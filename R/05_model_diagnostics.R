# 05_model_diagnostics.R
# Model summaries and posterior predictive checks.

source("R/01_setup.R")

m_peak_A <- readRDS("models/m_peak_A.rds")

print(summary(m_peak_A))

p_ppc <- brms::pp_check(m_peak_A, type = "dens_overlay", ndraws = 100)

save_fig("figures/Fig_pp_check_density_overlay.png", p_ppc, width = 7, height = 4.5)
