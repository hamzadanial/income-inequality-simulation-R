# Income Inequality Simulation Study

This repository contains an R-based simulation study to assess and compare various income inequality metrics under different data-generating scenarios. The analysis explores four synthetic income distributions with varying shapes and skewness:

- **Scenario 1 (UniformPos):** Mild inequality using Uniform[20, 100]
- **Scenario 2 (LognormalPos):** Strong inequality from a log-normal distribution
- **Scenario 3 (NormalMix):** Mean-zero normal with high variance (includes negative incomes)
- **Scenario 4 (NewGauss):** Symmetric Gaussian around 50

## 🔧 Methods Used

Each scenario is simulated over 100 replicates with 1,000 individuals per replicate. The following inequality metrics are computed:

- **Gini coefficient**
- **Coefficient of Variation (CV)**
- **L1 and L2 norms (CDF-based and quantile-based)**
- **Combined Distributional Quantile Framework (CDQF)**
- **Lorenz-based L1 metric**

## 📊 Visualization

Density plots for income distributions are created using `ggplot2`. A sample output looks like:

![Density Plot](plots/income_density_plot.png)

## 📂 Files

- `inequality_simulation.R` – complete simulation script.
- `README.md` – this file.
- `plots/` – contains visual outputs (optional).

## 📦 Dependencies

Install the required packages in R:

```r
install.packages(c("dplyr", "purrr", "tibble", "ggplot2", "ineq"), dependencies = TRUE)

