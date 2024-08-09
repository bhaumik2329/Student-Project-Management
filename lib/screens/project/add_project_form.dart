import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:typed_data'; // For Uint8List

class AddProjectForm extends StatefulWidget {
  @override
  _AddProjectFormState createState() => _AddProjectFormState();
}

class _AddProjectFormState extends State<AddProjectForm> {
  Uint8List? fileBytes;

  final _formKey = GlobalKey<FormState>();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController projectDescriptionController = TextEditingController();
  TextEditingController uploadFileLinkController = TextEditingController();
  String? selectedUserId;
  String? selectedCategoryId;
  List<String> selectedTagIds = [];
  bool _isLoading = false;
  File? selectedFile;
  String? fileDownloadUrl;

  Future<void> addProject() async {
    if ((selectedFile == null && fileBytes == null) &&
        uploadFileLinkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload a file or enter a URL')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (selectedFile != null || fileBytes != null) {
        // Upload the PDF to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('project_files/${selectedFile!.path.split('/').last}');

        if (kIsWeb) {
          // Upload file bytes for web
          await storageRef.putData(fileBytes!);
        } else {
          // Upload file path for mobile
          await storageRef.putFile(selectedFile!);
        }

        // Get the download URL
        fileDownloadUrl = await storageRef.getDownloadURL();
      } else {
        fileDownloadUrl = uploadFileLinkController.text;
      }

      // Add project details to Firestore
      await FirebaseFirestore.instance.collection('projects').add({
        'user_id': selectedUserId,
        'p_name': projectNameController.text,
        'desc': projectDescriptionController.text,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'upload_file_link': fileDownloadUrl,
        'category_id': selectedCategoryId,
        'tags_id': selectedTagIds,
      });

      // Project successfully added
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project added successfully')),
      );
      _formKey.currentState?.reset();
      setState(() {
        selectedUserId = null;
        selectedCategoryId = null;
        selectedTagIds = [];
        selectedFile = null;
        fileDownloadUrl = null;
        fileBytes = null;
      });
    } catch (e) {
      print('Error adding project: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add project. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'word', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.single;

        if (kIsWeb) {
          // For web, handle the file bytes
          setState(() {
            selectedFile = File(platformFile.name); // Placeholder for file name
            fileBytes = platformFile.bytes; // Store the file bytes
            uploadFileLinkController.clear(); // Clear manual URL input
          });
        } else {
          // For mobile platforms, handle the file path
          setState(() {
            selectedFile = File(platformFile.path!);
            fileBytes = null;
            uploadFileLinkController.clear(); // Clear manual URL input
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file. Please try again.')),
      );
    }
  }

  Widget _buildUserDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var users = snapshot.data!.docs;
        return DropdownButtonFormField<String>(
          value: selectedUserId,
          decoration: InputDecoration(
            labelText: 'Select User',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          items: users.map((user) {
            return DropdownMenuItem<String>(
              value: user.id,
              child: Text(user['f_name'] + ' ' + user['l_name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedUserId = value;
            });
          },
          validator: (value) => value == null ? 'Please select a user' : null,
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var categories = snapshot.data!.docs;
        return DropdownButtonFormField<String>(
          value: selectedCategoryId,
          decoration: InputDecoration(
            labelText: 'Select Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Text(category['name']),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCategoryId = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a category' : null,
        );
      },
    );
  }

  Widget _buildTagsDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tags').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var tags = snapshot.data!.docs;
        return MultiSelectFormField(
          title: Text('Select Tags'),
          dataSource: tags.map((tag) {
            return {"display": tag['name'], "value": tag.id};
          }).toList(),
          textField: 'display',
          valueField: 'value',
          okButtonLabel: 'OK',
          cancelButtonLabel: 'CANCEL',
          hintWidget: Text(' '),
          initialValue: selectedTagIds,
          onSaved: (value) {
            if (value == null) return;
            setState(() {
              selectedTagIds = List<String>.from(value);
            });
          },
          validator: (value) {
            if (selectedTagIds.isEmpty) return 'Please select at least one tag';
            return null;
          },
          onSelectionChanged: (value) {
            setState(() {
              selectedTagIds = value;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add Project',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(projectNameController, 'Project Name'),
              SizedBox(height: 10),
              _buildTextField(
                  projectDescriptionController, 'Project Description'),
              SizedBox(height: 10),
              _buildUserDropdown(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: selectFile,
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  textStyle: TextStyle(fontSize: 16),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  selectedFile != null
                      ? 'File Selected: ${selectedFile!.path.split('/').last}'
                      : 'Select PDF File',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(uploadFileLinkController, 'Or Enter File URL'),
              SizedBox(height: 10),
              _buildCategoryDropdown(),
              SizedBox(height: 10),
              _buildTagsDropdown(),
              SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            addProject();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          textStyle: TextStyle(fontSize: 16),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: Text('Add Project'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${labelText.toLowerCase()}';
        }
        return null;
      },
    );
  }
}

class MultiSelectFormField extends FormField<List<String>> {
  final Widget title;
  final List<Map<String, dynamic>> dataSource;
  final String textField;
  final String valueField;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final Widget hintWidget;
  final ValueChanged<List<String>> onSelectionChanged;

  MultiSelectFormField({
    required this.title,
    required this.dataSource,
    required this.textField,
    required this.valueField,
    required this.okButtonLabel,
    required this.cancelButtonLabel,
    required this.hintWidget,
    required this.onSelectionChanged,
    FormFieldSetter<List<String>>? onSaved,
    FormFieldValidator<List<String>>? validator,
    List<String>? initialValue,
    bool autovalidate = false,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue ?? [],
          autovalidateMode: autovalidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          builder: (FormFieldState<List<String>> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    List<String>? selectedValues = await showDialog(
                      context: state.context,
                      builder: (BuildContext context) {
                        return MultiSelectDialog(
                          title: title,
                          dataSource: dataSource,
                          textField: textField,
                          valueField: valueField,
                          okButtonLabel: okButtonLabel,
                          cancelButtonLabel: cancelButtonLabel,
                          hintWidget: hintWidget,
                          initialSelectedValues: state.value ?? [],
                        );
                      },
                    );
                    if (selectedValues != null) {
                      state.didChange(selectedValues);
                      onSelectionChanged(selectedValues);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: title is Text ? (title as Text).data : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                    ),
                    isEmpty: state.value == null || state.value!.isEmpty,
                    child: state.value == null || state.value!.isEmpty
                        ? hintWidget
                        : Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: state.value!.map((tagId) {
                              String tagName = dataSource.firstWhere(
                                  (tag) => tag['value'] == tagId)[textField];
                              return Chip(
                                label: Text(tagName),
                                onDeleted: () {
                                  state.didChange(
                                      List<String>.from(state.value!)
                                        ..remove(tagId));
                                },
                              );
                            }).toList(),
                          ),
                  ),
                ),
                state.hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(color: Colors.red, fontSize: 12.0),
                        ),
                      )
                    : Container(),
              ],
            );
          },
        );
}

class MultiSelectDialog extends StatefulWidget {
  final Widget title;
  final List<Map<String, dynamic>> dataSource;
  final String textField;
  final String valueField;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final Widget hintWidget;
  final List<String> initialSelectedValues;

  MultiSelectDialog({
    required this.title,
    required this.dataSource,
    required this.textField,
    required this.valueField,
    required this.okButtonLabel,
    required this.cancelButtonLabel,
    required this.hintWidget,
    required this.initialSelectedValues,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List<String>.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.dataSource.map((item) {
            return CheckboxListTile(
              value: _selectedValues.contains(item[widget.valueField]),
              title: Text(item[widget.textField]),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedValues.add(item[widget.valueField]);
                  } else {
                    _selectedValues.remove(item[widget.valueField]);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(widget.cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selectedValues);
          },
          child: Text(widget.okButtonLabel),
        ),
      ],
    );
  }
}
