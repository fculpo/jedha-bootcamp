module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "jedha-vpc"

  cidr             = local.vpc.cidr
  azs              = local.vpc.azs
  private_subnets  = local.vpc.private_subnets
  public_subnets   = local.vpc.public_subnets
  database_subnets = local.vpc.database_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_ipv6          = false
  enable_nat_gateway   = true

  create_database_subnet_group = true

  # ACLs
  manage_default_network_acl = true
  default_network_acl_tags = {
    Name = "Default route table"
  }
  
  public_dedicated_network_acl   = true
  private_dedicated_network_acl  = true
  database_dedicated_network_acl = true

  # DHCP Options
  enable_dhcp_options              = false

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs
  enable_flow_log                                 = false
  create_flow_log_cloudwatch_log_group            = false
  create_flow_log_cloudwatch_iam_role             = true

  enable_vpn_gateway = false

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks.name}" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.eks.name}" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }

  tags = local.tags
}

resource "aws_route53_zone" "public" {
  name    = local.public_domain
  comment = "Public ${local.public_domain} zone"
  tags    = local.tags
}

resource "aws_route53_record" "caa" {
  zone_id = aws_route53_zone.public.zone_id
  name    = local.public_domain
  type    = "CAA"
  ttl     = 3600
  records = local.caa_records
}