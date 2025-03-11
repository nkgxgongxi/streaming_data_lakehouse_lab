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
              sudo yum install git
              sudo mkdir -p /opt/airflow_project
              sudo chown -R ec2-user:ec2-user /opt/airflow_project
              cd /opt/airflow_project
              python3 -m venv airflow-venv
              source airflow-venv/bin/activate
              
              pip install apache-airflow[celery,postgres]
              pip install pandas
              pip install snowflake-connector-python
              pip install configparser

              sudo mkdir -p /opt/airflow_home
              sudo chown -R ec2-user:ec2-user /opt/airflow_home

              echo 'export AIRFLOW_HOME=/opt/airflow_home' >> ~/.bashrc
              source ~/.bashrc

              cd /opt
              sudo git clone https://nkgxgongxi:${var.github_access_key}@github.com/nkgxgongxi/streaming_data_lakehouse_lab.git
              sudo chown ec2-user:ec2-user /opt/streaming_data_lakehouse_lab
              
              sudo ln -s /opt/streaming_data_lakehouse_lab/airflow_dags/ /opt/airflow_home/dags

              airflow db migrate
              airflow users create --username admin --password ${var.airflow_user_password} --firstname Admin --lastname User --role Admin --email nkgxgongxi@gmail.com

              sudo sed -i 's/^load_examples = True/load_examples = False/' /opt/airflow_home/airflow.cfg
              airflow webserver -D
              airflow scheduler -D

              EOF
  
   tags = {
    Name = "Airflow-Server"
  }
}