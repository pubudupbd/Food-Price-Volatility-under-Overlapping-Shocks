# 04_model_fitting.R
# Fit Bayesian Student-t AR(1) interrupted time-series model.

source("R/01_setup.R")

egg_data <- readRDS("models/egg_data_with_interventions.rds")

ctrl <- list(adapt_delta = 0.999, max_treedepth = 15)

f_mean <- brms::bf(
  Price_scaled ~
    s(t, bs = "tp", k = 6) +
    PriceCollapse_a_pulse +
    PriceCollapse_a_step + PriceCollapse_a_ramp +
    FuelCrisis_b_step + FuelCrisis_b_ramp +
    StrictMRP_c_step +
    Relaxation_d_step + Relaxation_d_ramp +
    CycloneDitwa_e_pulse,
  autocor = brms::cor_ar(~ t, p = 1)
)

m_peak_A <- brms::brm(
  formula = f_mean,
  data    = egg_data,
  family  = brms::student(),
  prior   = c(
    brms::prior(normal(0, 0.7), class = "b"),
    brms::prior(student_t(3, 0, 1), class = "sds"),
    brms::prior(student_t(3, 0, 1), class = "Intercept"),
    brms::prior(gamma(2, 0.1), class = "nu")
  ),
  chains  = 4,
  cores   = 4,
  iter    = 4000,
  warmup  = 2000,
  control = ctrl,
  save_pars = brms::save_pars(all = TRUE)
)

saveRDS(m_peak_A, "models/m_peak_A.rds")
