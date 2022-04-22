provider "aws" {
	region = "us-east-2"
}
resource "aws_instance" "example" {
	ami = "ami-0fb653ca2d3203ac1"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.instance.id]
	
	user_data = <<-EOF
				#!/bin/bash
				cd /tmp
				echo "Hello, World" > index.html
nohup busybox httpd -f -p ${var.server_port} &
				EOF
	
	tags = {
		Name = "terraform-example"
	}
}

resource "aws_security_group" "instance" {
	name = "terraform-example-instance"
	
	ingress {
		from_port = var.server_port
		to_port = var.server_port
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

variable "server_port" {
	description = "There port the server will listen on"
	type = number
}

output "public_ip" {
	value = aws_instance.example.public_ip
	description = "Public IP of web server"
}
