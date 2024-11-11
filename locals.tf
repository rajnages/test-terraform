locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }

  # Condition example for production settings
  # This condition helps us determine if we're in a production environment
  # It can be used to enable/disable certain features or configurations
  # that should only be present in production, such as enhanced monitoring,
  # stricter security rules, or higher resource limits
  //instance_count = var.environment == "prod" ? 2 : 1

  # Security group rules using for_each
  sg_rules = {
    ssh = {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    http = {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  # Instance types
  instance_types = {
    dev = {
      public  = "t2.micro"
      private = "t2.micro"
    }
    prod = {
      public  = "t2.small"
      private = "t2.medium"
    }
  }

  # Use lookup for instance type based on environment
  public_instance_type  = lookup(local.instance_types[var.environment], "public", "t2.micro")
  private_instance_type = lookup(local.instance_types[var.environment], "private", "t2.micro")

  # User data scripts
  public_user_data  = file("${path.module}/public_user_data.sh")
  private_user_data = file("${path.module}/private_user_data.sh")
}
