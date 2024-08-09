import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStudentForm extends StatefulWidget {
  final Map<String, dynamic> studentData;

  EditStudentForm({required this.studentData});

  @override
  _EditStudentFormState createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<EditStudentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController isActiveController;
  bool _obscurePassword = true; // Track password visibility

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.studentData['f_name']);
    lastNameController =
        TextEditingController(text: widget.studentData['l_name']);
    emailController = TextEditingController(text: widget.studentData['email']);
    passwordController =
        TextEditingController(text: widget.studentData['password']);
    isActiveController = TextEditingController(
        text: widget.studentData['is_active'] ? 'Yes' : 'No');
  }

  Future<void> _updateStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool isActive = isActiveController.text == 'Yes';

        await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.studentData['user_id'])
            .update({
          'f_name': firstNameController.text,
          'l_name': lastNameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'is_active': isActive,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update student. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField(firstNameController, 'First Name'),
                SizedBox(height: 10),
                _buildTextField(lastNameController, 'Last Name'),
                SizedBox(height: 10),
                _buildTextField(emailController, 'Email',
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true), // Email field set to read-only
                SizedBox(height: 10),
                _buildPasswordField(passwordController, 'Password',
                    readOnly: true), // Password field set to read-only
                SizedBox(height: 10),
                _buildDropdownField(
                    isActiveController, 'Active', ['Yes', 'No']),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateStudent,
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
      TextInputType keyboardType = TextInputType.text,
      bool readOnly = false}) {
    // Add readOnly parameter
    return TextFormField(
      controller: controller,
      readOnly: readOnly, // Set the readOnly property
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
        if (labelText == 'Email') {
          if (!value.contains('@') || !value.endsWith('@fanshaweonline.ca')) {
            return 'Please enter a valid email from fanshaweonline.ca';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText,
      {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      readOnly: readOnly, // Set the readOnly property
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
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter ${labelText.toLowerCase()}';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(
      TextEditingController controller, String labelText, List<String> items) {
    return DropdownButtonFormField<String>(
      value: controller.text,
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
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          controller.text = newValue!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a ${labelText.toLowerCase()}';
        }
        return null;
      },
    );
  }
}
