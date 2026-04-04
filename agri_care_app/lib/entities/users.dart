class AppUser {
  final String id;
  final String username;
  final String email;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }
}