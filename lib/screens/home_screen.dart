import 'package:flutter/material.dart';
import 'package:api_petvida03/models/agendamento.dart';
import 'package:api_petvida03/services/api_service.dart';
import 'package:api_petvida03/screens/login_screen.dart';
import 'package:api_petvida03/screens/one_click_agendamento_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Agendamento>> _agendamentosFuture;

  static const Color _petVidaGreen = Color(0xFF03bb85);

  @override
  void initState() {
    super.initState();
    _agendamentosFuture = _apiService.getAgendamentos();
  }

  void _logout() async {
    await _apiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Recarrega lista de agendamentos
  void _recarregarAgendamentos() {
    setState(() {
      _agendamentosFuture = _apiService.getAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OneClickAgendamentoScreen(),
                ),
              ).then((value) {
                if (value == true) {
                  _recarregarAgendamentos(); // Atualiza após novo agendamento
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recarregarAgendamentos,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _agendamentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar agendamentos: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agendamento encontrado.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                _recarregarAgendamentos();
                await _agendamentosFuture;
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final agendamento = snapshot.data![index];

                  final bool isFinalizado =
                      agendamento.status?.toLowerCase() == 'finalizado';

                  final Color cardColor =
                      isFinalizado ? Colors.grey.shade300 : _petVidaGreen;
                  final Color textColor =
                      isFinalizado ? Colors.black87 : Colors.white;

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.pets, color: textColor),
                      title: Text(
                        agendamento.nomeServico ?? 'Serviço Desconhecido',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: textColor),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${agendamento.nomeAnimal} - ${agendamento.dataAgendamento.day}/${agendamento.dataAgendamento.month} às ${agendamento.horaAgendamento}',
                            style: TextStyle(color: textColor.withOpacity(0.8)),
                          ),
                          if (isFinalizado)
                            Text(
                              '✅ Serviço finalizado',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                      trailing:
                          isFinalizado ? Icon(Icons.check_circle, color: textColor) : null,
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
