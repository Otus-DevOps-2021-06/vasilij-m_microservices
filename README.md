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
Создал файл `docker-compose.override.yml` для reddit проекта, который позволяет:
* Изменять код каждого из приложений, не выполняя сборку образа
* Запускать puma для руби приложений в дебаг режиме с двумя воркерами (флаги --debug и -w 2)

По дефолту Compose читает два файла: `docker-compose.yml` и, если есть, `docker-compose.override.yml`. Обычно в `docker-compose.yml` описана базовая конфиуграция проекта, а файл `docker-compose.override.yml` либо дополняет, либо изменяет её.


***! Вывод списка контейнеров в сети `src_back_net`с помощью утилиты `jq`:***
```
docker network inspect src_back_net | jq '.[] | .Containers | .[] | .Name'
```


### ДЗ №22. Введение в мониторинг. Системы мониторинга.

#### Выполнено:
**1. Основное задание:**
  * Prometheus: запуск, конфигурация, знакомство с Web UI. Написан docker-compose файл (файл `docker/docker-compose.yml`), который поднимает контейнеры с микросервисами приложения, контейнер с Prometheus, а также контейнеры с экспортерами: node-exporter, mongodb-exporter, blackbox-exporter
  * Мониторинг состояния микросервисов. Сбор метрик описан в файле `monitoring/prometheus/prometheus.yml`
  * Сбор метрик хоста с использованием экспортера node-exporter

**2. Доп. задание:**
  * Добавлен мониторинг MongoDB с использованием экспортера mongodb экспортера от bitnami
  * Добавлен мониторинг сервисов comment, post, ui с помощью blackbox экспортера
  * Напишсан Makefile (в корне репозитория), который билдит образы prometheus, а также микросервисов comment post, ui, и пушит их в докер хаб

### ДЗ №23. Мониторинг приложения и инфраструктуры

***Скорость увеличения счетчика http ошибок за 1-минутный интервал:***
```
rate(ui_request_count{http_status=~"^[45].*"}[1m])
```
***Используйте для первого графика (UI http requests) функцию rate аналогично второму графику (Rate of UI HTTP Requests with Error):***
```
rate(ui_request_count[1m])
```
***95й процентиль времени обработки запросов с помощью функции histogram_quantile():***
```
histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m])) by (le))
```

#### Выполнено:

**Основное задание:**
  * Описание сервисов для мониторинга вынесено в отдельный файл для docker compose'а: `docker/docker-compose-monitoring.yml`
  * Реализована визуализация метрик с помощью Grafana, используемые в ДЗ дашборды экспортированы в `monitoring/grafana/dashboards`
  * Настроен Alertmanager для отправки уведомлений в Slack. При попытке подключить Alertmanager к своему каналу в workspace'е DevOps team я столкнулся с ошибкой ограничения возможных подключений в 10 штук, поэтому создал свой собственный workspace.

**Доп. задание \*, 1:**

В Makefile добавил билд и публикацию сервисов Alertmanager, Telegraf и Grafana

**Доп. задание \*, 2:**

