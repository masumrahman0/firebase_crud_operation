import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateCourse extends StatefulWidget {
  String documentId;
  String title;
  String details;
  String image;

  UpdateCourse(this.documentId, this.title, this.details, this.image);

  @override
  _UpdateCourseState createState() => _UpdateCourseState();
}

class _UpdateCourseState extends State<UpdateCourse> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _courseImage;
  String? imageUrl;

  chooseImageFromGalery() async {
    final ImagePicker _picker = ImagePicker();
    _courseImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  updateData(selectDocument) async {
    if (_courseImage == null) {
      CollectionReference _course =
          FirebaseFirestore.instance.collection('Course');
      _course.doc(selectDocument).update({
        'name': _titleController.text,
        'description': _descriptionController.text,
        'image': widget.image,
      });
      print("successfuly added");
      Navigator.pop(context);
    } else {
      File imageFile = File(_courseImage!.path);
      FirebaseStorage _storage = FirebaseStorage.instance;
      UploadTask _uploadTask =
          _storage.ref('image').child(_courseImage!.path).putFile(imageFile);

      TaskSnapshot snapshot = await _uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      print(imageUrl);
      CollectionReference _course =
          FirebaseFirestore.instance.collection('Course');
      _course.doc(selectDocument).update({
        'name': _titleController.text,
        'description': _descriptionController.text,
        'image': imageUrl,
      });
      print("successfuly added");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.details;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter course title",
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Enter course Description",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: Material(
                    child: _courseImage == null
                        ? Stack(children: [
                            Image.network(
                              widget.image,
                              fit: BoxFit.cover,
                            ),
                            CircleAvatar(
                                child: IconButton(
                              onPressed: () => chooseImageFromGalery(),
                              icon: Icon(Icons.camera_outlined),
                            ))
                          ])
                        : Image.file(
                            File(_courseImage!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => updateData(widget.documentId),
              child: Text("Update"),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
