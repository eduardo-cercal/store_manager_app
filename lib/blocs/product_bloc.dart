import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProductBloc extends BlocBase {
  final dataController = BehaviorSubject<Map>();
  final loadController = BehaviorSubject<bool>();
  final createController = BehaviorSubject<bool>();
  late String categoryId;
  DocumentSnapshot? product;
  late Map<String, dynamic> unsavedData;

  Stream<Map> get outData => dataController.stream;

  Stream<bool> get outLoading => loadController.stream;

  Stream<bool> get outCreate => createController.stream;

  ProductBloc({this.product, required this.categoryId}) {
    if (product != null) {
      unsavedData = Map.of(product!.data() as Map<String, dynamic>);
      unsavedData["images"] = List.of(product!.get("images"));
      unsavedData["sizes"] = List.of(product!.get("sizes"));
      createController.add(true);
    } else {
      unsavedData = {
        "title": null,
        "description": null,
        "price": null,
        "images": [],
        "sizes": [],
      };
      createController.add(false);
    }
    dataController.add(unsavedData);
  }

  void saveTitle(String? title) {
    unsavedData["title"] = title;
  }

  void saveDescription(String? description) {
    unsavedData["description"] = description;
  }

  void savePrice(String? price) {
    unsavedData["price"] = double.parse(price!);
  }

  void saveImage(List? image) {
    unsavedData["images"] = image;
  }

  void saveSize(List? size) {
    unsavedData["sizes"] = size;
  }

  Future<bool> saveProduct() async {
    loadController.add(true);
    try {
      if (product != null) {
        await uploadImage(product!.id);
        await product!.reference.update(unsavedData);
      } else {
        DocumentReference dr = await FirebaseFirestore.instance
            .collection("products")
            .doc(categoryId)
            .collection("itens")
            .add(Map.from(unsavedData)..remove("images"));
        await uploadImage(dr.id);
        await dr.update(unsavedData);
      }
      createController.add(true);
      loadController.add(false);
      return true;
    } catch (e) {
      loadController.add(false);
      return false;
    }
  }

  Future uploadImage(String id) async {
    for (int i = 0; i < unsavedData["images"].length; i++) {
      if (unsavedData["images"][i] is String) continue;

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child(id)
          .child(id)
          .child(DateTime.now().microsecondsSinceEpoch.toString())
          .putFile(unsavedData["images"][i]);
      TaskSnapshot s = await uploadTask.whenComplete(() {});
      String downloadUrl = await s.ref.getDownloadURL();

      unsavedData["images"][i] = downloadUrl;
    }
  }

  void deleteProduct(){
    product!.reference.delete();
  }
}
