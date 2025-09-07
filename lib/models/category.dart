class Category {
  final int? id;
  final String type; // e.g., 'income' or 'expense'
  final String name;

  Category({this.id, required this.type, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type, 'name': name};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(id: map['id'], type: map['type'], name: map['name']);
  }

  @override
  String toString() {
    return 'Category{id: $id, type: $type, name: $name}';
  }
}
