// lib/models/animal.dart
class Animal {
  final int id;
  final String nome;

  Animal({required this.id, required this.nome});

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      nome: json['nome'],
    );
  }
}