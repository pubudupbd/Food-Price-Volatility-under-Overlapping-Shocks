# 06_figures.R
# Generate all manuscript figures

source("R/01_setup.R")

egg_data <- readRDS("models/egg_data_with_interventions.rds")
scaling <- readRDS("models/scaling_parameters.rds")
m_peak_A <- readRDS("models/m_peak_A.rds")

price_mean <- scaling$price_mean
price_sd <- scaling$price_sd

# ---------- Figure 1: Monthly egg prices with shaded events ----------

regions_plot <- tibble::tribble(
  ~letter, ~name, ~start, ~end, ~label, ~col,
  "a", "Price collapse", as.Date("2021-12-01"), as.Date("2022-02-28"),
  "(a) Price collapse\nDec 2021-Feb 2022", "#009E73",
  "b", "Fuel crisis", as.Date("2022-03-01"), as.Date("2022-12-31"),
  "(b) Fuel crisis\nMar-Dec 2022", "#E69F00",
  "c", "Strict MRP", as.Date("2024-01-01"), as.Date("2024-12-31"),
  "(c) Strict MRP\nJan-Dec 2024", "#0072B2",
  "d", "Relaxation", as.Date("2025-01-01"), as.Date("2025-10-31"),
  "(d) Relaxation\nJan-Oct 2025", "#CC79A7",
  "e", "Cyclone Ditwa", as.Date("2025-11-01"), as.Date("2025-12-31"),
  "(e) Cyclone Ditwa\nNov-Dec 2025", "#D55E00"
) %>%
  mutate(label = factor(label, levels = label))

p1 <- ggplot(egg_data, aes(x = Date, y = Price)) +
  geom_rect(
    data = regions_plot,
    aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf, fill = label),
    inherit.aes = FALSE,
    alpha = 0.16,
    colour = NA
  ) +
  geom_line(linewidth = 0.7, colour = "black") +
  geom_point(size = 1.4, colour = "black") +
  scale_fill_manual(
    name = "Identified structural changes",
    values = setNames(regions_plot$col, regions_plot$label)
  ) +
  labs(
    x = "Month",
    y = "Egg price (LKR per egg)",
    title = "Monthly Egg Prices with Identified Structural Changes",
    subtitle = "Shaded periods are for visualization clarity"
  ) +
  theme_pub +
  theme(legend.position = "bottom")

save_fig("figures/Fig1_monthly_egg_prices.png", p1, 8, 4.5)


# ---------- Figure 2: Posterior smooth trend ----------

sm <- conditional_smooths(m_peak_A, effects = "t", prob = 0.95)[[1]]

p2 <- ggplot(sm, aes(x = t, y = estimate__)) +
  geom_ribbon(aes(ymin = lower__, ymax = upper__), fill = cb$sky, alpha = 0.25) +
  geom_line(colour = cb$blue, linewidth = 0.95) +
  labs(
    x = "Time index (t)",
    y = "Estimated smooth effect f(t) on scaled price",
    title = "Posterior smooth trend (baseline component)"
  ) +
  theme_pub

save_fig("figures/Fig2_smooth_trend.png", p2, 7, 4.2)


# ---------- Figure 3: Intervention effects ----------

post <- as_draws_df(m_peak_A)

coef_names <- c(
  "b_PriceCollapse_a_pulse",
  "b_PriceCollapse_a_step",
  "b_PriceCollapse_a_ramp",
  "b_FuelCrisis_b_step",
  "b_FuelCrisis_b_ramp",
  "b_StrictMRP_c_step",
  "b_Relaxation_d_step",
  "b_Relaxation_d_ramp",
  "b_CycloneDitwa_e_pulse"
)

effects_long <- post %>%
  select(all_of(coef_names)) %>%
  pivot_longer(everything(), names_to = "parameter", values_to = "value") %>%
  mutate(parameter = gsub("^b_", "", parameter))

p3 <- ggplot(effects_long, aes(x = value, y = reorder(parameter, value))) +
  tidybayes::stat_halfeye(fill = cb$sky, alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(
    x = "Effect on scaled price",
    y = NULL,
    title = "Posterior distributions of intervention effects"
  ) +
  theme_pub

save_fig("figures/Fig3_intervention_effects.png", p3, 7.5, 5)


# ---------- Figure 4: Counterfactual fuel crisis removed ----------

ep_fit <- posterior_epred(m_peak_A, ndraws = 800)

egg_cf <- egg_data
egg_cf$FuelCrisis_b_step <- 0
egg_cf$FuelCrisis_b_ramp <- 0

ep_cf <- posterior_epred(m_peak_A, newdata = egg_cf, ndraws = 800)

cf_df <- egg_data %>%
  mutate(
    fitted = unscale_price(colMeans(ep_fit), price_mean, price_sd),
    cf_mean = unscale_price(colMeans(ep_cf), price_mean, price_sd),
    cf_lo = unscale_price(apply(ep_cf, 2, quantile, 0.025), price_mean, price_sd),
    cf_hi = unscale_price(apply(ep_cf, 2, quantile, 0.975), price_mean, price_sd)
  )

p4 <- ggplot(cf_df, aes(x = Date)) +
  geom_ribbon(aes(ymin = cf_lo, ymax = cf_hi), fill = cb$orange, alpha = 0.20) +
  geom_line(aes(y = fitted), colour = cb$blue, linewidth = 0.9) +
  geom_line(aes(y = cf_mean), colour = cb$red, linewidth = 0.9, linetype = "dashed") +
  labs(
    x = NULL,
    y = "Egg price (original scale)",
    title = "Counterfactual trajectory: fuel crisis effects removed",
    subtitle = "Blue solid = fitted; red dashed = counterfactual"
  ) +
  theme_pub

save_fig("figures/Fig4_counterfactual_fuel_removed.png", p4, 7.5, 4.5)


# ---------- Figure B1: Posterior of AR(1) correlation ----------

ar_name <- grep("^ar", names(post), value = TRUE)[1]

pB1 <- ggplot(post, aes(x = .data[[ar_name]])) +
  geom_density(fill = cb$sky, alpha = 0.55, colour = cb$blue) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(
    x = "AR(1) parameter",
    y = "Density",
    title = "Posterior of AR(1) correlation"
  ) +
  theme_pub

save_fig("figures/FigB1_AR1_posterior.png", pB1, 7, 4.2)


# ---------- Figure B2: Posterior predictive ribbon overlay ----------

yrep <- posterior_predict(m_peak_A, ndraws = 800)

pp_df <- tibble(
  t = egg_data$t,
  y = egg_data$Price_scaled,
  q05 = apply(yrep, 2, quantile, 0.05),
  q25 = apply(yrep, 2, quantile, 0.25),
  q75 = apply(yrep, 2, quantile, 0.75),
  q95 = apply(yrep, 2, quantile, 0.95)
)

pB2 <- ggplot(pp_df, aes(x = t)) +
  geom_ribbon(aes(ymin = q05, ymax = q95), fill = cb$sky, alpha = 0.18) +
  geom_ribbon(aes(ymin = q25, ymax = q75), fill = cb$sky, alpha = 0.35) +
  geom_line(aes(y = y), colour = cb$gray, linewidth = 0.75) +
  labs(
    x = "Data point (index)",
    y = "Standardized egg price",
    title = "Posterior predictive check: time-series ribbon overlay"
  ) +
  theme_pub

save_fig("figures/FigB2_ppc_ribbon_overlay.png", pB2, 7.5, 4.5)
