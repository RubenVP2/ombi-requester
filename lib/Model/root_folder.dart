class RootFolder {

  final int id;
  final String path;

  RootFolder({
    required this.id,
    required this.path,
  });

  factory RootFolder.fromJson(Map<String, dynamic> json) {
    return RootFolder(
      id: json['id'],
      path: json['path'],
    );
  }

  @override
  String toString() {
    return 'RootFolder{id: $id, path: $path}';
  }
}