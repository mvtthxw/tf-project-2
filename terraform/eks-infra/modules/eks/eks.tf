module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.20.0"

  name               = local.cluster_name
  kubernetes_version = local.cluster_version
  subnet_ids         = var.private_subnets
  vpc_id             = var.vpc_id

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  create_iam_role                          = true
  create_cloudwatch_log_group              = false

  endpoint_public_access  = true
  endpoint_private_access = true

  dataplane_wait_duration = "60s"

  timeouts = {
    create = "45m"
    delete = "45m"
  }

  addons_timeouts = {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  create_node_security_group = true
  node_security_group_additional_rules = {
    http = {
      description = "Allow HTTP from anywhere"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    https = {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_groups = {
    (local.eks_managed_node_group_name) = {
      create_iam_role            = true
      iam_role_attach_cni_policy = true
      desired_size               = var.eks.node_group_desired_size
      max_size                   = var.eks.node_group_max_size
      min_size                   = var.eks.node_group_min_size
      disk_size                  = var.eks.node_group_disk_size
      instance_types             = var.eks.node_group_instance_types
      capacity_type              = "ON_DEMAND"

      timeouts = {
        create = "45m"
        update = "45m"
        delete = "45m"
      }
    }
  }

  fargate_profiles = {
    default = {
      selectors = [
        {
          namespace = "fargate-apps"
        }
      ]
    }
  }

  addons = {
    vpc-cni = {
      most_recent                 = true
      before_compute              = true
      preserve                    = false
      service_account_role_arn    = module.vpc_cni_role.arn
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    },
    kube-proxy = {
      most_recent                 = true
      before_compute              = true
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    },
    coredns = {
      most_recent                 = true
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"               = "true"
    "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
  }

  # access_entries = {
  #   admin = {
  #     principal_arn = data.aws_caller_identity.current.arn
  #     type          = "STANDARD"
  #     policy_associations = {
  #       example = {
  #         policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }
}
