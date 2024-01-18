locals {
  vpc_id         = data.terraform_remote_state.vpc.outputs.vpc_id
  account_id     = data.terraform_remote_state.vpc.outputs.account_id
  worker_subnets = data.terraform_remote_state.vpc.outputs.worker_subnets
  pod_subnets    = data.terraform_remote_state.vpc.outputs.pod_subnets
  public_subnets = data.terraform_remote_state.vpc.outputs.public_subnets
  cluster_name   = data.terraform_remote_state.vpc.outputs.eks_cluster_name
  region         = data.terraform_remote_state.vpc.outputs.region

  worker_subnet_ids = [for s in local.worker_subnets : s.id]
  pod_subnet_ids    = [for s in local.pod_subnets : s.id]
  public_subnet_ids = [for s in local.public_subnets : s.id]

  cluster_endpoint                   = try(aws_eks_cluster.eks.endpoint, null)
  cluster_certificate_authority_data = try(aws_eks_cluster.eks.certificate_authority[0].data, null)
}

output "vpc_id" {
  value = local.vpc_id
}