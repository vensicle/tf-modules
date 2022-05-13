terraform {
	backend "s3" {
		bucket	= "my-tf-hqxz-state"
		key		= "prod/data-stores/my-sql/terraform.tfstate"

		region = "us-east-2"
		dynamodb_table	= "my-tf-hqxz-locks"
		encrypt	= true
	}
}

provider "aws" {
	region = "us-east-2"
}

module "mysql_instance" {
	source = "../../../modules/data-stores/my-sql"
	
	db_id_prefix			= "nrp-terraform-prod"
	db_remote_state_bucket	= "my-tf-hqxz-state"
	db_remote_state_key		= "prod/data-stores/mysql/terraform.tfstate"
	
	db_username				= var.db_username
	db_password				= var.db_password

}