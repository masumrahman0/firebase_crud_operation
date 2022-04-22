import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddNewCourse extends StatefulWidget {
  const AddNewCourse({Key? key}) : super(key: key);

  @override
  _AddNewCourseState createState() => _AddNewCourseState();
}

class _AddNewCourseState extends State<AddNewCourse> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _courseImage;
  String? imageUrl;

  chooseImageFromGalery() async {
    final ImagePicker _picker = ImagePicker();
    _courseImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  writeData()async{
    File imageFile = File(_courseImage!.path);
    FirebaseStorage _storage = FirebaseStorage.instance;
    UploadTask _uploadTask = _storage.ref('image').child(_courseImage!.path).putFile(imageFile);
  
    TaskSnapshot snapshot = await _uploadTask;
    imageUrl = await snapshot.ref.getDownloadURL();
    print(imageUrl);
    CollectionReference _course = FirebaseFirestore.instance.collection('Course');
    _course.add({
      'name': _titleController.text,
      'description': _descriptionController.text,
      'image': imageUrl,
    });
    print("successfuly added");
    Navigator.pop(context);
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
                        ? IconButton(
                            onPressed: () => chooseImageFromGalery(),
                            icon: Icon(Icons.camera_outlined),
                          )
                        : Image.file(
                            File(_courseImage!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: ()=> writeData(),
              child: Text("Add New Course"),
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
