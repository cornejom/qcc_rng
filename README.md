# Synthetic Data for an X-bar/S Control Chart

This repository generates synthetic process data and performs the calculations
needed to build a Quality Control Chart from subgroup averages and the average
standard deviation of the subgroups. The resulting data can be used to create
an X-bar/S control chart in a plotting tool such as Seaborn, ggplot2, or
Tableau.

## Workflow

1. `src/rng_for_qcc.py` uses a seeded random number generator to create
   synthetic observations for each stage and batch. It writes the result to
   `data/output/RNG_for_qcc.csv`.
2. `src/adjust_rng_output.py` modifies the generated CSV by setting selected
   observations to hard-coded outlier values. These outliers are intended to
   appear as signals of special causes on the control chart.
3. `src/qcc.R` reads the data and uses the R `qcc` package to calculate the
   subgroup statistics, center line, and control limits. It writes the tidy
   results to `data/output/control_chart_stats.csv`.
4. The output CSV can be passed to a plotting package or visualization tool.

The current configuration uses four observations per subgroup and sets
`chart_type` to `xbar` in `config.yaml`. The configuration also controls the
data directory and the number of decimal places in the calculated output.

## Requirements

### Python

Install the Python dependencies listed in `requirements.txt`:

```bash
python -m pip install -r requirements.txt
```

### R

Install the R packages used by `src/qcc.R`:

```r
install.packages(c("yaml", "qcc", "here"))
```

## Running the Pipeline

Run these commands from the repository root:

```bash
python src/rng_for_qcc.py
python src/adjust_rng_output.py
Rscript src/qcc.R
```

The scripts write their output to `data/output`. Running the scripts
in this order ensures that the generated data is created first, the intended
special-cause observations are applied second, and the control-chart
calculations use the adjusted data last.

## Repository Layout

```text
config.yaml
   Project and chart configuration
data/output/RNG_for_qcc.csv
   Generated and adjusted synthetic data
data/output/control_chart_stats.csv
   Calculated chart statistics and limits
src/rng_for_qcc.py
   Synthetic data generation
src/adjust_rng_output.py
   Hard-coded outlier adjustments
src/qcc.R
   qcc calculations and CSV export
```
