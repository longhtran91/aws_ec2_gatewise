packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}


source "amazon-ebs" "gatewise-arm64-ami" {
  ami_name      = "ami-gatewise-ubuntu-22.02-arm64-${formatdate("YYYY-MM-DD-hh.mm-ZZZ", timestamp())}"
  instance_type = "t4g.nano"
  region        = "us-east-1"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    delete_on_termination = true
    volume_type = "gp3"
    encrypted = true
  }
  source_ami_filter {
    owners = ["099720109477"]
    most_recent = true
    filters = {
      name                = "*ubuntu*22.04*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "arm64"
    }
  }
  ssh_username = "ubuntu"
  temporary_security_group_source_public_ip = true
}

source "amazon-ebs" "gatewise-x86_64-ami" {
  ami_name      = "ami-gatewise-ubuntu-22.02-x86_64-${formatdate("YYYY-MM-DD-hh.mm-ZZZ", timestamp())}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    delete_on_termination = true
    volume_type = "gp3"
    encrypted = true
  }
  source_ami_filter {
    owners = ["099720109477"]
    most_recent = true
    filters = {
      name                = "*ubuntu*22.04*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
  }
  ssh_username = "ubuntu"
  temporary_security_group_source_public_ip = true
}

build {
  sources = [
    "source.amazon-ebs.gatewise-arm64-ami",
    "source.amazon-ebs.gatewise-x86_64-ami"
  ]
  provisioner "ansible" {
      user= "ubuntu"
      playbook_file = "./ansible/gatewise-playbook.yaml"
      ansible_ssh_extra_args = [                                                    
        "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
      ] 
  }
}