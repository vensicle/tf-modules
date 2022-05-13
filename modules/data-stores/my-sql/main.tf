
#provider "aws" {
#	region = "us-east-2"
#}

resource "aws_db_instance" "example" {
	identifier_prefix = "${var.db_id_prefix}-example"
	engine	= "mysql"
	allocated_storage	= 10
	instance_class		= "db.t2.micro"
	skip_final_snapshot	= true
	db_name				= "example_database"
	
	username	= var.db_username
	password	= var.db_password
}
