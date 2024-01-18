# resource "aws_eks_node_group" "node-grp" {
#   cluster_name    = aws_eks_cluster.eks.name
#   node_group_name = "eks-node-group"
#   node_role_arn   = aws_iam_role.node.arn
#   subnet_ids      = local.subnet_worker_ids
#   capacity_type   = "ON_DEMAND"
#   disk_size       = "20"
#   instance_types  = ["t2.small"]

#   remote_access {
#     ec2_ssh_key               = "eks"
#     source_security_group_ids = [aws_security_group.allow_tls.id]
#   }

#   labels = tomap({ env = "dev" })

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }

#   update_config {
#     max_unavailable = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#     #aws_subnet.pub_sub1,
#     #aws_subnet.pub_sub2,
#   ]
