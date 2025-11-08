// lib/screens/agendamento_screen.dart
import 'package:dio/dio.dart'; 
import 'package:flutter/material.dart';
import 'package:api_petvida03/models/animal.dart';
import 'package:api_petvida03/models/servicos.dart';
import 'package:api_petvida03/services/api_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  // Variáveis para armazenar as seleções do usuário.
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _observacoesController = TextEditingController();

  // Variáveis para o estado do formulário
  int? _animalSelecionado;
  int? _servicoSelecionado;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;

  // Futures para buscar os dados dos animais e serviços
  late Future<List<Animal>> _animaisFuture;
  late Future<List<Servicos>> _servicosFuture;

  @override
  void initState() {
    super.initState();
    // Use a nova função para obter os animais do cache
    _animaisFuture = _apiService.getMyAnimals();
    _servicosFuture = _apiService.getServicos();
  }

  // Função para selecionar a data.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  // Função para selecionar a hora.
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _horaSelecionada) {
      setState(() {
        _horaSelecionada = picked;
      });
    }
  }

  // Função para lidar com o envio do agendamento.
void _submitAgendamento() async {
  if (_formKey.currentState!.validate()) {
    if (_dataSelecionada == null || _horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma data e uma hora.')),
      );
      return;
    }

    final agendamentoData = {
      'id_animal': _animalSelecionado,
      'id_servicos': _servicoSelecionado,
      'data_agendamento': _dataSelecionada!.toIso8601String().split('T')[0],
      'hora_agendamento': '${_horaSelecionada!.hour.toString().padLeft(2, '0')}:${_horaSelecionada!.minute.toString().padLeft(2, '0')}',
      'observacoes': _observacoesController.text,
    };

    try {
      await _apiService.createAgendamento(agendamentoData);
      
      // --- MUDANÇA CRÍTICA AQUI ---
      // Esta parte do código só será executada se a API retornar 200/201.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento criado com sucesso!')),
      );
      Navigator.pop(context, true);
      
    } catch (e) {
      // O bloco catch já lida com todos os erros (incluindo o 400).
      String errorMessage = 'Erro ao criar agendamento.';
      
      // ... (sua lógica de tratamento de erro DioException, que já está correta) ...
      if (e is DioException && e.response?.statusCode == 400) {
        if (e.response?.data != null && e.response!.data is Map) {
          final errorData = e.response!.data;
          if (errorData.containsKey('non_field_errors') && errorData['non_field_errors'] is List) {
            errorMessage = errorData['non_field_errors'][0];
          } else {
            errorMessage = errorData.values.first.toString();
          }
        }
      } else {
        print('Erro inesperado: $e');
        errorMessage = 'Erro inesperado. Tente novamente mais tarde.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown para selecionar o animal
              FutureBuilder<List<Animal>>(
                future: _animaisFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Text("Nenhum animal cadastrado.");
                    }
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Selecione o Animal', border: OutlineInputBorder()),
                      value: _animalSelecionado,
                      items: snapshot.data!.map((animal) {
                        return DropdownMenuItem<int>(
                          value: animal.id,
                          child: Text(animal.nome),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _animalSelecionado = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecione um animal.' : null,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              // Dropdown para selecionar o serviço
              FutureBuilder<List<Servicos>>(
                future: _servicosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Text("Nenhum serviço disponível.");
                    }
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Selecione o Serviço', border: OutlineInputBorder()),
                      value: _servicoSelecionado,
                      items: snapshot.data!.map((servico) {
                        return DropdownMenuItem<int>(
                          value: servico.id,
                          child: Text(servico.nomeServico),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _servicoSelecionado = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Selecione um serviço.' : null,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              // Campo de data
              ListTile(
                title: const Text('Data do Agendamento'),
                subtitle: Text(
                  _dataSelecionada == null ? 'Nenhuma data selecionada' : _dataSelecionada!.toString().split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              // Campo de hora
              ListTile(
                title: const Text('Hora do Agendamento'),
                subtitle: Text(
                  _horaSelecionada == null ? 'Nenhum horário selecionado' : _horaSelecionada!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              // Campo de observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Ex: O animal é agitado',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // Botão para salvar
              ElevatedButton(
                onPressed: _submitAgendamento,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Agendar Serviço'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
