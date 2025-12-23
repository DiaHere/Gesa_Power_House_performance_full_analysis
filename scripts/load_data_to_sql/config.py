# loader/config.py
import os
from dotenv import load_dotenv

# load .env from project root
basedir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))

dotenv_path = os.path.join(basedir, '.env.cred')

load_dotenv(dotenv_path)

DB_CONFIG = {
    'host':     os.getenv('DB_HOST'),
    'port':     int(os.getenv('DB_PORT', 3306)),
    'user':     os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME'),
}

