import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

enum SortCriteria { READY_FIRST, READY_LAST }

class OrderBloc extends BlocBase {
  final orderController = BehaviorSubject<List>();

  List<DocumentSnapshot> order = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  late SortCriteria criteria;

  Stream<List> get outOrder => orderController.stream;

  OrderBloc() {
    addOrderListener();
  }

  void addOrderListener() {
    firestore.collection("orders").snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        String oid = change.doc.id;
        switch (change.type) {
          case DocumentChangeType.added:
            order.add(change.doc);
            break;
          case DocumentChangeType.modified:
            order.removeWhere((element) => element.id == oid);
            order.add(change.doc);
            break;
          case DocumentChangeType.removed:
            order.removeWhere((element) => element.id == oid);
            break;
        }
      }
     sort();
    });
  }

  void setOrderCriteria(SortCriteria sortCriteria) {
    criteria = sortCriteria;
    sort();
  }

  void sort() {
    switch (criteria) {
      case SortCriteria.READY_FIRST:
        order.sort((a, b) {
          int sa = a.get("status");
          int sb = b.get("status");
          if (sa < sb) {
            return 1;
          } else if (sa > sb) {
            return -1;
          } else {
            return 0;
          }
        });
        break;
      case SortCriteria.READY_LAST:
        order.sort((a, b) {
          int sa = a.get("status");
          int sb = b.get("status");
          if (sa > sb) {
            return 1;
          } else if (sa < sb) {
            return -1;
          } else {
            return 0;
          }
        });
        break;
    }
    orderController.add(order);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    orderController.close();
  }
}
