///
/// Class representing a profile
///
class Profile {

  final String name;
  final int id;

  Profile({
    required this.name,
    required this.id
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] as String,
      id: json['id'] as int,
    );
  }

}