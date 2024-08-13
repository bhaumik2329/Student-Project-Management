import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_admin_form.dart';

class ViewAdminPage extends StatefulWidget {
  @override
  _ViewAdminPageState createState() => _ViewAdminPageState();
}

class _ViewAdminPageState extends State<ViewAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String _selectedFilter = 'All'; // Default filter option

  void _editAdmin(BuildContext context, Map<String, dynamic> admin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAdminForm(
          adminData: admin,
          facultyData: admin,
        ),
      ),
    );
  }

  Future<void> _deleteAdmin(BuildContext context, String userId) async {
    try {
      await _firestore.collection('user').doc(userId).delete();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Admin deleted')),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to delete admin. Please try again.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Admin'),
          content: Text('Are you sure you want to delete this admin?'),
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
                _deleteAdmin(context, userId); // Then call the delete function
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot> _getAdminStream() {
    CollectionReference usersCollection = _firestore.collection('user');
    switch (_selectedFilter) {
      case 'Active':
        return usersCollection
            .where('is_admin', isEqualTo: true)
            .where('is_active', isEqualTo: true)
            .snapshots();
      case 'All':
        return usersCollection
            .where('is_admin', isEqualTo: true)
            // .where('is_active', isEqualTo: true)
            .snapshots();
      case 'Deactivated':
        return usersCollection
            .where('is_admin', isEqualTo: true)
            .where('is_active', isEqualTo: false)
            .snapshots();
      default:
        return usersCollection.where('is_admin', isEqualTo: true).snapshots();
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
                'Admin Members',
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
                  stream: _getAdminStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final adminData = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: adminData.length,
                      itemBuilder: (context, index) {
                        final admin =
                            adminData[index].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(admin['f_name'][0]),
                            ),
                            title: Text(
                              '${admin['f_name']} ${admin['l_name']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Email: ${admin['email']}'),
                                Text('Role: Admin'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editAdmin(context, admin),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(
                                      context, adminData[index].id),
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
