class AuthModel {
  final String phoneNumber;
  final String? verificationId;
  final String? uid;

  AuthModel({required this.phoneNumber, this.verificationId, this.uid});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      phoneNumber: json['phoneNumber'] ?? '',
      verificationId: json['verificationId'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'verificationId': verificationId,
      'uid': uid,
    };
  }

  AuthModel copyWith({
    String? phoneNumber,
    String? verificationId,
    String? uid,
  }) {
    return AuthModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      uid: uid ?? this.uid,
    );
  }
}
