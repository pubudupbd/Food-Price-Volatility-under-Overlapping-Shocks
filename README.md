# Bayesian Interrupted Time-Series Analysis of Sri Lankan Egg Prices

This repository contains R code for fitting a Bayesian interrupted time-series (ITS) model to monthly retail egg prices in Sri Lanka.

The model uses a Student-t likelihood, a smooth time trend, intervention covariates, and AR(1) residual dependence.

## Repository Structure

- `R/` — R scripts for setup, data preparation, intervention construction, model fitting, diagnostics, and figures.
- `data/` — Input data file. Place `egg_prices_data.csv` here.
- `figures/` — Generated figures.
- `models/` — Saved fitted model objects. Large `.rds` files are ignored by Git.

## Required Data

Place the input file in:

```text
data/egg_prices_data.csv
```

The CSV file should contain at least these columns:

```text
DATE, RETAIL.PRICE
```

## Workflow

Run the scripts from the project root folder in this order:

```r
source("R/01_setup.R")
source("R/02_data_preparation.R")
source("R/03_intervention_variables.R")
source("R/04_model_fitting.R")
source("R/05_model_diagnostics.R")
source("R/06_figures.R")
```

## Main Methods

The analysis includes:

- Monthly price standardization
- Construction of pulse, step, and ramp ITS covariates
- Bayesian Student-t regression using `brms`
- Thin-plate spline baseline trend
- AR(1) residual autocorrelation
- Posterior predictive checking
- Publication-quality figure export

## Citation

If you use this repository, please cite the archived Zenodo DOI.

DOI: To be added after Zenodo archiving.

## Author

A.W.L.P. Thilan  
Department of Mathematics, Faculty of Science  
University of Ruhuna
