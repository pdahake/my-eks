
resource "aws_security_group" "worker" {
  name_prefix = "worker_group"
  vpc_id      = local.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [for s in local.worker_subnets : s.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [for s in local.worker_subnets : s.cidr_block]
  }
  tags = { Name = "worker_group_sg" }
}

resource "aws_security_group" "add_cluster" {
  name_prefix = "add_cluster_group"
  vpc_id      = local.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.http.ip.response_body}/32"]
  }
  ingress {
    description = "Nodes on ephemeral ports"
    protocol    = "tcp"
    from_port   = 1025
    to_port     = 65535
    self        = true
  }
  ingress {
    description = "Ingress from another computed security group"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    self        = true
  }
  ingress {
    description = "Node groups to cluster API"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    self        = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.http.ip.response_body}/32"]
  }
  tags = { Name = "add_cluster_group_sg" }
}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

