class Cast {

  String character;
  int id;
  String name;
  String profilePath;

  Cast({
    required this.character,
    required this.id,
    required this.name,
    required this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      character: json['character'],
      id: json['id'],
      name: json['name'],
      profilePath: json['profile_path'],
    );
  }

  @override
  String toString() {
    return 'Cast{character: $character, id: $id, name: $name, profile_path: $profilePath}';
  }

}