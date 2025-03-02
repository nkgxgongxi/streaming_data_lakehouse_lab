data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "existing" {
  id = var.subnet_id
}

resource "aws_instance" "airflow" {
  ami                    = "ami-064b71eca68aadfb8"
  instance_type          = "t2.medium"
  subnet_id              = data.aws_subnet.existing.id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = "kafka-ec2-key"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y python3-pip python3-venv
              python3 -m venv airflow-venv
              source airflow-venv/bin/activate
              pip install apache-airflow[celery,postgres]
              airflow db init
              airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@example.com
              airflow webserver -D
              airflow scheduler -D
              EOF

  tags = {
    Name = "Airflow-Server"
  }
}