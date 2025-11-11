# ==============================
# 1️⃣ Etapa de Build (Flutter)
# ==============================
FROM ghcr.io/cirruslabs/flutter:3.29.1 AS build
# Esta imagem já contém Dart 3.8.1 — compatível com seu pubspec.yaml

# Define diretório de trabalho dentro do container
WORKDIR /app

# Copia o conteúdo do projeto Flutter para o container
COPY . .

# Substitui a URL base da API dinamicamente (vinda de --build-arg)
ARG API_URL
RUN sed -i "s|http://localhost:8000/api/|${API_URL}|g" lib/services/api_service.dart

# ✅ Ativa o suporte ao Flutter Web sem tentar atualizar o SDK
RUN flutter channel stable && flutter config --enable-web

# Baixa dependências e faz o build do app Flutter Web
RUN flutter pub get
RUN flutter build web --release

# ==============================
# 2️⃣ Etapa de Deploy (Nginx)
# ==============================
FROM nginx:stable-alpine

# Remove os arquivos padrão do Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copia o build gerado para o servidor web
COPY --from=build /app/build/web /usr/share/nginx/html

# Exposição da porta
EXPOSE 80

# Comando padrão para iniciar o servidor
CMD ["nginx", "-g", "daemon off;"]
