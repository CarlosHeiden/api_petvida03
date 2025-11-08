// lib/models/agendamento.dart

class Agendamento {
  final int? id;
  final int idAnimal;
  final String? nomeAnimal;
  final int idServicos;
  final String? nomeServico;
  final DateTime dataAgendamento;
  final String horaAgendamento;
  final String? observacoes;
  final String? status; // <--- 1. NOVO CAMPO ADICIONADO

  Agendamento({
    this.id,
    required this.idAnimal,
    this.nomeAnimal,
    required this.idServicos,
    this.nomeServico,
    required this.dataAgendamento,
    required this.horaAgendamento,
    this.observacoes,
    this.status, // <--- 2. NOVO CAMPO NO CONSTRUTOR
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      idAnimal: json['id_animal'],
      nomeAnimal: json['nome_animal'],
      idServicos: json['id_servicos'],
      nomeServico: json['nome_servico'],
      dataAgendamento: DateTime.parse(json['data_agendamento']),
      horaAgendamento: json['hora_agendamento'],
      observacoes: json['observacoes'],
      status: json['status'], // <--- 3. LENDO O CAMPO DO JSON DO DJANGO
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_animal': idAnimal,
      'id_servicos': idServicos,
      'data_agendamento': dataAgendamento.toIso8601String().substring(0, 10),
      'hora_agendamento': horaAgendamento,
      'observacoes': observacoes,
      // O campo 'status' não precisa ir no toJson pois é um dado de resposta/leitura
    };
  }
}