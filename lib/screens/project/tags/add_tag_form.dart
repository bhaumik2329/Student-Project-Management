import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTagForm extends StatefulWidget {
  @override
  _AddTagFormState createState() => _AddTagFormState();
}

class _AddTagFormState extends State<AddTagForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tagNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> addTag(String tagName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseFirestore.instance.collection('tags').add({
        'name': tagName,
        'created_date': DateTime.now().toIso8601String(),
      });

      // Tag successfully added
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tag added successfully')),
      );
      _formKey.currentState?.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add tag. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                'Add Tag',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(tagNameController, 'Tag Name'),
              SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            addTag(tagNameController.text);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          child: Text('Add Tag'),
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
