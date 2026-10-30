# Servidor de FramBitácora: imagen pequeña con el ejecutable compilado.
FROM dart:3.13 AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o /app/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/server
ENV PHOTOS_DIR=/data/fotos PORT=8080
EXPOSE 8080
CMD ["/app/server"]
