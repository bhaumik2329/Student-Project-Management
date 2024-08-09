import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFacultyForm extends StatefulWidget {
  @override
  _AddFacultyFormState createState() => _AddFacultyFormState();
}

class _AddFacultyFormState extends State<AddFacultyForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // Variable to track password visibility

  Future<void> addFaculty(
      String email, String password, String firstName, String lastName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user?.uid)
          .set({
        'user_id': userCredential.user?.uid,
        'f_name': firstName,
        'l_name': lastName,
        'email': email,
        'password': password,
        'role': 0,
        'created_date': DateTime.now().toIso8601String(),
        'is_active': true,
        'is_admin': false,
      });

      // User successfully signed up
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Faculty added successfully')),
      );
      _formKey.currentState?.reset();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'Failed to add faculty. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add faculty. Please try again.')),
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
                'Add Faculty Member',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(firstNameController, 'First Name'),
              SizedBox(height: 10),
              _buildTextField(lastNameController, 'Last Name'),
              SizedBox(height: 10),
              _buildTextField(emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 10),
              _buildPasswordField(passwordController, 'Password'),
              SizedBox(height: 20),
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            addFaculty(
                              emailController.text,
                              passwordController.text,
                              firstNameController.text,
                              lastNameController.text,
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          child: Text('Add Faculty'),
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
        if (labelText == 'Email') {
          if (!value.contains('@') || !value.endsWith('@fanshaweonline.ca')) {
            return 'Please enter a valid email from fanshaweonline.ca';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
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
        // Regex for complex password
        final passwordRegex = RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
        if (!passwordRegex.hasMatch(value)) {
          return 'Password must include uppercase, lowercase, number, and special character';
        }
        return null;
      },
    );
  }
}
