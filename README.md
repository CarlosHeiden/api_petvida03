# PetVida App - Flutter + Django

Aplicativo móvel para gerenciamento de serviços de clínica veterinária, com backend Django e notificações push via Firebase Cloud Messaging (FCM).

---

## 📝 Descrição do Projeto

O PetVida App permite que clientes agendem serviços, visualizem horários disponíveis, acompanhem seus agendamentos e recebam notificações em tempo real.  
O backend é implementado em **Django REST Framework**, enquanto o frontend é feito em **Flutter** para dispositivos Android.

O projeto integra:

- Registro e login de usuários.
- CRUD de animais vinculados aos usuários.
- Agendamento de serviços com horários disponíveis.
- Notificações push via **Firebase Cloud Messaging (FCM)**.
- Controle de token FCM no backend.

---

## ⚙️ Estrutura do Projeto

### Backend (Django)

- API REST com endpoints para:
  - `/api/servicos/` → lista serviços disponíveis.
  - `/api/horarios-disponiveis/` → horários livres para cada serviço.
  - `/api/agendar_servico/` → cria agendamento.
  - `/api/agendamentos/` → lista agendamentos por usuário.
  - `/finalizar-agendamento/<id>/` → finaliza agendamento e envia notificação FCM.
  - `/api/save_fcm_token/` → registra token FCM do usuário.
- **Notificações push**:
  - Função `send_push_notification(fcm_token, title, body, data)` em `clinica/utils.py`.
  - Integração com Firebase Admin SDK.

### Frontend (Flutter)

- Serviços:
  - `ApiService` → faz login, salva token FCM, requisita permissões.
  - `FCMService` → inicializa FCM, envia token ao Django e escuta mensagens.
- Notificações:
  - Recebimento em **foreground** e **background**.
  - Exibição de mensagem no rodapé ou na tela principal.

### Configurações sensíveis

- **Firebase**:
  - `android/app/google-services.json` (Android)
  - `ios/Runner/GoogleService-Info.plist` (iOS)
- **Git**: estes arquivos **não devem ser commitados** (inseridos no `.gitignore`).

