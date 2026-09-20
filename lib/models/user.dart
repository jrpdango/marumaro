/// The authenticated MyAnimeList user.
class User {
  const User({required this.name, this.picture});

  final String name;
  final Uri? picture;

  factory User.fromJson(Map<String, dynamic> json) {
    final String? picture = json["picture"] as String?;
    return User(
      name: (json["name"] as String?) ?? "",
      picture: picture == null ? null : Uri.tryParse(picture),
    );
  }
}
