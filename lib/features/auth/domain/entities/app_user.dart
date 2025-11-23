class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  factory AppUser.fromFirebaseUser(dynamic firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoUrl.hashCode;
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }
}
