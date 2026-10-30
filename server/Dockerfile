# Servidor de FramBitácora con la versión web incluida.
# Construir desde la raíz del repositorio:
#   docker build -f server/Dockerfile -t frambitacora-server .

# 1. Versión web de la app.
FROM ghcr.io/cirruslabs/flutter:3.47.9 AS web
WORKDIR /src
COPY server/pubspec.* server/
COPY app/ app/
RUN cd app && flutter pub get && flutter build web --release --no-web-resources-cdn --no-wasm-dry-run

# 2. Servidor compilado.
FROM dart:3.13 AS server
WORKDIR /src/server
COPY server/pubspec.* ./
RUN dart pub get
COPY server/ ./
RUN dart compile exe bin/server.dart -o /server

# 3. Imagen final mínima.
FROM scratch
COPY --from=server /runtime/ /
COPY --from=server /server /app/server
COPY --from=web /src/app/build/web /app/web
ENV PHOTOS_DIR=/data/fotos WEB_DIR=/app/web PORT=8080
EXPOSE 8080
CMD ["/app/server"]
