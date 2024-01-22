module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = local.vpc_id
  subnet_ids = concat(local.worker_subnet_ids, local.public_subnet_ids)
  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
          env = {
            # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
            ENABLE_PREFIX_DELEGATION = "true"
            WARM_PREFIX_TARGET       = "1"
          }
        })      
    }
  }
  enable_irsa = true
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  create_kms_key = false
  cluster_encryption_config = ""
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }    
    ingress_ec2_tcp = {
      description                = "Access EKS from EC2 instance."
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_security_group_id   = data.aws_security_group.bastion.id
    }    
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Test: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2319
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 22
      to_port                  = 22
      type                     = "ingress"
      source_security_group_id = data.aws_security_group.bastion.id
    }
  }
  
  eks_managed_node_group_defaults = {
    disk_size = 20
  }

  eks_managed_node_groups = {
    # general = {
    #   desired_size = 1
    #   min_size     = 1
    #   max_size     = 10

    #   labels = {
    #     role = "general"
    #   }

    #   instance_types = ["t3.small"]
    #   capacity_type  = "ON_DEMAND"
    # }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "spot"
      }

      # taints = [{
      #   key    = "market"
      #   value  = "spot"
      #   effect = "NO_SCHEDULE"
      # }]

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }
  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
  tags = {
    Name = var.cluster_name
    Version = var.k8s_version
    Environment = var.environment
  }
}
