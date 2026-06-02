module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.20.0"

  name               = "${var.username}-${var.repo}-${var.environment}-eks"
  kubernetes_version = var.cluster_version
  subnet_ids         = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id

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
    mvtthxw_group = {
      create_iam_role            = true
      iam_role_attach_cni_policy = true
      desired_size               = 1
      max_size                   = 4
      min_size                   = 1
      disk_size                  = 20

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

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
