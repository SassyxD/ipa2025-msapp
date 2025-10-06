project_name   = "ipa-wk13"
environment    = "dev"
aws_region     = "us-east-1"
aws_profile    = "default"

vpc_cidr       = "10.10.0.0/16"
az_names       = ["ap-southeast-1a", "ap-southeast-1b"]

web_instance_type = "t3.micro"
web_count         = 2
key_name          = null
