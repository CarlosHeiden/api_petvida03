// lib/services/fcm_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/constants.dart';

class FCMService {
  // 🔧 Configurações locais
  //static const String djangoBaseUrl = "http://201.35.251.181:8000/api";
  //static const String saveTokenEndpoint = "/save_fcm_token/";
  static String djangoAuthToken = ""; // será definido dinamicamente

  // 🚀 Inicializa o FCM e envia o token ao Django
  static Future<void> initializeFCM({required String authToken}) async {
    try {
      // ✅ Atribui o token do usuário logado
      djangoAuthToken = authToken;

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Solicita permissão (principalmente para iOS)
      final settings = await messaging.requestPermission();
      print("🔔 Permissão para notificações: ${settings.authorizationStatus}");

      // Obtém o token FCM
      final fcmToken = await messaging.getToken();
      print("📱 Token FCM gerado: $fcmToken");

      if (fcmToken != null && djangoAuthToken.isNotEmpty) {
        await sendTokenToDjango(fcmToken);
      } else {
        print("⚠️ Token FCM ou authToken não disponível. (fcmToken=$fcmToken, authToken=$djangoAuthToken)");
      }

      // Ouve mudanças no token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print("♻️ Novo token FCM gerado: $newToken");
        if (djangoAuthToken.isNotEmpty) {
          sendTokenToDjango(newToken);
        }
      });

      // Escuta mensagens recebidas com o app em primeiro plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📨 Mensagem recebida (foreground): ${message.notification?.title}");
      });

    } catch (e) {
      print("❌ Erro ao inicializar FCM: $e");
    }
  }

  // 📤 Envia o token ao Django
  static Future<void> sendTokenToDjango(String fcmToken) async {
    final url = Uri.parse("$API_BASE_URL$SAVE_FCM_TOKEN_ENDPOINT");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $djangoAuthToken",
        },
        body: jsonEncode({"fcm_token": fcmToken}),
      );

      if (response.statusCode == 200) {
        print("✅ Token FCM salvo no Django com sucesso!");
      } else {
        print("⚠️ Falha ao salvar token FCM: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Erro ao enviar token FCM: $e");
    }
  }
}
