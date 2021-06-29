# vasilij-m_microservices
vasilij-m microservices repository

### ДЗ №16. Технология контейнеризации. Введение в Docker

**Выполнено:**
1. Основное задание:
  * Инициализация хоста docker на истансе Yandex Cloud с помощью `docker-machine`
  * Запуск приложения и базы mongo в одном контейнере
  * Загрузка образа в docker hub

2. Доп. задание:
  * Объяснил отличия команд `docker inspect <u_container_id>` и `docker inspect <u_image_id>`
  * Написал плейбуки Ansible с использованием динамического инвентори (`infra/ansible/environments/stage/inventory.py`) для установки докера (`infra/ansible/playbooks/docker_install.yml`) и запуска образа приложения (`infra/ansible/playbooks/reddit_run.yml`)
  * Написал шаблон пакера (`infra/packer/ubuntu-docker.json`), который делает образ с уже установленным Docker с использованием плейбука `docker_install.yml`
  * Описал инфраструтуру в Terraform с поднятием инстансов, количество которых задается переменной. Инстансы разворачиваются на основе образа, собранного пакером


### ДЗ №17. Docker-образы. Микросервисы

**Выполнено:**
1. Основное задание:
  * Приложение разбито на 4 микросервиса/контейнера: база MongoDB, сервис post-py, сервис comment, сервис ui
  * Инструкции по сборке отпимизированы с целью уменьшения итоговых образов
  * Для сохранения данных после перезапуска контейнепров создан volume `reddit_db` и подключен к контейнеру с монгой

2. Доп. задание:
  * Запустить контейнеры с другими сетевыми алиасами:
  ```
  docker run -d --network=reddit --network-alias=post_database --network-alias=comment_database mongo:latest
  docker run -d --network=reddit --network-alias=post_service --env POST_DATABASE_HOST=post_database vasiilij/post:1.0
  docker run -d --network=reddit --network-alias=comment_service --env COMMENT_DATABASE_HOST=comment_database vasiilij/comment:1.0
  docker run -d --network=reddit --env POST_SERVICE_HOST=post_service --env COMMENT_SERVICE_HOST=comment_service -p 9292:9292 vasiilij/ui:1.0
  ```
  * Собрал образы на основе Alpine Linux для сервисов `UI` и `comment`, чем уменьшил размер образа до ~280 Mb. Инструкции по сборке - в докерфайлах `ui/Dockerfile.1` и `comment/Dockerfile.1`


### ДЗ №18. Docker: сети, docker-compose

#### Выполнено:
**1. Основное задание:**
  * Изучены варианты подключения docker-контейнеров к сети с помощью драйверов `none`, `host`, `bridge`
  * Создание кастомной сети с bridge драйвером, подключение к ней контейнеров с возможностью их обнаружения по алиасам
  * Описание и запуск сервисов с помощью docker-compose, параметризация с помощью переменных окружения, записанных в `.env` файл

Все создаваемые docker-compose сущности имеют одинаковый префикс, к примеру `dockermicroservices_ui_1`, где
`dockermicroservices` - базовое имя проекта.
***Задание:***
Узнайте как образуется базовое имя проекта. Можно ли его задать? Если можно то как?
***Ответ:***
Базовое имя проекта берется из переменной окружения `COMPOSE_PROJECT_NAME`, по дефолту её значение - имя директории, из которой запускается docker-compose. Соответственно, чтобы изменить имя проекта, нужно переопределить переменну окружения `COMPOSE_PROJECT_NAME` либо через `export`, либо в файле `.env`. Еще один способ - передать имя проекта через ключ `-p`: `docker-compose -p my_super_project up`.

**2. Доп. задание:**
  * Объяснил отличия команд `docker inspect <u_container_id>` и `docker inspect <u_image_id>`


***Вывод списка контейнеров в сети `src_back_net`с помощью утилиты `jq`:***
```
docker network inspect src_back_net | jq '.[] | .Containers | .[] | .Name'
```
