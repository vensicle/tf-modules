provider "aws" {
	region = "us-east-2"
}

#resource "aws_instance" "example" {
#	ami = "ami-0fb653ca2d3203ac1"
#	instance_type = "t2.micro"
#	vpc_security_group_ids = [aws_security_group.instance.id]
#	
#	user_data = <<-EOF
#				#!/bin/bash
#				cd /tmp
#				echo "Hello, World" > index.html
#nohup busybox httpd -f -p ${var.server_port} &
#				EOF
#	
#	tags = {
#		Name = "terraform-example"
#	}
#}

resource "aws_launch_configuration" "example" {
	image_id = "ami-0fb653ca2d3203ac1"
	instance_type = "t2.micro"
	security_groups = [aws_security_group.instance.id]
	
	user_data = <<-EOF
				#!/bin/bash
				cd /tmp
				echo "Hello, World" > index.html
				nohup busybox httpd -f -p ${var.server_port} &
				EOF
				
	# Needed if used with an autoscaling group, otherwise you can't push changes because of the cross dependency between the resources
	lifecycle {
		create_before_destroy = true
	}
}

data "aws_vpc" "default" {
	default = true
}

data "aws_subnets" "default" {
	filter {
		name = "vpc-id"
		values = [data.aws_vpc.default.id]
	}
}

resource "aws_autoscaling_group" "example" {
	launch_configuration = aws_launch_configuration.example.name
	vpc_zone_identifier = data.aws_subnets.default.ids
	
	target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type = "ELB"
	
	min_size = 2
	max_size = 10
	
	tag {
		key = "Name"
		value = "terraform-asg-example"
		propagate_at_launch = true
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

resource "aws_lb" "example" {
	name = "terraform-asg-example"
	load_balancer_type = "application"
	subnets = data.aws_subnets.default.ids
	security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.example.arn
	port = 80
	protocol = "HTTP"
	
	# by default, return a simple 404 not found response
	default_action {
		type = "fixed-response"
		
		fixed_response {
			content_type = "text/plain"
			message_body = "404: page not found"
			status_code = 404
		}
	}
}

resource "aws_lb_listener_rule" "asg" {
	listener_arn = aws_lb_listener.http.arn
	priority = 100
	
	condition {
		path_pattern {
			values = ["*"]
		}
	}
	
	action {
		type = "forward"
		target_group_arn = aws_lb_target_group.asg.arn
	}
}

resource "aws_security_group" "alb" {
	name = "terraform-example-alb"
	
	#allow inbound http
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	#allow all outbound
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_lb_target_group" "asg" {
	name = "terraform-asg-example"
	port = var.server_port
	protocol = "HTTP"
	vpc_id = data.aws_vpc.default.id
	
	health_check {
		path = "/"
		protocol = "HTTP"
		matcher = "200"
		interval = 15
		timeout = 3
		healthy_threshold = 2
		unhealthy_threshold = 2
	}
}

variable "server_port" {
	description = "There port the server will listen on"
	type = number
	default = 8080
}

output "alb_dns_name" {
	value = aws_lb.example.dns_name
	description = "Domain name of load balancer"
}
