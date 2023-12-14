import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;

class CashTrackController {
  final User user;
  var _collectionName = '';

  void setCollectionName(String collectionName) {
    _collectionName = collectionName;
  }

  CashTrackController({required this.user});

  Stream<fb.QuerySnapshot<Object?>> get stream {
    return fb.FirebaseFirestore.instance
        .collection(FirebaseDataseConsts.walletCollectionName)
        .doc(user.walletId)
        .collection(_collectionName)
        .snapshots();
  }
}
