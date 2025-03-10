import configparser
import os

def retrieve_config_info(config_file_name:str, config_abs_path:str = None):
    # Get the absolute path of the directory where the script is located
    if not config_abs_path:
        script_dir = os.path.dirname(os.path.abspath(__file__))

    else:
        script_dir = os.path.normpath(config_abs_path)
    # Construct the full path to config.ini
    config_path = os.path.join(script_dir, config_file_name)
    print(config_path)

    # Load the configuration file
    config = configparser.ConfigParser()
    config.read(config_path)

    return config

if __name__ == '__main__':
    config = retrieve_config_info(config_file_name="config.ini", config_abs_path="/opt/airflow_home")

    print(config['snowflake'])
