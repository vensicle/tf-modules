# Staging env

provider "aws" {
	region = "us-east-2"
}

module "webserver_cluster" {
	source = "../../../modules/services/webserver-cluster"
	
	cluster_name			= "webservers-stage"
	db_remote_state_bucket	= "my-tf-hqxz-state"
	db_remote_state_key		= "stage/services/webserver-cluster/terraform.tfstate"
	
	instance_type 	= "t2.micro"
	min_size		= 2
	max_size		= 2
}
