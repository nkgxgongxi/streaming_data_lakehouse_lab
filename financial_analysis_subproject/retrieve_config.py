import configparser
import os

def retrieve_config_info(config_file_name:str):
    # Get the absolute path of the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Construct the full path to config.ini
    config_path = os.path.join(script_dir, config_file_name)

    # Load the configuration file
    config = configparser.ConfigParser()
    config.read(config_path)

    return config

if __name__ == '__main__':
    config = retrieve_config_info("config.ini")