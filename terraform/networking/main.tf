# Create a VPC
resource "aws_vpc" "kafka_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "KafkaVPC"
  }
}

# Create a subnet
resource "aws_subnet" "kafka_subnet" {
  vpc_id                  = aws_vpc.kafka_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-2a"
  tags = {
    Name = "KafkaSubnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "kafka_igw" {
  vpc_id = aws_vpc.kafka_vpc.id
  tags = {
    Name = "KafkaIGW"
  }
}

# Create a Route Table
resource "aws_route_table" "kafka_rt" {
  vpc_id = aws_vpc.kafka_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kafka_igw.id
  }
  tags = {
    Name = "KafkaRouteTable"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "kafka_rta" {
  subnet_id      = aws_subnet.kafka_subnet.id
  route_table_id = aws_route_table.kafka_rt.id
}

# Create a Security Group in the VPC
resource "aws_security_group" "kafka_sg" {
  name        = "kafka-sg"
  description = "Allow Kafka traffic"
  vpc_id      = aws_vpc.kafka_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Zookeeper
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Kafka Broker
  }

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Kafka Connect REST API
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# vpc
# resource "aws_vpc" "main" {
#   cidr_block = "10.0.0.0/16"
# }

# subnet
# resource "aws_subnet" "main" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
# }

# security group
# resource "aws_security_group" "main" {
#   vpc_id = aws_vpc.main.id
# }