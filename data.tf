data "aws_availability_zones" "available" {
  state = "available"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = "pritam-tf-state-backend"
    key     = "my-vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "terraform"
    assume_role = {
      role_arn     = "arn:aws:iam::635066407893:role/tf-master"
      sesison_name = "terraform"
    }
  }
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "tls_certificate" "this" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}