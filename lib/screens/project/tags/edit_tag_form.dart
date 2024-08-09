import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTagForm extends StatefulWidget {
  final Map<String, dynamic> tagData;

  EditTagForm({required this.tagData});

  @override
  _EditTagFormState createState() => _EditTagFormState();
}

class _EditTagFormState extends State<EditTagForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController tagNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tagNameController = TextEditingController(text: widget.tagData['name']);
  }

  @override
  void dispose() {
    tagNameController.dispose();
    super.dispose();
  }

  Future<void> _editTag() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('tags')
          .doc(widget.tagData['id'])
          .update({
        'name': tagNameController.text,
        'updated_date': DateTime.now().toIso8601String(),
      });

      // Tag successfully updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tag updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update tag. Please try again.')),
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
        title: Text('Edit Tag', style: TextStyle(color: Colors.white)),
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
                  'Edit Tag',
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
                              _editTag();
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
