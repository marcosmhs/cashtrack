import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class Wallet {
  late String id;
  late String name;
  late String invitationCode;
  late String ownerUserId;

  Wallet({
    this.id = '',
    this.name = '',
    String invitationCode = '',
    this.ownerUserId = '',
  }) {
    this.invitationCode = invitationCode.isNotEmpty ? invitationCode : TebUidGenerator.customInvitationCode();
  }

  factory Wallet.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Wallet.fromMap(data);
  }

  static Wallet fromMap(Map<String, dynamic> map) {
    var w = Wallet();

    w = Wallet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      invitationCode: map['invitationCode'] ?? '',
      ownerUserId: map['ownerUserId'] ?? '',
    );
    return w;
  }

  Map<String, dynamic> get toMap {
    Map<String, dynamic> r = {};

    r = {
      'id': id,
      'name': name,
      'invitationCode': invitationCode,
      'ownerUserId': ownerUserId,
    };

    return r;
  }
}
