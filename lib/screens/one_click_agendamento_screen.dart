// lib/screens/one_click_agendamento_screen.dart

import 'package:flutter/material.dart';
import 'package:api_petvida03/models/servicos.dart';
import 'package:api_petvida03/services/api_service.dart';
import 'package:api_petvida03/models/animal.dart';
import 'package:dio/dio.dart';

class OneClickAgendamentoScreen extends StatefulWidget {
  const OneClickAgendamentoScreen({super.key});

  @override
  State<OneClickAgendamentoScreen> createState() => _OneClickAgendamentoScreenState();
}

class _OneClickAgendamentoScreenState extends State<OneClickAgendamentoScreen> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variáveis para o estado
  DateTime? _dataSelecionada;
  int? _servicoSelecionado;
  int? _animalSelecionado;
  List<String> _horariosDisponiveis = [];
  bool _isLoading = false;

  // Futures para buscar os dados dos animais e serviços
  late Future<List<Animal>> _animaisFuture;
  late Future<List<Servicos>> _servicosFuture;
  
  
  @override
  void initState() {
    super.initState();
    _animaisFuture = _apiService.getMyAnimals();
    _servicosFuture = _apiService.getServicos();
  }

  // Função para buscar e atualizar os horários
  Future<void> _fetchHorarios() async {
    if (_dataSelecionada == null || _servicoSelecionado == null) return;
    
    setState(() {
      _isLoading = true;
      _horariosDisponiveis = [];
    });

    try {
      final dataStr = _dataSelecionada!.toIso8601String().split('T')[0];
      final horarios = await _apiService.getHorariosDisponiveis(
        data: dataStr,
        servicoId: _servicoSelecionado!,
      );
      setState(() {
        _horariosDisponiveis = horarios;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar horários. Tente novamente.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para lidar com o agendamento com um clique
  void _agendar(String horario) async {
    if (_animalSelecionado == null || _servicoSelecionado == null || _dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um animal, serviço e data.')),
      );
      return;
    }

    try {
      final dataStr = _dataSelecionada!.toIso8601String().split('T')[0];
      await ApiService().agendarComUmClique(
        idAnimal: _animalSelecionado!, // Corrigido: usa a variável de estado
        idServicos: _servicoSelecionado!, // Corrigido: usa a variável de estado
        data: dataStr,
        hora: horario, // Corrigido: usa o parâmetro recebido
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento realizado com sucesso!')),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      String errorMessage = 'Erro ao agendar.';
      if (e.response?.statusCode == 400 && e.response!.data is Map) {
        final errorData = e.response!.data;
        if (errorData.containsKey('non_field_errors') && errorData['non_field_errors'] is List) {
          errorMessage = errorData['non_field_errors'][0];
        } else {
          errorMessage = errorData.values.first.toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado. Tente novamente mais tarde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamento Rápido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<List<Animal>>(
                future: _animaisFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Nenhum animal cadastrado.");
                  }
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Selecione o Animal'),
                    value: _animalSelecionado,
                    items: snapshot.data!.map((animal) {
                      return DropdownMenuItem<int>(
                        value: animal.id,
                        child: Text(animal.nome),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _animalSelecionado = newValue;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Servicos>>(
                future: _servicosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Nenhum serviço disponível.");
                  }
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Selecione o Serviço'),
                    value: _servicoSelecionado,
                    items: snapshot.data!.map((servico) {
                      return DropdownMenuItem<int>(
                        value: servico.id,
                        child: Text(servico.nomeServico),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _servicoSelecionado = newValue;
                        if (_dataSelecionada != null) {
                          _fetchHorarios();
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dataSelecionada ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dataSelecionada = pickedDate;
                    });
                    _fetchHorarios();
                  }
                },
                child: Text(_dataSelecionada == null
                    ? 'Selecione a Data'
                    : 'Data: ${_dataSelecionada!.toIso8601String().split('T')[0]}'),
              ),
              const SizedBox(height: 24),
              const Text('Horários Disponíveis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_horariosDisponiveis.isEmpty)
                const Text('Não há horários disponíveis para a data e serviço selecionados.')
              else
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _horariosDisponiveis.map((horario) {
                    return ElevatedButton(
                      onPressed: () => _agendar(horario),
                      child: Text(horario),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}