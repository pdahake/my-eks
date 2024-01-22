variable "cluster_name" {
  type        = string
  description = "eks cluster name"
  default     = "my-eks2"
}

variable "k8s_version" {
  type        = string
  description = "k8s version"
  default     = "1.28"
}

variable "environment" {
  type        = string
  description = "k8s environment"
  default     = "test"
}

variable "role_arn" {
  type        = string
  description = "kubeconfig role"
  default     = "arn:aws:iam::635066407893:role/tf-master"
}