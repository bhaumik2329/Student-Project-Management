import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_faculty_form.dart';

class ViewFacultyPage extends StatefulWidget {
  @override
  _ViewFacultyPageState createState() => _ViewFacultyPageState();
}

class _ViewFacultyPageState extends State<ViewFacultyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String _selectedFilter = 'All'; // Default filter option

  void _editFaculty(BuildContext context, Map<String, dynamic> faculty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFacultyForm(facultyData: faculty),
      ),
    );
  }

  Future<void> _deleteFaculty(BuildContext context, String userId) async {
    try {
      await _firestore.collection('user').doc(userId).delete();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Faculty member deleted')),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
            content:
                Text('Failed to delete faculty member. Please try again.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Faculty'),
          content: Text('Are you sure you want to delete this faculty member?'),
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
                _deleteFaculty(
                    context, userId); // Then call the delete function
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFacultyStream() {
    CollectionReference usersCollection = _firestore.collection('user');
    switch (_selectedFilter) {
      case 'Active':
        return usersCollection
            .where('role', isEqualTo: 0)
            .where('is_admin', isEqualTo: false)
            .where('is_active', isEqualTo: true)
            .snapshots();
      case 'Deactivated':
        return usersCollection
            .where('role', isEqualTo: 0)
            .where('is_admin', isEqualTo: false)
            .where('is_active', isEqualTo: false)
            .snapshots();
      default:
        return usersCollection
            .where('role', isEqualTo: 0)
            .where('is_admin', isEqualTo: false)
            .snapshots();
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
                'Faculty Members',
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
                items: <String>['All', 'Active', 'Deactivated']
                    .map((String value) {
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
                  stream: _getFacultyStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final facultyData = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: facultyData.length,
                      itemBuilder: (context, index) {
                        final faculty =
                            facultyData[index].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(faculty['f_name'][0]),
                            ),
                            title: Text(
                              '${faculty['f_name']} ${faculty['l_name']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Email: ${faculty['email']}'),
                                Text('Role: Faculty'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _editFaculty(context, faculty),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(
                                      context, facultyData[index].id),
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
