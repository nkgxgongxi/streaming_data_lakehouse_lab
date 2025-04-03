from nba_api.stats.endpoints import playercareerstats
from nba_api.live.nba.endpoints import scoreboard
import json
import pandas as pd

career = playercareerstats.PlayerCareerStats(player_id='203999') 

# pandas data frames (optional: pip install pandas)
print(career.get_data_frames()[0])

games = scoreboard.ScoreBoard()

# json
games_data = json.loads(games.get_json())['scoreboard']['games']
print(type(games_data))
df = pd.DataFrame(games_data)
print(df.columns)