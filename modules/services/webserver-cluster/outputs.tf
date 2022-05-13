output "alb_dns_name" {
	value = aws_lb.example.dns_name
	description = "Domain name of load balancer"
}

output "asg_name" {
	value		= aws_autoscaling_group.example.name
	description	= "Name of Auto Scaling Group"
}

# Exposing this from the module means callers can add additional access rules to the config in their code
output "alb_security_group_id" {
	value 		= aws_security_group.alb.id
	description = "ID of security group attached to load balancer"
}
