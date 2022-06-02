class CastSerie {

  String character;
  int id;
  String person;
  String image;

  CastSerie({
    required this.character,
    required this.id,
    required this.person,
    required this.image,
  });

  factory CastSerie.fromJson(Map<String, dynamic> json) {
    return CastSerie(
      character: json['character'],
      id: json['id'],
      person: json['person'],
      image: json['image'],
    );
  }

  @override
  String toString() {
    return 'Cast{character: $character, id: $id, person: $person, image: $image}';
  }

}