Активировал отдачу метрик docker (документация: https://docs.docker.com/config/daemon/prometheus/), в графану подключил дашборд Docker_Engine_Metrics (`monitoring/grafana/dashboards/Docker_Engine_Metrics.json):

Добавил следующую конфигурацию в файл `/etc/docker/daemon.json` на docker хосте:
```
{
  "metrics-addr" : "0.0.0.0:9323",
  "experimental" : true
}
```
В `prometheus.yml` добавил джобу, в качестве таргета указал ip адрес bridge-интерфейса docker0:
```
- job_name: 'docker'
  static_configs:
  - targets:
    - '172.17.0.1:9323'
```
***Сравнение количества метрик с Cadvisor:***
Количество метрик Docker - 452:
```
yc-user@docker-host:~$ curl -s localhost:9323/metrics | grep -v "^#" | wc -l
452
```
Количество метрик Cadvisor - 3044:
```
yc-user@docker-host:~$ curl -s localhost:8080/metrics | grep -v "^#" | wc -l
3044
```
**Доп. задание \*, 3:**

Добавил сбор метрик с Docker демона в Prometheus с помощью Telegraf. Конфиг телеграфа: `telegraf/telegraf.conf`
Дашборд для графаны: `monitoring/grafana/dashboards/Telegraf_Docker_Metrics.json`

***Сравнение количества метрик с Cadvisor:***
Количество метрик Telegraf - 903:
```
yc-user@docker-host:~$ curl -s localhost:9273/metrics | grep -v "^#" | wc -l
903
```
Количество метрик Cadvisor - 3044:
```
yc-user@docker-host:~$ curl -s localhost:8080/metrics | grep -v "^#" | wc -l
3044
```

**Доп. задание \*\*, 1:**

Реализовал автоматическое добавление источника данных и созданных в данном ДЗ дашбордов в графану.
Файл с конфигом истоника данных: `grafana/datasource.yml`
Файл с конфигом дашбордов: `grafana/dashboard.yml`

В графане получал ошибку `Datasource named ${DS_PROMETHEUS} was not found`, решение описано здесь: https://github.com/grafana/grafana/issues/10786#issuecomment-568788499


### ДЗ №25. Логирование и распределенная трассировка

#### Выполнено:
**1. Основное задание:**
  * Поднята система логирования docker контейнеров на базе EFK
  * Во Fluentd добавлены grok-фильтры для структурирования логов сервиса ui
  * Осуществлен распределенный трейсинг с помощью Zipkin

**2. Доп. задание:**
  * Составлена конфигурация Fluentd так, чтобы разбирались оба формата логов UI-сервиса одновременно
  * Выполнен траблшутинг UI-экспириенса, ошибки исправлены:

С помощью логов в Kibana исправил ошибку, по которой не подгружались посты. В коде приложения `post_app.py` на 53й строке: было - `body = '\x0c\x00\x00\x00\x01' + encoded_span`, исправленный вариант - `body = b'\x0c\x00\x00\x00\x01' + encoded_span`.

С помощью трейсов в Zipkin исправил ошибку долгой загрузки поста. Причина была в функции `find_post()`, в строке 167 указана задержка в 3 секунды: `time.sleep(3)`.


### ДЗ №27. Введение в kubernetes

#### Выполнено:
**1. Основное задание:**
  * Описал приложение в контексте Kubernetes с помощью manifestов в YAML-формате, файлы манифестов находятся в `kubernetes/reddit`
  * Кластер kubernetes установлен на двух нодах (1 master, 1 worker)
  * Установлен Calico Network Plugin для обеспечения сетевого взаимодействия в кластере k8s

**2. Доп. задание \*\*:**
  * Установка кластера k8s описана с помощью terraform и ansible. Файлы terraform для поднятия одной машины для control plane и второй для worker'а находятся в `kebernetes/terraform`. Инвентори, роли и плейбуки для установки k8s находятся в `kubernetes/ansible`

### ДЗ №28. Kubernetes. Запуск кластера и приложения. Модель безопасности

#### Выполнено:
**1. Основное задание:**
  * Развернул кластер Kubernetes локально с помощью Minikube
  * Описал приложение reddit и объекты типа Service в YAML-манифестах и запустил его
  * Запустил приложение в dev namespace'е
  * Развернул кластер Kubernetes в платформе Yandex Cloud Managed Service for kubernetes и задеплоил туда наше приложение

**2. Доп. задание \*\*:**
  * Развернул Kubernetes-кластер в Yandex cloud с помощью Terraform. Файлы terraform расположены в `kubernetes/terraform/yandex_managed`
  * Создал YAML-манифесты для включения Web UI (Dashboard). Файлы манифестов расположены в `kubernetes/dashboard`

Документация по деплою дашборда: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

Доступ в дашборд возможен только при предъявлении токена. Токен выписывается на юзера, поэтому сначала нужно создать юзера, документация: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

Токен, полученный на юзера, можно посмотреть следующим образом:

1. Вывести список сервис-акканутовв нэймспейсе `kubernetes-dashboard`:

```
$ kubectl get serviceaccounts --namespace kubernetes-dashboard
NAME                   SECRETS   AGE
admin-user             1         5m12s
default                1         29m
kubernetes-dashboard   1         29m
```
2. Просмотреть юзера `admin-user`, которого мы создали ранее:

```
$ kubectl describe secret admin-user --namespace kubernetes-dashboard
Name:         admin-user-token-qcmft
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: 8e8d5f8a-c0dc-43b3-bc61-3bdd7189a4b9

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1066 bytes
namespace:  20 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6Ijh2N2hIZ2J3QUlwU1dzc0lvVVVrQk1GbU1tQkVvYldmY3B3X3ZxNHp6azAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLXFjbWZ0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4ZThkNWY4YS1jMGRjLTQzYjMtYmM2MS0zYmRkNzE4OWE0YjkiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.ebnzDe2MoOj_NqiaqKSATBrs0eRkpxpB-So7BfijDW98BDfoI7osE9tjVtsNb9q9ftAPI31WxDk5tipTPqJpStJOCJ8o0VGVvZlx7ZdJNdAJ9Sqk19SIwH6G0r-dyKtS66a7z7mZQzjfn9jLV-yLsc8-pB5O9rOj8gfb_yDGiTgqiMtIcgIFl9iae2p5LstTqMAy3L1hR_ByHVkj5uq6UxQNJCddF55wzUS7zBYPTuOsi9MtAKnMuV8jOIbH1yPMBVpVcOlifY8VfV2CNnSfBujBdlKG7Y8XZ3l-4KKmdelPCxiLNcFaGp8P6b2p0FjAEsNlqSU2OlImnD6FYEO2iA
```

Для доступа в дашборд нужно выполнить команду `kubectl proxy`, открыть дашборд по ссылке http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ и выполнить вход с помощью токена.


### ДЗ №29. Kubernetes. Networks, Storages.

#### Выполнено:
**1. Основное задание:**
  * Настроил доступ к приложению из вне с помощью load balancer'а Yandex'а
  * Заменил load balancer'а Yandex'а на ingress controller с nginx в качестве балансировщика
  * Создал ingress, добавил в него поддержку tls
  * Создал Network Policy для ограничения входящего траффика к сервису mongodb
  * Создал хранилище для базы на основе PersistentVolume

**2. Доп. задание \*:**
  * Описал объект Secret для хранения tls.key и tls.crt в виде Kubernetes-манифеста: `kubernetes/reddit/ui-ingress-secret.yml`
