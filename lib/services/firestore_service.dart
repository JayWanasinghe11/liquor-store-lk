import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Stream<QuerySnapshot> getDrinks() {
    return _db.collection('drinks').snapshots();
  }
}