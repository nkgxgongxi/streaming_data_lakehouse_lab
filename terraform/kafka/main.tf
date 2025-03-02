# Uncomment when trying to deploy kafka server
# provider "aws" {
#   region = "ap-southeast-2" # Asia Pacific (Sydney)
# }

# # Create a VPC
# resource "aws_vpc" "kafka_vpc" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_support = true
#   enable_dns_hostnames = true
#   tags = {
#     Name = "KafkaVPC"
#   }
# }

# # Create a subnet
# resource "aws_subnet" "kafka_subnet" {
#   vpc_id                  = aws_vpc.kafka_vpc.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = true
#   availability_zone       = "ap-southeast-2a"
#   tags = {
#     Name = "KafkaSubnet"
#   }
# }

# # Create an Internet Gateway
# resource "aws_internet_gateway" "kafka_igw" {
#   vpc_id = aws_vpc.kafka_vpc.id
#   tags = {
#     Name = "KafkaIGW"
#   }
# }

# # Create a Route Table
# resource "aws_route_table" "kafka_rt" {
#   vpc_id = aws_vpc.kafka_vpc.id
  
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.kafka_igw.id
#   }
#   tags = {
#     Name = "KafkaRouteTable"
#   }
# }

# # Associate Route Table with Subnet
# resource "aws_route_table_association" "kafka_rta" {
#   subnet_id      = aws_subnet.kafka_subnet.id
#   route_table_id = aws_route_table.kafka_rt.id
# }

# # Create a Security Group in the VPC
# resource "aws_security_group" "kafka_sg" {
#   name        = "kafka-sg"
#   description = "Allow Kafka traffic"
#   vpc_id      = aws_vpc.kafka_vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  
#   ingress {
#     from_port   = 2181
#     to_port     = 2181
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Zookeeper
#   }

#   ingress {
#     from_port   = 9092
#     to_port     = 9092
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Kafka Broker
#   }

#   ingress {
#     from_port   = 8083
#     to_port     = 8083
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Kafka Connect REST API
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Create EC2 Instance in the New VPC
# resource "aws_instance" "kafka_ec2" {
#   ami           = "ami-0523420044a1cd2b1" # Amazon Linux 2 (Free Tier Eligible)
#   instance_type = "t2.medium"
#   key_name      = "kafka-ec2-key"  # Replace with your key pair name
#   subnet_id     = aws_subnet.kafka_subnet.id
#   security_groups = [aws_security_group.kafka_sg.id]

#   user_data = <<-EOF
#               #!/bin/bash
#               # First ensure the timezone of the machine is the desired one (or aligned with RDS database).
#               sudo timedatectl set-timezone "Australia/Sydney"

#               # Install java jdk
#               sudo yum update -y
#               sudo yum install -y java-11-amazon-corretto wget

#               # Create Kafka Directory and Set Permissions
#               sudo mkdir -p /opt/kafka
#               sudo chown -R ec2-user:ec2-user /opt/kafka
              
#               # Install Kafka
#               cd /opt/kafka
#               wget https://downloads.apache.org/kafka/3.7.2/kafka_2.13-3.7.2.tgz
#               tar -xvzf kafka_2.13-3.7.2.tgz --strip 1

#               export KAFKA_HOME=/opt/kafka
#               export PATH=$PATH:$KAFKA_HOME/bin
#               export JAVA_HOME=/usr/lib/jvm/java-23-openjdk
#               export PATH=$PATH:$JAVA_HOME/bin
#               source ~/.bashrc

#               # Give EC2 User Permissions to Kafka Logs
#               sudo mkdir -p /var/log/kafka
#               sudo chown -R ec2-user:ec2-user /var/log/kafka
              
#               # Start Zookeeper as ec2-user
#               sudo -u ec2-user nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /var/log/kafka/zookeeper.log 2>&1 &
              
#               # Start Kafka Broker as ec2-user
#               sudo -u ec2-user nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /var/log/kafka/kafka.log 2>&1 &
              
#               # Install Kafka Connect
#               sudo mkdir -p /opt/kafka-connect
#               sudo chown -R ec2-user:ec2-user /opt/kafka-connect
#               cd /opt/kafka-connect
#               wget https://packages.confluent.io/archive/7.8/confluent-7.8.0.tar.gz
#               tar -xvzf confluent-7.8.0.tar.gz
#               mv confluent-7.8.0 /opt/kafka-connect/confluent
              
#               # Install JDBC Source Connector and PostgreSQL JDBC driver
#               sudo mkdir -p /opt/kafka-connect/plugins
#               sudo chown -R ec2-user:ec2-user /opt/kafka-connect/plugins
#               cd /opt/kafka-connect/plugins
#               wget https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/10.8.0/kafka-connect-jdbc-10.8.0.jar
#               wget https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
#               sudo chmod +rx kafka-connect-jdbc-10.8.0.jar
#               sudo chmod +rx postgresql-42.7.4.jar

#               # Update kafka-connect configuration
#               echo "plugin.path=/opt/kafka-connect" >> /opt/kafka/config/connect-distributed.properties
#               export CLASSPATH="/opt/kafka-connect/plugins/postgresql-42.7.4.jar:$CLASSPATH"

#               # Start Kafka Connect
#               sudo -u ec2-user nohup /opt/kafka-connect/confluent/bin/connect-distributed /opt/kafka/config/connect-distributed.properties > /var/log/kafka/kafka-connect.log 2>&1 &
              
#               EOF

#   tags = {
#     Name = "KafkaServer"
#   }
# }

# output "kafka_ec2_public_ip" {
#   value = aws_instance.kafka_ec2.public_ip
# }
