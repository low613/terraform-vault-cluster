data "aws_availability_zones" "zones" {

}

data "aws_caller_identity" "current" {
}

module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "vault-vpc"
  cidr           = "10.0.0.0/16"
  azs            = data.aws_availability_zones.zones.zone_ids
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

data "aws_ami" "vault" {
  owners = [data.aws_caller_identity.current.account_id]
  filter {
    name   = "name"
    values = ["vault-ubuntu-jammy*"]
  }
  most_recent = true
}

resource "aws_key_pair" "ssh" {
  key_name_prefix = "vault"
  public_key      = var.ssh_pub_key
}

resource "aws_launch_template" "vault-server" {
  instance_type = "t3.nano"
  name_prefix   = "vault-server"
  image_id      = data.aws_ami.vault.image_id
  iam_instance_profile {
    arn = aws_iam_instance_profile.vault-kms-unseal.arn
  }
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.vault.id]
  user_data = base64encode(templatefile("${path.module}/scripts/userdata.sh", {
    region      = var.aws_region
    kms_id      = aws_kms_key.vault.id
    account     = data.aws_caller_identity.current.account_id
    private_key = var.priv_key_base64
    pub_key     = var.pub_key_base64
    ca          = var.ca_base64
  }))
  tag_specifications {
    resource_type = "instance"
    tags = {
      vault = "server"
    }
  }
}

resource "aws_kms_key" "vault" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal"
  }
}

resource "aws_autoscaling_group" "vault" {
  vpc_zone_identifier = module.vpc.public_subnets
  desired_capacity    = 3
  min_size            = 1
  max_size            = 3
  launch_template {
    id      = aws_launch_template.vault-server.id
    version = aws_launch_template.vault-server.latest_version
  }
  instance_refresh {
    strategy = "Rolling"
  }
}

module "acm-cloudflare" {
  source      = "../terraform-aws-acm-cloudflare"
  domain_name = var.domain_name
  zone_name   = var.zone_name
}
