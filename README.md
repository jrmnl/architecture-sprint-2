# Спринт 2

## Итоговая схема

[./task1.drawio](./task1.drawio)

## Как запустить

Переходим в папку sharding-repl-cache

```shell
cd sharding-repl-cache
```

Запускаем докер композ

```shell
docker compose up -d
```

Инициализируем приложение

```shell
./scripts/mongo-init.sh
```

## Как проверить проект на локальной машине

Откройте в браузере http://localhost:8080/docs