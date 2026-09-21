from pathlib import Path

# Function to find the project root directory based on a marker file.
def find_project_root(current_path: Path, marker_file: str = 'config.yaml') -> Path:
    """
    Searches upwards from the current path to find the directory containing the marker file.
    """
    # Check the current directory and all its parent directories
    for directory in [current_path] + list(current_path.parents):
        if (directory / marker_file).is_file():
            return directory
            
    raise FileNotFoundError(f"Could not find '{marker_file}' in {current_path} or its parents.")
