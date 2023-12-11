"""Manage the database."""
import sys
from pathlib import Path


def main():
    """Create the database."""
    # Add the root directory of your project to the sys.path
    project_path = str(Path(__file__).resolve().parents[1])
    sys.path.append(project_path)

    # pylint: disable=import-outside-toplevel
    # from app import db

    # db.create_all()


if __name__ == "__main__":
    main()
