// lib/screens/confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:api_petvida03/models/agendamento.dart';

class ConfirmationScreen extends StatelessWidget {
  final Agendamento agendamento;

  const ConfirmationScreen({super.key, required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamento Confirmado'),
        automaticallyImplyLeading: false, // Esconde o botão de voltar padrão
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Agendamento Realizado com Sucesso!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Seu serviço foi agendado. Em breve, entraremos em contato para mais detalhes.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        icon: Icons.pets,
                        label: 'Serviço',
                        value: agendamento.nomeServico ?? 'N/A',
                      ),
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Data',
                        value:
                            '${agendamento.dataAgendamento.day}/${agendamento.dataAgendamento.month}/${agendamento.dataAgendamento.year}',
                      ),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Hora',
                        value: agendamento.horaAgendamento,
                      ),
                      if (agendamento.observacoes != null)
                        _buildDetailRow(
                          icon: Icons.notes,
                          label: 'Observações',
                          value: agendamento.observacoes!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Voltar para o Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
