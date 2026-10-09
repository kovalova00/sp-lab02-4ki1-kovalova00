# Етап 1: Збірка
FROM rust:latest AS build
WORKDIR /app

# Копіюємо маніфест і код
COPY Cargo.toml ./
COPY src ./src

# Компілюємо
RUN cargo build --release

# Етап 2: Фінальний мінімальний образ
FROM debian:12-slim
WORKDIR /app

# Копіюємо ТІЛЬКИ готовий бінарник з етапу build
COPY --from=build /app/target/release/vtfk-sid /app/vtfk-sid

# Запускаємо
CMD ["./vtfk-sid"]