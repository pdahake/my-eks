locals {
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  account_id     = data.terraform_remote_state.vpc.outputs.account_id
  worker_subnets = data.terraform_remote_state.vpc.outputs.worker_subnets
  pod_subnets    = data.terraform_remote_state.vpc.outputs.pod_subnets
  public_subnets = data.terraform_remote_state.vpc.outputs.public_subnets
  region         = data.terraform_remote_state.vpc.outputs.region
  cluster_name   = var.cluster_name

  worker_subnet_ids = [for s in local.worker_subnets : s.id]
  pod_subnet_ids    = [for s in local.pod_subnets : s.id]
  public_subnet_ids = [for s in local.public_subnets : s.id]

  #public_ip_cidr = "${data.http.ip.response_body}/32"
  public_ip_cidr = "100.1.131.10/32"

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
}

output "vpc_id" {
  value = local.vpc_id
}

data "aws_security_group" "bastion" {
  name = "bastion"
}