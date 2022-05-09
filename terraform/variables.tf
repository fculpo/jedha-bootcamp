locals {
  customer    = "jedha"
  environment = "prod"

  full_name = "${local.customer}-${local.environment}"

  public_domain = "${local.environment}.${local.customer}.awslabs.culpo.fr."

  vpc = {
    name                     = "vpc-${local.full_name}"
    cidr                     = "10.1.0.0/16"
    azs                      = ["eu-west-3a", "eu-west-3b"]
    private_subnets          = ["10.1.32.0/19", "10.1.64.0/19"]
    public_subnets           = ["10.1.0.0/21", "10.1.8.0/21"]
    database_subnets         = ["10.1.128.0/20", "10.1.144.0/20"]
  }

  eks = {
    name          = "eks-${local.full_name}"
    version       = "1.21"
    instance_type = "t3.micro"
    desired_size  = 2
    asg_max_size  = 4
    disk_size     = 50
    public_endpoint_whitelist = []
  }

  caa_records = [
    "0 issue \"amazontrust.com\"",
    "0 issue \"amazonaws.com\"",
    "0 issue \"awstrust.com\"",
    "0 issue \"amazon.com\"",
    "0 issue \"letsencrypt.org\"",
  ]

  tags = {
    customer    = local.customer
    environment = local.environment
    terraform   = true
  }
}
