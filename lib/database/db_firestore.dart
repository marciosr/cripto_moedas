// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firedart/firedart.dart';
// import 'package:firedart/firestore/firestore.dart';

class DBFirestore {
  DBFirestore._();
  static final DBFirestore _instance = DBFirestore._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static FirebaseFirestore get() {
    return DBFirestore._instance._firestore;
  }
}
