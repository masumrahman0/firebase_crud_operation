import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud_operation/Views/add_new_course.dart';
import 'package:firebase_crud_operation/Views/update_course.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Stream<QuerySnapshot> _courseStream =
      FirebaseFirestore.instance.collection('Course').snapshots();

  addNewCourse() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => AddNewCourse(),
    );
  }

  Future<void> deleteCourse(selectDocument) {
    return FirebaseFirestore.instance
        .collection('Course')
        .doc(selectDocument)
        .delete()
        .then((value) => print("Course has been deleted"))
        .catchError((error) => print(error));
  }

  Future<void> Update(selectDocumentID, title, description, image) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) => UpdateCourse(selectDocumentID, title, description, image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Courses"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => addNewCourse(),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _courseStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                  width: double.maxFinite,
                                  child: Image.network(
                                    data['image'],
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              data['name'],
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(data['description']),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Card(
                          child: Container(
                            height: 40,
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: ()=>Update(document.id,data['name'],data['description'],data['image']),
                                  icon: Icon(Icons.edit_rounded),
                                ),
                                IconButton(
                                  onPressed: () => deleteCourse(document.id),
                                  icon: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
