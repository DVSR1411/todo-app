data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = ["ap-south-1a", "ap-south-1b"]
  }
}
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "20.37.1"
  cluster_name                    = "test"
  cluster_version                 = "1.32"
  kms_key_deletion_window_in_days = 7
  create_kms_key                  = false
  cluster_encryption_config       = {}
  cluster_addons = {
    coredns = {
      addon_version = "v1.11.4-eksbuild.2"
    }
    kube-proxy = {
      addon_version = "v1.32.0-eksbuild.2"
    }
    vpc-cni = {
      addon_version = "v1.19.2-eksbuild.1"
    }
    metrics-server = {
      addon_version = "v0.7.2-eksbuild.4"
    }
  }
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = false
  enable_cluster_creator_admin_permissions = true
  vpc_id                                   = data.aws_vpc.default.id
  subnet_ids                               = data.aws_subnets.selected.ids
  control_plane_subnet_ids                 = data.aws_subnets.selected.ids
  authentication_mode                      = "API_AND_CONFIG_MAP"
  eks_managed_node_groups = {
    test-ng = {
      ami_type               = "AL2023_x86_64_STANDARD"
      instance_types         = ["t2.small"]
      capacity_type          = "SPOT"
      vpc_security_group_ids = [aws_security_group.eks_sg.id]
      min_size               = 1
      max_size               = 3
      desired_size           = 2
      force_update_version   = false
      update_config = {
        max_unavailable_percentage = 25
      }
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
