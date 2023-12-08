"""Manage the database."""
import sys
from pathlib import Path

# Add the root directory of your project to the sys.path
project_path = str(Path(__file__).resolve().parents[1])
sys.path.append(project_path)

from app import db
from app import app
app.app_context().push()
db.create_all()
