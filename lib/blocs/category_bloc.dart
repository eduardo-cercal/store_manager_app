import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase {
  final titleController = BehaviorSubject<String>();
  final imageController = BehaviorSubject();
  final deleteController = BehaviorSubject<bool>();
  DocumentSnapshot? category;
  File? image;
  late String title;

  Stream<String> get outTitle => titleController.stream.transform(
          StreamTransformer<String, String>.fromHandlers(
              handleData: (title, sink) {
        if (title.isEmpty) {
          sink.addError("Insira um título");
        } else {
          sink.add(title);
        }
      }));

  Stream get outImage => imageController.stream;

  Stream<bool> get outDelete => deleteController.stream;

  Stream<bool> get submitValid =>
      Rx.combineLatest2(outTitle, outImage, (a, b) => true);

  CategoryBloc({this.category}) {
    if (category != null) {
      title=category!.get("title");
      titleController.add(category!.get("title"));
      imageController.add(category!.get("icon"));
      deleteController.add(true);
    } else {
      deleteController.add(false);
    }
  }

  void setImage(File file) {
    image = file;
    imageController.add(file);
  }

  void setTitle(String title) {
    this.title = title;
    titleController.add(title);
  }

  Future saveData() async {
    if (image == null && category != null && title == category!.get("title")) {
      return;
    }
    Map<String, dynamic> dataToUpdate = {};
    if (image != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("icons")
          .child("title")
          .putFile(image!);
      TaskSnapshot snap = await task.whenComplete(() {});
      dataToUpdate["icon"] = await snap.ref.getDownloadURL();
    }
    if (category == null || title != category!.get("title")) {
      dataToUpdate["title"] = title;
    }
    if (category == null) {
      await FirebaseFirestore.instance
          .collection("products")
          .doc(title.toLowerCase())
          .set(dataToUpdate);
    } else {
      await category!.reference.update(dataToUpdate);
    }
  }

  void delete(){
    category!.reference.delete();
  }
}
