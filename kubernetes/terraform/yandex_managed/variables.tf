variable cloud_id {
  description = "Cloud ID"
}
variable folder_id {
  description = "Folder ID"
}
variable zone {
  description = "Zone"
  default     = "ru-central1-a"
}
variable master_count {
  description = "Count of k8s master nodes"
  default     = "1"
}
variable worker_count {
  description = "Count of k8s worker nodes"
  default     = "1"
}
variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable service_account_key_file {
  description = "key.json"
}
variable service_account_id {
  description = "service_account_id"
}
