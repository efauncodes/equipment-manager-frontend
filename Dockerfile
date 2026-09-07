# Flutter is pinned to a published SDK image so local and CI builds use the
# same toolchain. Update this tag deliberately when upgrading Flutter.
FROM ghcr.io/cirruslabs/flutter:3.47.2 AS build

WORKDIR /src

COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=http://localhost:8081
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.27-alpine AS runtime

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /src/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O - http://127.0.0.1/healthz | grep -q '^ok$'
