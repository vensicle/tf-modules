terraform {
	backend "s3" {
		bucket = "my-tf-hqxz-state"
		key = "global/s3/terraform.tfstate"
		region = "us-east-2"
		dynamodb_table	= "my-tf-hqxz-locks"
		encrypt	= true
	}
}

provider "aws" {
	region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
	bucket = "my-tf-hqxz-state"
	# prevent accidental deletion
	lifecycle {
		prevent_destroy = true
	}
}

# enable versioning for full revision history
resource "aws_s3_bucket_versioning" "enabled" {
	bucket = aws_s3_bucket.terraform_state.id
	versioning_configuration {
		status = "Enabled"
	}
}

# enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
	bucket = aws_s3_bucket.terraform_state.id
	
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "AES256"
		}
	}
}

# explicitly block public access
resource "aws_s3_bucket_public_access_block" "public_access" {
	bucket	= aws_s3_bucket.terraform_state.id
	block_public_acls	= true
	block_public_policy	= true
	ignore_public_acls	= true
	restrict_public_buckets	= true
}

resource "aws_dynamodb_table" "terraform_locks" {
	name	= "my-tf-hqxz-locks"
	billing_mode	= "PAY_PER_REQUEST"
	hash_key	= "LockID"
	
	attribute {
		name	= "LockID"
		type	= "S"
	}
}

output "s3_bucket_arn" {
	value = aws_s3_bucket.terraform_state.arn
	description = "The ARN of the S3 bucket holding Terraform state"
}

output "dynamodb_table_name" {
	value = aws_dynamodb_table.terraform_locks.name
	description = "The name of the DynamoDB table holding Terraform locks"
}

