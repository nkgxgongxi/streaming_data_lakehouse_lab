provider "aws" {
  region = "ap-southeast-2" # Asia Pacific (Sydney)
}

module "networking" {
  source = "./networking"
}

module "airflow" {
  source = "./airflow"
  vpc_id = module.networking.vpc_id
  subnet_id = module.networking.subnet_id
  security_group_id = module.networking.security_group_id
}

# Uncomment when you want to deploy Kafka
# module "kafka" {
#   source = "./kafka"
#   vpc_id = module.networking.vpc_id
#   subnet_id = module.networking.subnet_id
#   security_group_id = module.networking.security_group_id
# }
