module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.11.0"

  cluster_name    = local.eks.name
  cluster_version = local.eks.version

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true #tfsec:ignore:aws-eks-no-public-cluster-access
  cluster_endpoint_public_access_cidrs = []

  vpc_id     = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  enable_irsa                   = true
  create_iam_role               = true
  create_cluster_security_group = true

  node_security_group_additional_rules = {
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_generic = {
      description                   = "Cluster to node from 1025 to 65535"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_groups = {
    for index, az in module.vpc.azs : az => {
      instance_types    = ["t2.small","t3.small"]
      capacity_type     = "SPOT"
      min_size          = 2
      max_size          = 4
      desired_size      = 2
      disk_size         = 50
      subnet_ids        = [module.vpc.private_subnets[index]]
      enable_monitoring = false
      tags = {
        "k8s.io/cluster-autoscaler/${local.eks.name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"           = "true"
      }
    }
  }

  tags = merge(local.tags, { Name = local.eks.name })
}
