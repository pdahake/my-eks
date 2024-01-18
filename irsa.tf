locals {
  # Not available on outposts
  oidc_root_ca_thumbprint = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  dns_suffix              = data.aws_partition.current.dns_suffix
}


resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.${local.dns_suffix}"]
  thumbprint_list = local.oidc_root_ca_thumbprint
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${var.cluster_name}-irsa" }
  )
}