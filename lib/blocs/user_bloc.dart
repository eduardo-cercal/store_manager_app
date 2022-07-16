import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc extends BlocBase {
  final userController = BehaviorSubject<List>();

  Map<String, Map<String, dynamic>> user = {};

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List> get outUser => userController.stream;

  UserBloc() {
    addUserListener();
  }

  void onChangedSearch(String search) {
    if (search.trim().isEmpty) {
      userController.add(user.values.toList());
    } else {
      userController.add(filter(search.trim()));
    }
  }

  void addUserListener() {
    firestore.collection("users").snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        String uid = change.doc.id;
        switch (change.type) {
          case DocumentChangeType.added:
            user[uid] = change.doc.data()!;
            subscribeToOrders(uid);
            break;
          case DocumentChangeType.modified:
            user[uid]!.addAll(change.doc.data()!);
            userController.add(user.values.toList());
            break;
          case DocumentChangeType.removed:
            user.remove(uid);
            unsubscribeToOrders(uid);
            userController.add(user.values.toList());
            break;
        }
      }
    });
  }

  void subscribeToOrders(String uid) {
    user[uid]!["subscription"] = firestore
        .collection("users")
        .doc(uid)
        .collection("orders")
        .snapshots()
        .listen((orders) async {
      int numOrders = orders.docs.length;
      double money = 0;

      for (DocumentSnapshot doc in orders.docs) {
        DocumentSnapshot order =
            await firestore.collection("orders").doc(doc.id).get();
        if (order.data() == null) continue;
        money += order.get("totalPrice");
      }
      user[uid]!.addAll({
        "money": money,
        "orders": numOrders,
      });
      userController.add(user.values.toList());
    });
  }

  void unsubscribeToOrders(String uid) {
    user[uid]!["subscription"].cancel();
  }

  Map<String,dynamic> getUser(String uid){
    return user[uid]!;
  }

  List<Map<String, dynamic>> filter(String search) {
    List<Map<String, dynamic>> filteredUsers = List.from(user.values.toList());
    filteredUsers.retainWhere((s) {
      return s["name"].toUpperCase().contains(search.toUpperCase());
    });
    return filteredUsers;
  }

  @override
  void dispose() {
    super.dispose();
    userController.close();
  }
}
