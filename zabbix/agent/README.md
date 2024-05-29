# alse17/zabbix-agent:6.0

## Назначение

Образ zabbix-agent-6.0 на базе AstraLinux SE 1.7

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
docker build --no-cache -t alse17/zabbix-agent:6.0 .
```

## Запуск

### Список базовых переменных окружения контейнера

| Имя переменной      | Описание                          | Значение по умолчанию |
|---------------------|-----------------------------------|-----------------------|
| `ZBX_SERVER_HOST`   | Адрес подключаемого zabbix server | zabbix-server         |
| `ZBX_SERVER_PORT`   | Порт подключаемого zabbix server  | 10051                 |
| `ZBX_HOSTNAME`      | Название узла zabbix agent        | zabbix-agent          |

### Запуск контейнера

```commandline
docker run -p 10050:10050 alse17/zabbix-agent:6.0
```