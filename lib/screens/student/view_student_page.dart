import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_student_form.dart';

class ViewStudentPage extends StatefulWidget {
  @override
  _ViewStudentPageState createState() => _ViewStudentPageState();
}

class _ViewStudentPageState extends State<ViewStudentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  
  String _selectedFilter = 'All'; // Default filter option

  void _editStudent(BuildContext context, Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditStudentForm(studentData: student),
      ),
    );
  }

  Future<void> _deleteStudent(BuildContext context, String userId) async {
    try {
      await _firestore.collection('user').doc(userId).delete();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Student deleted')),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to delete student. Please try again.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Student'),
          content: Text('Are you sure you want to delete this student?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                _deleteStudent(
                    context, userId); // Then call the delete function
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _getStudentsStream() {
    CollectionReference usersCollection = _firestore.collection('user');
    switch (_selectedFilter) {
      case 'Active':
        return usersCollection.where('role', isEqualTo: 1).where('is_active', isEqualTo: true).snapshots();
      case 'Deactivated':
        return usersCollection.where('role', isEqualTo: 1).where('is_active', isEqualTo: false).snapshots();
      default:
        return usersCollection.where('role', isEqualTo: 1).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              // Filter Dropdown
              DropdownButton<String>(
                value: _selectedFilter,
                items: <String>['All', 'Active', 'Deactivated'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFilter = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getStudentsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final studentData = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: studentData.length,
                      itemBuilder: (context, index) {
                        final student =
                            studentData[index].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(student['f_name'][0]),
                            ),
                            title: Text(
                              '${student['f_name']} ${student['l_name']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Email: ${student['email']}'),
                                Text('Role: Student'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _editStudent(context, student),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(
                                      context, studentData[index].id),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
