import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_project_management/screens/login_screen.dart';
import 'package:student_project_management/screens/project/view_project_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String _selectedPage = 'Home';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Failed to log out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(color: Colors.white), // Set font color to white
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(
            color: Colors.white), // Set the icon theme color to purple
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/logo.png', // Path to your logo image
                          height: 60,
                          width: 300,
                        ),
                      ],
                    ),
                  ),
                  _buildDropdownMenu(context, 'Project', Icons.work),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _buildPageContent(),
    );
  }

  Widget _buildDropdownMenu(BuildContext context, String title, IconData icon) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      children: <Widget>[
        ListTile(
          title: Text('View $title'),
          onTap: () {
            setState(() {
              _selectedPage = 'View $title';
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildPageContent() {
    switch (_selectedPage) {
      case 'View Project':
        return ViewProjectPage(
          userRole: 'Student',
        );

      default:
        return const Center(child: Text('Welcome to Student Dashboard'));
    }
  }
}
