FROM grafana/grafana:8.0.4

COPY ./datasource.yml /etc/grafana/provisioning/datasources/
COPY ./dashboard.yml /etc/grafana/provisioning/dashboards/
COPY ./dashboards/* /var/lib/grafana/dashboards/
