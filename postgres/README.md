# alse17/postgres:11

## Назначение

Образ postgresql-11-server на базе AstraLinux SE 1.7

## Сборка

### Список аргументов

Файл `Dockerfile` содержит в себе следующие аргументы:

| Имя аргумента    | Описание                                    | Значение по умолчанию          |
|------------------|---------------------------------------------|--------------------------------|
| `ASTRA_REGISTRY` | адрес docker-репозитория образов AstraLinux | registry.astralinux.ru         |
| `ASTRA_IMAGE`    | образ AstraLinux SE 1.7                     | library/alse:1.7.5uu1-mg12.5.0 |

Значение аргумента можно переопределить с помощью параметра `--build-arg` в командах `docker build` и `buildah bud`.

### Сборка контейнера:

```commandline
docker build --no-cache -t alse17/postgres:11 .
```

## Запуск

### Список переменных окружения контейнера

| Имя переменной         | Описание                                                                    | Значение по умолчанию                  |
|------------------------|-----------------------------------------------------------------------------|----------------------------------------|
| `POSTGRES_DB`          | Название инициализируемой базы данных                                       | postgres                               |
| `POSTGRES_USER`        | Имя пользователя-владельца базы данных                                      | postgres                               |
| `POSTGRES_PASSWORD`    | Пароль пользователя-владельца базы данных                                   |                                        |
| `POSTGRES_INITDB_ARGS` | Кастомизация параметров инициализации базы данных (например: --auth=sha256) |                                        |
| `PGPORT`               | Порт сервера postgresql                                                     | 5432                                   |
| `PGDATA`               | Директория хранения данных сервера postgresql                               | /var/lib/postgresql/data               |
| `PGUNIX`               | Путь до Unix-сокета сервера postgresql                                      | /var/run/postgresql/.s.PGSQL.${PGPORT} |

### Запуск контейнера

```commandline
docker run -p 5432:5432 -e POSTGRES_PASSWORD=password alse17/postgres:11
```