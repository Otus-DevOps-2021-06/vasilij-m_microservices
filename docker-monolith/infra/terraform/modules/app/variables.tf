variable public_key_path {
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
variable disk_image {
  description = "Disk image for reddit app"
}
variable subnet_id {
  description = "Subnet for modules"
}
variable instance_count {
  description = "Count of instance for running reddit application"
  default     = "1"
}
