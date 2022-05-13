variable "db_username" {
	type		= string
	sensitive	= true
}

variable "db_password" {
	type		= string
	sensitive	= true
}

variable "db_id_prefix" {
	description = "MySQL DB name prefix"
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