data "aws_vpcs" "selected" {
  tags = {
    Name = var.vpc_name
    env  = var.env
  }
}
data "aws_subnets" "selected_public" {
  tags = {
    Name = "*public*"
    env  = var.env
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.selected.ids[0]]
  }
}
data "aws_ami" "gatewise_ami" {
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "name"
    values = [format("%s%s", var.ami_name, "*")]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}
data "aws_security_groups" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.selected.ids[0]]
  }
}
data "aws_security_groups" "my_ip" {
  filter {
    name   = "group-name"
    values = ["my-ip*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.selected.ids[0]]
  }
}
data "aws_security_groups" "web" {
  filter {
    name   = "group-name"
    values = ["http*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.selected.ids[0]]
  }
}

module "gatewise_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 4.1"

  name                        = "awspl-app-gatewise"
  subnet_id                   = data.aws_subnets.selected_public.ids[0]
  ami                         = data.aws_ami.gatewise_ami.id
  associate_public_ip_address = true
  instance_type               = var.gatewise_instance_type
  key_name                    = var.keypair_name
  vpc_security_group_ids      = concat(data.aws_security_groups.default.ids, data.aws_security_groups.my_ip.ids, data.aws_security_groups.web.ids)


  tags = {
    app = "gatewise"
    env = var.env
  }
  volume_tags = {
    app = "gatewise"
    env = var.env
  }
}

data "aws_route53_zone" "selected" {
  name         = format("%s%s", regex("^(?:(?P<record>[^\\.]+))?(?:.(?P<domain>[^/?#]*))?", var.hostname).domain, ".")
  private_zone = false
}

resource "aws_route53_record" "gatewise" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = regex("^(?:(?P<record>[^\\.]+))?(?:.(?P<domain>[^/?#]*))?", var.hostname).record
  type    = "A"
  ttl     = 300
  records = [module.gatewise_ec2.public_ip]
}
