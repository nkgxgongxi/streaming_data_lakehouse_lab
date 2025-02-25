from newsapi import NewsApiClient
import configparser
import os

# Get the absolute path of the directory where the script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Construct the full path to config.ini
config_path = os.path.join(script_dir, "config.ini")

# Load the configuration file
config = configparser.ConfigParser()
config.read(config_path)

# Read the API key
my_api_key = config.get("api", "key")

# print(f"API Key: {my_api_key}")

# Init
newsapi = NewsApiClient(api_key=my_api_key)

# /v2/top-headlines
top_headlines = newsapi.get_top_headlines(q='trump',
                                          sources='bbc-news',
                                          language='en')

# /v2/everything
# all_articles = newsapi.get_everything(q='bitcoin',
#                                       sources='bbc-news,the-verge',
#                                       domains='bbc.co.uk,techcrunch.com',
#                                       from_param='2017-12-01',
#                                       to='2017-12-12',
#                                       language='en',
#                                       sort_by='relevancy',
#                                       page=2)

# /v2/top-headlines/sources
# sources = newsapi.get_sources()
# print(sources)

print(top_headlines)