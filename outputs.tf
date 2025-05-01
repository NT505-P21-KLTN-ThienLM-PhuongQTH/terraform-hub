output "training_server_ip" {
  value = module.training_server.ip
  description = "Public IP của Training Server (MLflow + Airflow)"
}

# output "inference_server_ip" {
#   value = module.inference_server.inference_server_ip
#   description = "Public IP của Inference Server (FastAPI + k3s)"
# }

# output "monitoring_server_ip" {
#   value = module.monitoring_server.monitoring_server_ip
#   description = "Public IP của Monitoring Server (Prometheus + Grafana)"
# }

output "mlflow_url" {
  value = "http://${module.training_server.ip}:5000"
  description = "URL của MLflow server"
}

output "airflow_url" {
  value = "http://${module.training_server.ip}:8080"
  description = "URL của Airflow server"
}

# output "prometheus_url" {
#   value = "http://${module.monitoring_server.monitoring_server_ip}:9090"
#   description = "URL của Prometheus server"
# }
#
# output "grafana_url" {
#   value = "http://${module.monitoring_server.monitoring_server_ip}:3000"
#   description = "URL của Grafana server"
# }

output "subdomain_name" {
    value = module.subdomain_for_ec2.subdomain_name
    description = "Tên subdomain đã tạo"
}