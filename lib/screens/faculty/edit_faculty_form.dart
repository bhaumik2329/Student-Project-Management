import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFacultyForm extends StatefulWidget {
  final Map<String, dynamic> facultyData;

  EditFacultyForm({required this.facultyData});

  @override
  _EditFacultyFormState createState() => _EditFacultyFormState();
}

class _EditFacultyFormState extends State<EditFacultyForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController roleController;
  late TextEditingController isActiveController;
  bool _obscurePassword = true; // Track password visibility

  @override
  void initState() {
    super.initState();
    firstNameController =
        TextEditingController(text: widget.facultyData['f_name']);
    lastNameController =
        TextEditingController(text: widget.facultyData['l_name']);
    emailController = TextEditingController(text: widget.facultyData['email']);
    passwordController =
        TextEditingController(text: widget.facultyData['password']);
    roleController = TextEditingController(
        text: widget.facultyData['role'] == 0
            ? 'Faculty'
            : (widget.facultyData['is_admin'] ? 'Admin' : 'Student'));
    isActiveController = TextEditingController(
        text: widget.facultyData['is_active'] ? 'Yes' : 'No');
  }

  Future<void> _updateFaculty() async {
    if (_formKey.currentState!.validate()) {
      try {
        String role = roleController.text;
        bool isAdmin = false;
        int roleValue = 0;

        if (role == 'Admin') {
          isAdmin = true;
        } else if (role == 'Faculty') {
          isAdmin = false;
          roleValue = 0;
        } else if (role == 'Student') {
          isAdmin = false;
          roleValue = 1; // Assuming 1 is the role value for students
        }

        bool isActive = isActiveController.text == 'Yes';

        await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.facultyData['user_id'])
            .update({
          'f_name': firstNameController.text,
          'l_name': lastNameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'role': roleValue,
          'is_active': isActive,
          'is_admin': isAdmin,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Faculty member updated successfully')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update faculty member. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Faculty'),
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
                    roleController, 'Role', ['Admin', 'Faculty', 'Student']),
                SizedBox(height: 10),
                _buildDropdownField(
                    isActiveController, 'Active', ['Yes', 'No']),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateFaculty,
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
    // Add readOnly parameter
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
