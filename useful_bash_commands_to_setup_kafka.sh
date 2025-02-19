# Starting Kafka server by 3 steps.
# Step 1. Zookeeper
sudo -u ec2-user nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /var/log/kafka/zookeeper.log 2>&1 &

# Step 2. Kafka
sudo -u ec2-user nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /var/log/kafka/kafka.log 2>&1 &

# Step 3. Kafka-Connect
sudo -u ec2-user nohup /opt/kafka-connect/confluent/bin/connect-distributed /opt/kafka/config/connect-distributed.properties > /var/log/kafka/kafka-connect.log 2>&1 &

# check the message processed by a specific topic, e.g., postgres-kafka_source_test_data
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic postgres-kafka_source_test_data --from-beginning --property print.key=true --property print.value=true

# list the Kafka topics 
/opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic postgres-kafka_source_test_data

# Check JDBC Source Connector status
curl -X GET http://localhost:8083/connectors/postgres-jdbc-source/status

# Check JDBC Source Connector config
curl -X GET http://localhost:8083/connectors/postgres-jdbc-source/config

# Set JDBC Source Connector config
curl -X POST -H "Content-Type: application/json" --data @/opt/kafka-connect/postgres-jdbc-source.json http://localhost:8083/connectors

curl -X PUT -H "Content-Type: application/json"  --data @postgres-jdbc-source.json http://localhost:8083/connectors/postgres-jdbc-source/config


# Restart the connector
curl -X POST http://localhost:8083/connectors/postgres-jdbc-source/tasks/0/restart






# make kafka into interactive mode
KAFKA_OPTS="-Djava.awt.headless=true" /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list



# Apply changes to update Kafka Home and Java Home
echo $KAFKA_HOME
echo $JAVA_HOME



export KAFKA_HOME=/opt/kafka
export PATH=$PATH:$KAFKA_HOME/bin
export JAVA_HOME=/usr/lib/jvm/java-23-openjdk
export PATH=$PATH:$JAVA_HOME/bin


source ~/.bashrc


# Run kafka in interactive mode
bash -i /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic postgres-kafka_source_test_data --from-beginning



/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic postgres-kafka_source_test_data --from-beginning

# check the date in EC2 instance
date

# Set the timezone of my EC2
sudo timedatectl set-timezone "Australia/Sydney"  # Or your local timezone



# reset the offset for my topic
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --all-groups --topic postgres-kafka_source_test_data --reset-offsets --to-earliest --execute









