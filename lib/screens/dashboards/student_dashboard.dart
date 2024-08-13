import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_project_management/screens/login_screen.dart';
import 'package:student_project_management/screens/profile/ProfilePage.dart';
import 'package:student_project_management/screens/project/view_project_page.dart';
import 'dart:math';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String _selectedPage = 'Home';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int totalProjectCount = 0;
  int submittedProjectCount = 0;
  String selectedQuote = '';

  final List<String> motivationalQuotes = [
    '“The only way to do great work is to love what you do.” - Steve Jobs',
    '“Success is not final, failure is not fatal: It is the courage to continue that counts.” - Winston Churchill',
    '“Don’t watch the clock; do what it does. Keep going.” - Sam Levenson',
    '“The future depends on what you do today.” - Mahatma Gandhi',
    '“Your limitation—it’s only your imagination.”',
    '“Push yourself, because no one else is going to do it for you.”',
    '“Great things never come from comfort zones.”',
    '“Dream it. Wish it. Do it.”',
    '“Success doesn’t just find you. You have to go out and get it.”',
    '“The harder you work for something, the greater you’ll feel when you achieve it.”'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProjectStatistics();
    _selectRandomQuote();
  }

  void _selectRandomQuote() {
    final random = Random();
    setState(() {
      selectedQuote =
          motivationalQuotes[random.nextInt(motivationalQuotes.length)];
    });
  }

  Future<void> _fetchProjectStatistics() async {
    try {
      final projectSnapshot =
          await FirebaseFirestore.instance.collection('projects').get();
      final submittedSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('status',
              isEqualTo: 'submitted') // Assuming 'submitted' is a status
          .get();

      setState(() {
        totalProjectCount = projectSnapshot.docs.length;
        submittedProjectCount = submittedSnapshot.docs.length;
      });
    } catch (e) {
      print('Failed to fetch project statistics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to load project statistics. Please try again.')),
      );
    }
  }

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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
                        InkWell(
                          onTap: () {
                            // Logic to determine which dashboard to navigate to
                            String role =
                                'Admin'; // Replace with actual logic to get role

                            if (role == 'Admin') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentDashboard()),
                              );
                            } else if (role == 'Faculty') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentDashboard()),
                              );
                            } else if (role == 'Student') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StudentDashboard()),
                              );
                            }
                          },
                          child: Image.asset(
                            'assets/logo.png', // Path to your logo image
                            height: 60,
                            width: 300,
                          ),
                        )
                      ],
                    ),
                  ),
                  _buildDropdownMenu(context, 'Project', Icons.work),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.black),
              title: Text('My Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
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
        return _buildStudentDashboard();
    }
  }

  Widget _buildStudentDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMotivationalQuote(),
          const SizedBox(height: 20),
          _buildProjectStatistics(),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            selectedQuote,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectStatistics() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Projects Submitted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Projects: $totalProjectCount',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 8),
            // Text(
            //   'Submitted Projects: $submittedProjectCount',
            //   style: TextStyle(
            //     fontSize: 18,
            //     color: Colors.black54,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
