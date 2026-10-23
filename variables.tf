variable "vpc_cidr" {
  description = "IPv4 address range for the 19thoct VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ---------- Docker hosts (Kenneth) ----------
variable "docker_instance_type" {
  description = "EC2 instance type for the Docker hosts"
  type        = string
  default     = "t2.medium"
}

variable "docker_min_size" {
  description = "Minimum number of Docker hosts"
  type        = number
  default     = 1
}

variable "docker_desired_capacity" {
  description = "Normal number of Docker hosts, one per availability zone"
  type        = number
  default     = 2
}

variable "docker_max_size" {
  description = "Maximum number of Docker hosts during traffic spikes"
  type        = number
  default     = 3
}

# ---------- BankApp domain and load balancer (Kenneth) ----------
variable "app_subdomain" {
  description = "Subdomain of everythingops.io for the BankApp, e.g. bankapp -> bankapp.everythingops.io"
  type        = string
  default     = "bankapp"
}

variable "app_health_check_path" {
  description = "Path the load balancer calls on each Docker host to check the app is healthy"
  type        = string
  default     = "/"
}
