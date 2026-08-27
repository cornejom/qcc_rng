---
name: RNG for QCC Project Rules
description: Project overview, architecture, and development guidelines for the RNG for QCC utility.
---

# Project Overview: RNG for QCC

This project is a Python-based utility designed to generate synthetic data for Quality Control Charts (QCC). It produces random numbers following normal distributions with specified parameters across different "stages" of a process.

## Key Technologies
- **Python 3.14+** (based on `.venv` metadata)
- **NumPy**: Used for random number generation (RNG).
- **Pandas**: Used for data manipulation and CSV export.
- **Pathlib**: For robust path management.

## Architecture
The project follows a simple script-based architecture:
- `src/`: Contains the source code and configuration.
- `data/`: Stores generated output files.
- `config.py`: Centralizes directory paths using `pathlib`.

***

# Getting Started

## Prerequisites
- Python 3.10 or higher
- `pip` for dependency management

## Installation
1. Clone the repository.
2. Create and activate a virtual environment:
   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```
3. Install dependencies:
   ```powershell
   pip install numpy pandas
   ```

## Basic Usage
To generate the random data:
```powershell
python src/rng_for_qcc.py
```
This will create a CSV file at `data/output/RNG_for_qcc.csv`.

***

# Project Structure

- **`.continue/rules/`**: Contains documentation and rules for the Continue AI assistant.
- **`src/`**:
    - `rng_for_qcc.py`: The main script that generates the data.
    - `config.py`: Project-wide configuration (e.g., `DATA_DIR`).
    - `prompt_RNG_spec_for_qc.txt`: The original prompt used to generate the script logic.
- **`data/`**:
    - `output/`: Target directory for generated CSV files.

***

# Development Workflow

## Coding Standards
- Use `pathlib` for all file path operations.
- Maintain consistency with the random seed (`42`) to ensure reproducible results.
- Format numerical output to 2 decimal places as required by the spec.

## Testing
Currently, the project uses manual verification of the output CSV. Future iterations could include:
- Validating the mean and standard deviation of generated stages.
- Ensuring row counts match the specifications in `Table 1`.

***

# Key Concepts

- **Stages**: Discrete phases of data generation (1 through 4).
- **RNG Seed**: Set to `42` to ensure that every run produces the exact same "random" data.
- **Normal Distribution**: Data is generated using `np.random.normal(avg, sd, n)`.

***

# Common Tasks

## Adding a New Stage
1. Open `src/rng_for_qcc.py`.
2. Locate the `parameters` list.
3. Add a new dictionary entry:
   ```python
   {'n': 50, 'stage': 5, 'avg': 18.0, 'sd': 3.0}
   ```

## Changing Output Location
Update the `DATA_DIR` in `src/config.py` or modify the `target_file` path in `src/rng_for_qcc.py`.

***

# Troubleshooting

## Missing Data Directory
The script is designed to create the `data/output` directory if it doesn't exist using `os.makedirs(..., exist_ok=True)`. If you encounter permission errors, ensure you have write access to the project root.

## Dependency Version Mismatch
If `pandas` or `numpy` fail to import, ensure your virtual environment is activated and the packages are installed.

***

# References
- [NumPy Random Documentation](https://numpy.org/doc/stable/reference/random/index.html)
- [Pandas DataFrame to_csv Documentation](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.to_csv.html)
