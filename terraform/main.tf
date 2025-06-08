variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  type = string
}

variable "private_key" {
  type        = string
  sensitive   = true
  description = "Private key content passed from GitHub Actions"
}

variable "existing_instance_id" {
  type    = string
  default = ""
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  count         = var.existing_instance_id == "" ? 1 : 0
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 22.04 in us-east-1
  instance_type = "t2.micro"
  key_name      = var.key_name

  tags = {
    Name = "POD4WebServer"
  }

  provisioner "remote-exec" {
    inline = ["echo Instance ready"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = self.public_ip
    }
  }
}

data "aws_instance" "existing" {
  count       = var.existing_instance_id != "" ? 1 : 0
  instance_id = var.existing_instance_id
}

output "instance_id" {
  value = var.existing_instance_id != "" ? data.aws_instance.existing[0].id : aws_instance.web[0].id
}

output "instance_ip" {
  value = var.existing_instance_id != "" ? data.aws_instance.existing[0].public_ip : aws_instance.web[0].public_ip
}
