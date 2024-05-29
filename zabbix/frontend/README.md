# alse17/zabbix-frontend-unit-pgsql:6.0

## Назначение

Образ zabbix-frontend-6.0 на базе веб-сервера Nginx Unit c поддержкой PostgreSQL на базе AstraLinux SE 1.7

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
docker build --no-cache -t alse17/zabbix-frontend-unit-pgsql:6.0 .
```

## Запуск

### Список переменных окружения контейнера

| Имя переменной      | Описание                                                 | Значение по умолчанию |
|---------------------|----------------------------------------------------------|-----------------------|
| `DB_SERVER_HOST`    | Хост сервера postgresql                                  | postgres              |
| `DB_SERVER_PORT`    | Порт сервера postgresql                                  | 5432                  |
| `POSTGRES_DB`       | Название базы данных postgresql                          | zabbix                |
| `POSTGRES_USER`     | Пользователь базы данных postgresql                      | zabbix                |  
| `POSTGRES_PASSWORD` | Пароль пользователя базы данных postgresql               | zabbix                |
| `ZBX_SERVER_HOST`   | Адрес подключаемого zabbix сервера                       | zabbix-server         |
| `ZBX_SERVER_PORT`   | Порт подключаемого zabbix сервера                        | 10051                 |
| `ZBX_SERVER_NAME`   | Имя подключаемого zabbix сервера (фактически имя агента) | zabbix-agent          |

### Запуск контейнера

```commandline
docker run -p 8080:8080 alse17/zabbix-frontend-unit-pgsql:6.0
```