output "vpc_id" {
  value = aws_vpc.kafka_vpc.id
}

output "subnet_id" {
  value = aws_subnet.kafka_subnet.id
}

output "security_group_id" {
  value = aws_security_group.kafka_sg.id
}