module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    # coredns = {
    #   most_recent = true
    # }
    # vpc-cni = {
    #   most_recent = true
    # }
    # kube-proxy = {
    #   most_recent = true
    # }
  }

  enable_aws_load_balancer_controller    = false
  enable_cluster_proportional_autoscaler = false
  enable_karpenter                       = true
  enable_kube_prometheus_stack           = false
  enable_metrics_server                  = false
  enable_external_dns                    = false
  enable_cert_manager                    = false
  #cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
}