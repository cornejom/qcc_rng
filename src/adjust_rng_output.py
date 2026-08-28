# This script is for adjusting the RNG output data, such as for adding arbitrary outliers.

from pathlib import Path

import pandas as pd
import yaml


PROJECT_ROOT = Path(__file__).resolve().parents[1]

ROW_UPDATES = [
	{"stage": 1, "batch": 8, "values": {"x1": 26, "x2": 28, "x3": 30}},
	{
		"stage": 2,
		"batch": 7,
		"values": {"x1": 25, "x2": 26, "x3": 24, "x4": 28},
	},
]


def main():
	config_path = PROJECT_ROOT / "config.yaml"
	with config_path.open(encoding="utf-8") as config_file:
		config = yaml.safe_load(config_file) or {}

	data_directory = Path(config["directories"]["data"])
	if not data_directory.is_absolute():
		data_directory = PROJECT_ROOT / data_directory

	input_path = data_directory / "output" / "RNG_for_qcc.csv"
	data = pd.read_csv(input_path)

	for update in ROW_UPDATES:
		matching_rows = (data["stage"] == update["stage"]) & (
			data["batch"] == update["batch"]
		)
		if matching_rows.sum() != 1:
			raise ValueError(
				"Expected exactly one row where "
				f"stage={update['stage']} and batch={update['batch']}, "
				f"but found {matching_rows.sum()}"
			)

		data.loc[matching_rows, list(update["values"])] = list(
			update["values"].values()
		)

	data.to_csv(input_path, index=False, float_format="%.2f")


if __name__ == "__main__":
	main()
