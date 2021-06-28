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
