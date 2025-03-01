variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the existing subnet"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Airflow"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "AMI ID for the Airflow instance"
  type        = string
  default     = "ami-0523420044a1cd2b1"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}
