docker images | grep lab02

lab02-naive:latest   7312685042aa       2.36GB          605MB        
lab02-slim:latest    a850dd9ed0ea        114MB         28.4MB      

docker run --rm lab02-slim

Ядро С.І.Д. активне!

docker history lab02-naive

IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
7312685042aa   6 minutes ago   CMD ["/bin/sh" "-c" "[\"./target/release/vtf…   0B        buildkit.dockerfile.v0
<missing>      6 minutes ago   RUN /bin/sh -c cargo build --release # build…   573kB     buildkit.dockerfile.v0
<missing>      6 minutes ago   COPY . . # buildkit                             13.6MB    buildkit.dockerfile.v0
<missing>      6 minutes ago   WORKDIR /app                                    8.19kB    buildkit.dockerfile.v0
<missing>      3 days ago      RUN /bin/sh -c set -eux;         arch="$(dpk…   643MB     buildkit.dockerfile.v0
<missing>      3 days ago      ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME…   0B        buildkit.dockerfile.v0
<missing>      3 days ago      LABEL org.opencontainers.image.source=https:…   0B        buildkit.dockerfile.v0
<missing>      3 days ago      RUN /bin/sh -c set -ex;  apt-get update;  ap…   695MB     buildkit.dockerfile.v0
<missing>      3 days ago      RUN /bin/sh -c set -eux;  apt-get update;  a…   202MB     buildkit.dockerfile.v0
<missing>      3 days ago      RUN /bin/sh -c set -eux;  apt-get update;  a…   65MB      buildkit.dockerfile.v0
<missing>      4 days ago      # debian.sh --arch 'amd64' out/ 'trixie' '@1…   134MB     debuerreotype 0.17

docker history lab02-slim

IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
a850dd9ed0ea   5 minutes ago   CMD ["./vtfk-sid"]                              0B        buildkit.dockerfile.v0
<missing>      5 minutes ago   COPY /app/target/release/vtfk-sid /app/vtfk-…   455kB     buildkit.dockerfile.v0
<missing>      5 minutes ago   WORKDIR /app                                    8.19kB    buildkit.dockerfile.v0
<missing>      4 days ago      # debian.sh --arch 'amd64' out/ 'bookworm' '…   85.3MB    debuerreotype 0.17

Контрольні питання 
1. Чому проміжний build-етап не впливає на розмір фінального образу при багатоетапній збірці?
Бо у фінал копіюється лише результат (COPY --from=build), а весь toolchain залишається у проміжному образі, який Docker викидає.

2. Що станеться з кешем усіх наступних шарів, якщо змінити файл, скопійований у першому COPY?
Кеш усіх наступних шарів інвалідується. Docker кешує по ланцюжку: змінився один шар — перезбираються всі наступні.

3. Чому копіювання Cargo.toml/package.json окремим кроком до копіювання всього коду покращує кешування?
Бо Cargo.toml змінюється рідко. Спочатку копіюємо маніфест → залежності кешуються → зміна коду в src/ не перезбирає залежності.

4. Чому в scratch-образ не можна помістити динамічно злінкований бінарник без додаткових бібліотек?
У scratch немає libc і динамічного лінкера. Динамічний бінарник не запуститься без системних бібліотек. Потрібен статично злінкований.

5. Які інструкції Dockerfile створюють новий шар файлової системи, а які — лише метадані?
Створюють шар: RUN, COPY, ADD. Тільки метадані: FROM, WORKDIR, ENV, ARG, LABEL, USER, EXPOSE, VOLUME, CMD, ENTRYPOINT.

6. Як docker history допомагає знайти, яка саме інструкція додала найбільше мегабайтів до образу?
docker history показує SIZE кожного шару. Шукаєш найбільше число — бачиш у CREATED BY, яка інструкція винна.

7. Навіщо потрібен .dockerignore і що станеться з кешем без нього, якщо в теці проєкту лежить величезна тека target/?
.dockerignore виключає зайве з контексту. Без нього target/ тягнеться у збірку і будь-яка зміна в ній інвалідує кеш COPY . ..

8. Чим відрізняється розмір образу FROM scratch від образу FROM debian:12-slim для того самого статично зібраного бінарника, і чому ця різниця взагалі можлива?
scratch = розмір бінарника (кілька MB), debian:12-slim = ~85 MB + бінарник. Різниця можлива, бо статичний бінарник не потребує системних бібліотек Debian.