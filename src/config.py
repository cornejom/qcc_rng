# project/config.py
from pathlib import Path

# Since config.py is in the root, its parent is the root
PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = PROJECT_ROOT / "data"
