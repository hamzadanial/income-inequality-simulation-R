
###install.packages(c("dplyr", "purrr", "tibble", "ggplot2", "ineq"), dependencies = TRUE)

library(dplyr)     # data manipulation
library(purrr)     # functional programming (map)
library(tibble)    # tibble constructor
library(ggplot2)   # plotting
library(ineq)      # Gini()

## Data generation
set.seed(2025)
n    = 1000   # number of observations per scenario
reps = 100     # number of simulation replicates

## data simulation

df20 = map_dfr(
  seq_len(reps),
  function(rep) {
    scenarios = list(
      UniformPos   = runif(n,  min = 20,  max = 100),      # mild inequality
      LognormalPos = rlnorm(n, meanlog = 4, sdlog = 0.5),  # strong right skew
      NormalMix    = rnorm(n,  mean = 0,  sd = 50),        # mixed-sign distribution
      NewGauss     = rnorm(n,  mean = 50, sd = 20)         # symmetric moderate spread
    )
    imap_dfr(scenarios, ~ tibble(
      Replicate = rep,        # replicate number
      Scenario  = .y,         # scenario name
      ID        = seq_len(n), # observation ID
      Income    = .x          # simulated income value
    ))
  }
) %>%
  mutate(
    # relabel the scenarios for plotting/summary
    Scenario = factor(
      Scenario,
      levels = c("UniformPos", "LognormalPos", "NormalMix", "NewGauss"),
      labels = c("Scenario 1",   "Scenario 2",     "Scenario 3",     "Scenario 4")
    )
  )

## UD and RUD income

df20_rud = df20 %>%
  group_by(Replicate, Scenario) %>%
  mutate(
    y_min = min(Income),
    mu_y  = mean(Income),
    UD    = Income - y_min,
    RUD   = UD / mu_y
  ) %>%
  ungroup()

## density plot of scenarios
xlim_vals = range(df20_rud$Income)

ggplot(df20_rud, aes(x = Income, fill = Scenario)) +
  geom_density(alpha = 0.5, color = "black", size = 0.4) +
  facet_wrap(~ Scenario, ncol = 2, scales = "free_y") +
  xlim(xlim_vals) +
  labs(
    #title = "Income Density by Scenario (20 Replicates Combined)",
    x     = "Income",
    y     = "Density"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "none",
    strip.text      = element_text(face = "bold", size = 14)
  )

### inequality metrics
per_rep = df20_rud %>%
  group_by(Replicate, Scenario) %>%
  summarise(
    mu_z   = mean(RUD),
    sd_z   = sd(RUD),
    CV_z   = sd_z / mu_z,
    G_z    = Gini(RUD),

    # CDF‐based norms
    L1_c   = mu_z,
    L2_2_c = mu_z * (1 - G_z),

    # Quantile‐based norms
    L1_q   = mu_z,
    L2_2_q = mu_z^2 * (1 + CV_z^2),

    # Combined CDQF
    L1_cq   = L1_c + L1_q,
    L2_2_cq = L2_2_c + L2_2_q,

    # Lorenz‐based L1
    L1_l = 0.5 * mu_z * (1 - G_z),

    .groups = "drop"
  )

### Results
avg_results = per_rep %>%
  group_by(Scenario) %>%
  summarise(across(mu_z:L1_l, mean), .groups = "drop")

# -----------------------------------------------
# 7) Display the average results
# -----------------------------------------------
print(avg_results)
View(avg_results)

# Rounding all numeric columns to 3 decimal places
avg_results_3dp <- avg_results
avg_results_3dp[ , sapply(avg_results_3dp, is.numeric)] <-
    round(avg_results_3dp[ , sapply(avg_results_3dp, is.numeric)], 3)

# View in RStudio Viewer (like spreadsheet)
View(avg_results_3dp)

# OR print in console (for plain text output)
print(avg_results_3dp)

