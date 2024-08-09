import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_tag_form.dart';

class ViewTagPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void _editTag(BuildContext context, Map<String, dynamic> tag, String tagId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTagForm(tagData: {...tag, 'id': tagId}),
      ),
    );
  }

  Future<void> _deleteTag(BuildContext context, String tagId) async {
    try {
      await _firestore.collection('tags').doc(tagId).delete();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Tag deleted')),
      );
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to delete tag. Please try again.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String tagId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Tag'),
          content: Text('Are you sure you want to delete this tag?'),
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
                _deleteTag(context, tagId); // Then call the delete function
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
                'Tags',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('tags').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final tagData = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: tagData.length,
                      itemBuilder: (context, index) {
                        final tag =
                            tagData[index].data() as Map<String, dynamic>;
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(tag['name'][0]),
                            ),
                            title: Text(
                              '${tag['name']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Created: ${tag['created_date']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _editTag(context, tag, tagData[index].id),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _confirmDelete(
                                      context, tagData[index].id),
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
