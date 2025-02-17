class UserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  // Convertește un Map<String, dynamic> într-un obiect UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  // Convertește obiectul UserModel într-un Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_url': imageUrl,
      'name_lowercase': name.toLowerCase(), // Necesar pentru căutare
    };
  }

  // Creează o copie a obiectului cu posibilitatea de a modifica anumite câmpuri
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, imageUrl: $imageUrl)';
  }
}
