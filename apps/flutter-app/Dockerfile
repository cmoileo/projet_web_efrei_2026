FROM debian:bookworm-slim AS builder
ARG FLUTTER_VERSION=3.41.0
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --branch ${FLUTTER_VERSION} --depth 1 \
    https://github.com/flutter/flutter.git /sdk/flutter
ENV PATH="/sdk/flutter/bin:$PATH"
RUN flutter config --enable-web --no-analytics && flutter precache --web
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
