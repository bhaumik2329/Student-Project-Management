import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_project_management/screens/faculty/add_faculty_form.dart';
import 'package:student_project_management/screens/faculty/view_faculty_page.dart';
import 'package:student_project_management/screens/login_screen.dart';
import 'package:student_project_management/screens/project/add_project_form.dart';
import 'package:student_project_management/screens/project/category/add_category_form.dart';
import 'package:student_project_management/screens/project/category/view_category_page.dart';
import 'package:student_project_management/screens/project/tags/add_tag_form.dart';
import 'package:student_project_management/screens/project/tags/view_tag_page.dart';
import 'package:student_project_management/screens/project/view_project_page.dart';
import 'package:student_project_management/screens/student/add_student_form.dart';
import 'package:student_project_management/screens/student/view_student_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _selectedPage = 'Home';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int studentCount = 0;
  int facultyCount = 0;
  int projectCount = 0;
  int categoryCount = 0;
  int tagCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetching data for statistics
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 1)
          .get();
      final facultySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 0)
          .where('is_admin', isEqualTo: false)
          .get();
      final projectSnapshot =
          await FirebaseFirestore.instance.collection('projects').get();
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final tagSnapshot =
          await FirebaseFirestore.instance.collection('tags').get();

      setState(() {
        studentCount = studentSnapshot.docs.length;
        facultyCount = facultySnapshot.docs.length;
        projectCount = projectSnapshot.docs.length;
        categoryCount = categorySnapshot.docs.length;
        tagCount = tagSnapshot.docs.length;
      });
    } catch (e) {
      print('Failed to fetch data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data. Please try again.')),
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
          'Admin Dashboard',
          style: TextStyle(color: Colors.white), // Set font color to white
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(
            color: Colors.white), // Set the icon theme color to white
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
                          'Admin Menu',
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
                                    builder: (context) => AdminDashboard()),
                              );
                            } else if (role == 'Faculty') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdminDashboard()),
                              );
                            }
                            // else if (role == 'Student') {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => StudentDashboard()),
                            //   );
                            // }
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
                  ListTile(
                    leading: Icon(Icons.dashboard, color: Colors.black),
                    title: Text(
                      'Dashboard',
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPage = 'Dashboard';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  _buildDropdownMenu(context, 'Student', Icons.school),
                  _buildDropdownMenu(context, 'Faculty', Icons.person),
                  _buildDropdownMenu(context, 'Project', Icons.work),
                  _buildDropdownMenu(context, 'Category', Icons.category),
                  _buildDropdownMenu(context, 'Tag', Icons.label),
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
          title: Text('Add $title'),
          onTap: () {
            setState(() {
              _selectedPage = 'Add $title';
            });
            Navigator.pop(context);
          },
        ),
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
      case 'Add Student':
        return AddStudentForm();
      case 'Add Faculty':
        return AddFacultyForm();
      case 'Add Project':
        return AddProjectForm();
      case 'Add Category':
        return AddCategoryForm();
      case 'Add Tag':
        return AddTagForm();
      case 'View Student':
        return ViewStudentPage();
      case 'View Faculty':
        return ViewFacultyPage();
      case 'View Project':
        return ViewProjectPage(
          userRole: 'Admin',
        );
      case 'View Category':
        return ViewCategoryPage();
      case 'View Tag':
        return ViewTagPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // Wide screen layout
            return Row(
              children: [
                Expanded(
                  child: _buildStatisticsCard(),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildPieChart(),
                ),
              ],
            );
          } else {
            // Narrow screen layout
            return Column(
              children: [
                _buildStatisticsCard(),
                SizedBox(height: 16),
                _buildPieChart(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStatisticsCard() {
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
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                _buildStatisticItem('Students', studentCount),
                _buildStatisticItem('Faculty', facultyCount),
                _buildStatisticItem('Projects', projectCount),
                _buildStatisticItem('Categories', categoryCount),
                _buildStatisticItem('Tags', tagCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
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
              'Entity Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 80,
                  sections: showingSections(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(5, (i) {
      final double fontSize = 14;
      final double radius = 100;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: studentCount.toDouble(),
            title: 'Students\n$studentCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.orange,
            value: facultyCount.toDouble(),
            title: 'Faculty\n$facultyCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.green,
            value: projectCount.toDouble(),
            title: 'Projects\n$projectCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.purple,
            value: categoryCount.toDouble(),
            title: 'Categories\n$categoryCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: Colors.red,
            value: tagCount.toDouble(),
            title: 'Tags\n$tagCount',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
