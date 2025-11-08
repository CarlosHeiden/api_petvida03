// lib/models/servicos.dart
class Servicos {
  final int id;
  final String nomeServico;

  Servicos({required this.id, required this.nomeServico});

  factory Servicos.fromJson(Map<String, dynamic> json) {
    return Servicos(id: json['id'], nomeServico: json['nome_servico']);
  }
}
