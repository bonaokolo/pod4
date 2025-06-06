provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
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
      private_key = file("../key.pem")
      host        = self.public_ip
    }
  }
}

output "instance_id" {
  value = aws_instance.web.id
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}
