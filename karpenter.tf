module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name = module.eks.cluster_name

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  #create_iam_role      = false
  iam_role_arn         = module.eks.eks_managed_node_groups["spot"].iam_role_arn
}

output "karpenter_role_arn" {
  value = module.karpenter.role_arn
}
output "karpenter_role_name" {
  value = module.karpenter.role_name
}
output "karpenter_irsa_arn" {
  value = module.karpenter.irsa_arn
}
output "karpenter_irsa_name" {
  description = "The name of the IAM role for service accounts"
  value       = module.karpenter.irsa_name
}
output "karpenter_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}

output "karpenter_aws_node_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}
output "karpenter_aws_node_instance_profile_arn" {
  value = module.karpenter.instance_profile_arn
}

output "karpenter_sqs_queue_name" {
  value = module.karpenter.queue_name
}
# module "eks_blueprints_addons" {
#   source = "aws-ia/eks-blueprints-addons/aws"
#   version = "~> 1.0" #ensure to update this to the latest/desired version

#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   cluster_version   = module.eks.cluster_version
#   oidc_provider_arn = module.eks.oidc_provider_arn

#   eks_addons = {
#     aws-ebs-csi-driver = {
#       most_recent = true
#     }
#     # coredns = {
#     #   most_recent = true
#     # }
#     # vpc-cni = {
#     #   most_recent = true
#     # }
#     # kube-proxy = {
#     #   most_recent = true
#     # }
#   }

#   enable_aws_load_balancer_controller    = false
#   enable_cluster_proportional_autoscaler = false
#   enable_karpenter                       = true
#   enable_kube_prometheus_stack           = false
#   enable_metrics_server                  = false
#   enable_external_dns                    = false
#   enable_cert_manager                    = false
#   #cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

#   tags = {
#     Environment = "dev"
#   }
# }