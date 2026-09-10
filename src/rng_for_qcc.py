# Purpose: Generate random numerical data for quality control charting (QCC) based on
#  specified stage distributions.
# This file was generated using the prompt_RNG_spec_for_qcc.txt file as the specification.

import os
import yaml
import numpy as np
import pandas as pd

def main():
    # Load configuration parameters from config.yaml
    config_file = 'config.yaml'
    try:
        with open(config_file, 'r') as file:
            config = yaml.safe_load(file)
    except FileNotFoundError:
        print(f"Error: {config_file} not found in the root directory.")
        return

    # Extract target directories and parameters
    data_dir = config.get('directories', {}).get('data', 'data')
    batch_size = config.get('qcc_params', {}).get('batch_size', 4)
    
    # Construct target file path
    output_path = os.path.join(data_dir, 'output', 'RNG_for_qcc.csv')
    output_dir = os.path.dirname(output_path)

    # Check that the directory exists, but do not create it
    if not os.path.exists(output_dir):
        print(f"Error: The target directory '{output_dir}' does not exist.")
        print("Please ensure the directory structure exists before running.")
        return

    # Set the starting seed for RNG
    np.random.seed(42)

    # Define the data generation specifications per Table 1
    table_1_specs = [
        {'batches': 10, 'stage': 1, 'avg': 20.0, 'sd': 4.0, 'slope': 0.8},
        {'batches': 16, 'stage': 2, 'avg': 17.0, 'sd': 3.5, 'slope': 0.4},
        {'batches': 20, 'stage': 3, 'avg': 15.0, 'sd': 2.5, 'slope': 0.0},
        {'batches':  5, 'stage': 4, 'avg': 15.5, 'sd': 2.7, 'slope': 0.2}
    ]

    records = []

    # Generate data for each stage
    for spec in table_1_specs:
        stage = spec['stage']
        slope = spec['slope']
        for batch in range(1, spec['batches'] + 1):
            # Adjust average by slope for each batch
            adjusted_avg = spec['avg'] + (batch - 1) * slope
            values = np.random.normal(
                loc=adjusted_avg, scale=spec['sd'], size=batch_size
            )
            records.append({
                'stage': int(stage),
                'batch': batch,
                **{
                    f'x{index}': round(value, 2)
                    for index, value in enumerate(values, start=1)
                }
            })

    # Create a pandas DataFrame and enforce data formatting constraints
    df = pd.DataFrame(records)
    
    # Write to CSV, formatting the decimal to strictly 2 decimal places
    df.to_csv(output_path, index=False, float_format='%.2f')

    # Print success indicators
    print("Success: Process data generation complete.")
    print(f"Size of output data: {len(df)} rows")
    print(f"Output file path: {output_path}")

if __name__ == "__main__":
    main()