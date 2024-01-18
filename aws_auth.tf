locals {
# aws_auth_roles = [
#     {
#       rolearn  = module.eks_managed_node_group.iam_role_arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#       ]
#     },
#     {
#       rolearn  = module.self_managed_node_group.iam_role_arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#       ]
#     },
#   ]
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::635066407893:role/eks-admin"
      username = "eks-admin"
      groups = [
        "system:masters"
      ]
    },      
  ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::635066407893:user/pdahake"
      username = "pdahake"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_accounts = [
    "635066407893",
  ]
  aws_auth_configmap_data = {
    mapRoles = yamlencode(local.aws_auth_roles)
    mapUsers = yamlencode(local.aws_auth_users)
    mapAccounts = yamlencode(local.aws_auth_accounts)
  }
}
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    # We are ignoring the data here since we will manage it with the resource below
    # This is only intended to be used in scenarios where the configmap does not exist
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  depends_on = [
    # Required for instances where the configmap does not exist yet to avoid race condition
    kubernetes_config_map.aws_auth,
  ]
}
