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

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3-pip
              sudo mkdir -p /opt/airflow_project
              sudo chown -R ec2-user:ec2-user /opt/airflow_project
              cd /opt/airflow_project
              python3 -m venv airflow-venv
              source airflow-venv/bin/activate
              
              pip install apache-airflow[celery,postgres]
              pip install pandas

              sudo mkdir -p /opt/airflow_home
              sudo chown -R ec2-user:ec2-user /opt/airflow_home

              echo 'export AIRFLOW_HOME=/opt/airflow_home' >> ~/.bashrc
              source ~/.bashrc

              airflow db init
              airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email nkgxgongxi@gmail.com

              sed -i 's/^load_examples = True/load_examples = False/' /opt/airflow_home/airflow.cfg
              airflow webserver -D
              airflow scheduler -D
              EOF
  
   tags = {
    Name = "Airflow-Server"
  }
}