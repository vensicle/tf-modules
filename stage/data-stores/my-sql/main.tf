terraform {
	backend "s3" {
		bucket = "my-tf-hqxz-state"
		key = "stage/data-stores/mysql/terraform.tfstate"
		region = "us-east-2"
		dynamodb_table	= "my-tf-hqxz-locks"
		encrypt	= true
	}
}

provider "aws" {
	region = "us-east-2"
}

resource "aws_db_instance" "example" {
	identifier_prefix = "nrp-terraform-example"
	engine	= "mysql"
	allocated_storage	= 10
	instance_class		= "db.t2.micro"
	skip_final_snapshot	= true
	db_name				= "example_database"
	
	username	= var.db_username
	password	= var.db_password
}
