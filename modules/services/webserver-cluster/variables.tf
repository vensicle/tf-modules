variable "server_port" {
	description = "There port the server will listen on"
	type = number
	default = 8080
}

variable "cluster_name" {
	description = "The name to use for all the cluster resources"
	type = string
}

variable "db_remote_state_bucket" {
	description = "S3 bucket name for terraform remote state for database"
	type = string
}

variable "db_remote_state_key" {
	description = "Path to database's remote state in S3"
	type = string
}

variable "instance_type" {
	description = "EC2 instance type (e.g. t2.micro)"
	type = string
}

variable "min_size" {
	description = "Min number of EC2's in ASG"
	type = number
}

variable "max_size" {
	description = Max number of EC2's in ASG"
	type = number
}

