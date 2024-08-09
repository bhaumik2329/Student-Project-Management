import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProjectForm extends StatefulWidget {
  final Map<String, dynamic> projectData;
  final String projectId; // Add this field to capture the project ID

  EditProjectForm(
      {required this.projectData,
      required this.projectId}); // Update constructor to accept project ID

  @override
  _EditProjectFormState createState() => _EditProjectFormState();
}

class _EditProjectFormState extends State<EditProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController projectNameController;
  late TextEditingController projectDescriptionController;
  late TextEditingController uploadFileLinkController;
  String? selectedCategoryId;
  List<String> selectedTagIds = [];
  String? selectedUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    projectNameController =
        TextEditingController(text: widget.projectData['p_name']);
    projectDescriptionController =
        TextEditingController(text: widget.projectData['desc']);
    uploadFileLinkController =
        TextEditingController(text: widget.projectData['upload_file_link']);
    selectedCategoryId = widget.projectData['category_id'];
    selectedTagIds = List<String>.from(widget.projectData['tags_id']);
    selectedUserId = widget.projectData['user_id'];
  }

  @override
  void dispose() {
    projectNameController.dispose();
    projectDescriptionController.dispose();
    uploadFileLinkController.dispose();
    super.dispose();
  }

  Future<void> updateProject() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.projectId)
          .update({
        'user_id': selectedUserId,
        'p_name': projectNameController.text,
        'desc': projectDescriptionController.text,
        'updated_at': DateTime.now().toIso8601String(),
        'upload_file_link': uploadFileLinkController.text,
        'category_id': selectedCategoryId,
        'tags_id': selectedTagIds,
      });

      // Project successfully updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update project. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Edit Project',
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
                SizedBox(height: 20),
                _buildUserDropdown(),
                SizedBox(height: 10),
                _buildTextField(uploadFileLinkController, 'Upload File Link'),
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
                              updateProject();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            child: Text('Save Changes'),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                            textStyle: TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ],
            ),
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
                                  onSelectionChanged(
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
