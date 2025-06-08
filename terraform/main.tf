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

# Fetch details about existing EC2 instance
data "aws_instance" "existing" {
  count       = var.existing_instance_id != "" ? 1 : 0
  instance_id = var.existing_instance_id
}

# Start existing instance if stopped (null_resource used for external action)
resource "null_resource" "start_existing_instance" {
  count = var.existing_instance_id != "" ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      STATUS=$(aws ec2 describe-instances --instance-ids ${var.existing_instance_id} --query "Reservations[0].Instances[0].State.Name" --output text)
      echo "Instance state: $STATUS"
      if [ "$STATUS" = "stopped" ]; then
        echo "Starting instance ${var.existing_instance_id}"
        aws ec2 start-instances --instance-ids ${var.existing_instance_id}
        aws ec2 wait instance-running --instance-ids ${var.existing_instance_id}
        echo "Instance started"
      fi
    EOT
  }
}

output "instance_id" {
  value = var.existing_instance_id != "" ? data.aws_instance.existing[0].id : aws_instance.web[0].id
}

output "instance_ip" {
  value = var.existing_instance_id != "" ? data.aws_instance.existing[0].public_ip : aws_instance.web[0].public_ip
}
