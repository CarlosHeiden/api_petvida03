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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  late Future<List<Agendamento>> _agendamentosFuture;

  static const Color _petVidaGreen = Color(0xFF03BB85);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _agendamentosFuture = _apiService.getAgendamentos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔄 Recarrega lista ao retornar para o app (inclusive via notificação)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recarregarAgendamentos();
    }
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

  // 🔁 Atualiza os agendamentos
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
            tooltip: 'Novo agendamento rápido',
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => const OneClickAgendamentoScreen(),
                ),
              )
                  .then((value) {
                if (value == true) {
                  _recarregarAgendamentos(); // Atualiza após criar novo agendamento
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar lista',
            onPressed: _recarregarAgendamentos,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Agendamento>>(
        future: _agendamentosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar agendamentos: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agendamento encontrado.',
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            final agendamentos = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                _recarregarAgendamentos();
                await _agendamentosFuture;
              },
              child: ListView.builder(
                itemCount: agendamentos.length,
                itemBuilder: (context, index) {
                  final agendamento = agendamentos[index];
                  final bool isFinalizado =
                      agendamento.status?.toLowerCase() == 'finalizado';

                  final Color cardColor =
                      isFinalizado ? Colors.grey.shade300 : _petVidaGreen;
                  final Color textColor =
                      isFinalizado ? Colors.black87 : Colors.white;

                  return Card(
                    color: cardColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.pets, color: textColor),
                      title: Text(
                        agendamento.nomeServico ?? 'Serviço Desconhecido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${agendamento.nomeAnimal} - '
                            '${agendamento.dataAgendamento.day}/${agendamento.dataAgendamento.month} '
                            'às ${agendamento.horaAgendamento}',
                            style: TextStyle(color: textColor.withOpacity(0.9)),
                          ),
                          if (isFinalizado)
                            const Text(
                              '✅ Serviço finalizado',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      trailing: isFinalizado
                          ? Icon(Icons.check_circle, color: textColor)
                          : null,
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
