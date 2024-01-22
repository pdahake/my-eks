resource "null_resource" "az_subnet_daemonset_vars" {
  depends_on = [
    // Needs the VPC CNI installed to update its change
    module.eks
    #aws_eks_addon.vpc_cni,
    // Needs this security group rule to exist to gain access to the api
    #aws_security_group_rule.control_plane
  ]
  triggers = {
    aws_region   = local.region
    cluster_name = local.cluster_name
    role_arn = var.role_arn
  }
  provisioner "local-exec" {
    command = <<-EOT
        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME --role-arn $ROLE_ARN --kubeconfig kubeconfig.yaml --profile default
        export KUBECONFIG=./kubeconfig.yaml
        kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
        kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone
        kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
EOT
    environment = {
      AWS_REGION   = self.triggers.aws_region
      CLUSTER_NAME = self.triggers.cluster_name
      ROLE_ARN = self.triggers.role_arn
    }
  }
}

resource "helm_release" "eni-config" {
  name       = "eni-config"
  chart      = "eni-configs"

  values = [
    file("${path.module}/eni-configs/values.yaml")
  ]
}

# resource "null_resource" "az_subnet_daemonset_vars" {
#   depends_on = [
#     // Needs the VPC CNI installed to update its change
#     module.eks.cluster_addons
#     #aws_eks_addon.vpc_cni,
#     // Needs this security group rule to exist to gain access to the api
#     #aws_security_group_rule.control_plane
#   ]
#   triggers = {
#     aws_region   = local.region
#     cluster_name = local.cluster_name
#   }
#   provisioner "local-exec" {
#     command = <<-EOT
#         aws eks update-kubeconfig 
#             --region $AWS_REGION 
#             --name $CLUSTER_NAME 
#             --kubeconfig kubeconfig.yaml 
#         export KUBECONFIG=./kubeconfig.yaml
#         kubectl set env daemonset aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
#         kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone
#         kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
# EOT
#     environment = {
#       AWS_REGION   = self.triggers.aws_region
#       CLUSTER_NAME = self.triggers.cluster_name
#     }
#   }
# }


## the below is deploued via helm chart, so no need to deploy
# resource "null_resource" "az_subnet_eniconfig_cr_app" {
#   count = length(var.secondary_subnets)
#   depends_on = [
#     // Documentation suggests that the env as set before setting the CR
#     null_resource.az_subnet_daemonset_vars
#   ]
#   triggers = {
#     aws_region   = local.region
#     cluster_name = local.cluster_name
#     az           = var.secondary_subnets[count.index].availability_zone
#     sg_id        = aws_eks_cluster.my_cluster.vpc_config[0].cluster_security_group_id
#     subnet_id    = var.secondary_subnets[count.index].subnet_id
#   }
#   provisioner "local-exec" {
#     command = <<-EOT
#         aws eks update-kubeconfig \
#             --region $AWS_REGION \
#             --name $CLUSTER_NAME \
#             --kubeconfig kubeconfig.yaml
#         export KUBECONFIG=./kubeconfig.yaml
#         cat &lt;<CR_EOF | kubectl apply -f -
#         apiVersion: crd.k8s.amazonaws.com/v1alpha1
#         kind: ENIConfig
#         metadata:
#           name: $AWS_AZ
#         spec:
#           securityGroups:
#             - $WORKERGROUPS_SG
#           subnet: $SECONDARY_SUBNET_ID
#         CR_EOF
# EOT
#     environment = {
#       AWS_AZ              = self.triggers.az
#       WORKERGROUPS_SG     = self.triggers.sg_id
#       SECONDARY_SUBNET_ID = self.triggers.subnet_id
#       AWS_REGION          = self.triggers.aws_region
#       CLUSTER_NAME        = self.triggers.cluster_name
#     }
#   }
# }