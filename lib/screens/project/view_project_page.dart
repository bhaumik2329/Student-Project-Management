import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_project_form.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

class ViewProjectPage extends StatefulWidget {
  final String userRole;

  ViewProjectPage({required this.userRole});

  @override
  _ViewProjectPageState createState() => _ViewProjectPageState();
}

class _ViewProjectPageState extends State<ViewProjectPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _editProject(BuildContext context, Map<String, dynamic> projectData,
      String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProjectForm(projectData: projectData, projectId: projectId),
      ),
    );
  }

  Future<void> _deleteProject(BuildContext context, String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Project deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to delete project. Please try again.')),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _downloadFile(String url) async {
    // For web, this can be the same as opening the link
    // as the browser usually handles downloads automatically.
    await _launchURL(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Projects',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('projects').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final projects = snapshot.data!.docs;

                  return FutureBuilder<Map<String, String>>(
                    future: _getCategoryAndTagNames(),
                    builder: (context, categoryTagSnapshot) {
                      if (!categoryTagSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final categoryTagNames = categoryTagSnapshot.data!;
                      final filteredProjects = projects.where((project) {
                        final projectData =
                            project.data() as Map<String, dynamic>;
                        final categoryName =
                            categoryTagNames[projectData['category_id']] ??
                                'N/A';
                        final tagNames = (projectData['tags_id']
                                as List<dynamic>)
                            .map((tagId) => categoryTagNames[tagId] ?? 'N/A')
                            .join(', ');

                        final searchFields = [
                          projectData['p_name'].toString().toLowerCase(),
                          projectData['desc'].toString().toLowerCase(),
                          categoryName.toLowerCase(),
                          tagNames.toLowerCase()
                        ];

                        return searchFields.any((field) =>
                            field.contains(_searchQuery.toLowerCase()));
                      }).toList();

                      return ListView.builder(
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index].data()
                              as Map<String, dynamic>;
                          final projectId = filteredProjects[index].id;
                          final categoryName =
                              categoryTagNames[project['category_id']] ?? 'N/A';
                          final tagNames = (project['tags_id'] as List<dynamic>)
                              .map((tagId) => categoryTagNames[tagId] ?? 'N/A')
                              .join(', ');

                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    project['p_name'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Description: ${project['desc']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Category: $categoryName',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tags: $tagNames',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Project Report Link: ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.picture_as_pdf),
                                        label: Text('Report'),
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.green,
                                        ),
                                        onPressed: () {
                                          _launchURL(
                                              project['upload_file_link']);
                                        },
                                      ),
                                      SizedBox(width: 8),
                                      // ElevatedButton.icon(
                                      //   icon: Icon(Icons.download),
                                      //   label: Text('Download'),
                                      //   style: ElevatedButton.styleFrom(
                                      //     primary: Colors.orange,
                                      //   ),
                                      //   onPressed: () {
                                      //     _downloadFile(
                                      //         project['upload_file_link']);
                                      //   },
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  if (widget.userRole !=
                                      'Student') // Hide buttons for students
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.edit, size: 18),
                                          label: Text('Edit'),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.blue,
                                          ),
                                          onPressed: () => _editProject(
                                              context, project, projectId),
                                        ),
                                        SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.delete, size: 18),
                                          label: Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                  context, projectId),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _getCategoryAndTagNames() async {
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final tagsSnapshot = await _firestore.collection('tags').get();

    final categoryTagNames = <String, String>{};

    for (var doc in categoriesSnapshot.docs) {
      categoryTagNames[doc.id] = doc['name'];
    }

    for (var doc in tagsSnapshot.docs) {
      categoryTagNames[doc.id] = doc['name'];
    }

    return categoryTagNames;
  }

  void _showDeleteConfirmation(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Project'),
          content: Text('Are you sure you want to delete this project?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteProject(context, projectId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
