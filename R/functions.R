# Helper functions

nearest_obs_date <- function(target_date, obs_dates) {
  obs_dates[which.min(abs(obs_dates - target_date))]
}

unscale_price <- function(x_scaled, price_mean, price_sd) {
  x_scaled * price_sd + price_mean
}

save_fig <- function(filename, plot, width, height, dpi = 300) {
  ggplot2::ggsave(
    filename = filename,
    plot     = plot,
    width    = width,
    height   = height,
    units    = "in",
    dpi      = dpi
  )
}
