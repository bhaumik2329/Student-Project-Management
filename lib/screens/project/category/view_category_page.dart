import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_category_form.dart';

class ViewCategoryPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void _editCategory(
      BuildContext context, Map<String, dynamic> category, String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditCategoryForm(categoryData: {...category, 'id': categoryId}),
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Category deleted')),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to delete category. Please try again.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
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
                _deleteCategory(
                    context, categoryId); // Then call the delete function
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
                'Categories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final categoryData = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: categoryData.length,
                      itemBuilder: (context, index) {
                        final category =
                            categoryData[index].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(category['name'][0]),
                            ),
                            title: Text(
                              '${category['name']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text('Description: ${category['description']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editCategory(context,
                                      category, categoryData[index].id),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(
                                      context, categoryData[index].id),
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
