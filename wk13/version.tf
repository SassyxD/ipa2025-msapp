terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1" # ระบุเวอร์ชันชัด ๆ ตาม assignment
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
