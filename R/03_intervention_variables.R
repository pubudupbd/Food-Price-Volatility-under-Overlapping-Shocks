# 03_intervention_variables.R
# Construct interrupted time-series intervention covariates.

source("R/01_setup.R")

egg_data <- readRDS("models/egg_data_prepared.rds")

regions <- tibble::tribble(
  ~letter, ~name,               ~start,               ~end,
  "a",     "PriceCollapse_a",   as.Date("2021-12-01"), as.Date("2022-02-28"),
  "b",     "FuelCrisis_b",      as.Date("2022-03-01"), NA,
  "c",     "StrictMRP_c",       as.Date("2024-01-01"), NA,
  "d",     "Relaxation_d",      as.Date("2025-01-01"), NA,
  "e",     "CycloneDitwa_e",    as.Date("2025-11-01"), as.Date("2025-12-31")
) %>%
  dplyr::mutate(
    start = pmax(start, min(egg_data$Date, na.rm = TRUE)),
    end   = dplyr::if_else(is.na(end), max(egg_data$Date, na.rm = TRUE), end),
    end   = pmin(end, max(egg_data$Date, na.rm = TRUE))
  ) %>%
  dplyr::filter(start <= end) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    start_obs = nearest_obs_date(start, egg_data$Date),
    end_obs   = nearest_obs_date(end, egg_data$Date)
  ) %>%
  dplyr::ungroup()

for (i in seq_len(nrow(regions))) {
  base  <- regions$name[i]
  s_obs <- regions$start_obs[i]
  e_obs <- regions$end_obs[i]

  t0 <- egg_data$t[egg_data$Date == s_obs][1]

  egg_data[[paste0(base, "_step")]]  <- as.integer(egg_data$Date >= s_obs)
  egg_data[[paste0(base, "_ramp")]]  <- pmax(0, egg_data$t - t0)
  egg_data[[paste0(base, "_pulse")]] <- as.integer(egg_data$Date >= s_obs & egg_data$Date <= e_obs)
}

saveRDS(egg_data, "models/egg_data_with_interventions.rds")
saveRDS(regions, "models/intervention_regions.rds")
