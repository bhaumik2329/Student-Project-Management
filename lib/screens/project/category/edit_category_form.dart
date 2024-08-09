import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategoryForm extends StatefulWidget {
  final Map<String, dynamic> categoryData;

  EditCategoryForm({required this.categoryData});

  @override
  _EditCategoryFormState createState() => _EditCategoryFormState();
}

class _EditCategoryFormState extends State<EditCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.categoryData['name']);
    descriptionController =
        TextEditingController(text: widget.categoryData['description']);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _editCategory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryData['id'])
          .update({
        'name': nameController.text,
        'description': descriptionController.text,
        'updated_date': DateTime.now().toIso8601String(),
      });

      // Category successfully updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update category. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Category', style: TextStyle(color: Colors.white)),
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
                  'Edit Category',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField(nameController, 'Category Name'),
                SizedBox(height: 10),
                _buildTextField(descriptionController, 'Category Description'),
                SizedBox(height: 20),
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _editCategory();
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
