resource "aws_eks_cluster" "eks" {
  # Name of the cluster.
  name = local.cluster_name

  # The Amazon Resource Name (ARN) of the IAM role that provides permissions for 
  # the Kubernetes control plane to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.eks_cluster.arn

  # Desired Kubernetes master version
  version = var.k8s_version

  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = true

    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true

    # Must be in at least two different availability zones
    #subnet_ids = concat(local.worker_subnet_ids, local.public_subnet_ids)
    subnet_ids         = concat(local.worker_subnet_ids, [])
    security_group_ids = [aws_security_group.add_cluster.id]
    #public_access_cidrs = ["${data.http.ip.response_body}/32"]
    public_access_cidrs = [local.public_ip_cidr]
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_cluster_policy
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 3

  tags = merge(
    { Name = "/aws/eks/${var.cluster_name}/cluster" }
  )
}

