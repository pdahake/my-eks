variable "cluster_name" {
  type        = string
  description = "eks cluster name"
  default     = "my-eks"
}

variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "1.28"
}