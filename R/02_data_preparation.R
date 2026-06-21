# 02_data_preparation.R
# Read and prepare monthly retail egg price data.

source("R/01_setup.R")

data_file <- "data/egg_prices_data.csv"

if (!file.exists(data_file)) {
  stop("Data file not found. Please place egg_prices_data.csv in the data/ folder.")
}

egg_data <- read.csv(data_file, stringsAsFactors = FALSE) %>%
  dplyr::rename(Date = DATE, Price = `RETAIL.PRICE`) %>%
  dplyr::mutate(Date = lubridate::mdy(Date)) %>%
  dplyr::arrange(Date)

egg_data <- egg_data %>%
  dplyr::mutate(
    t = dplyr::row_number() - 1,
    Price_scaled = as.numeric(scale(Price))
  )

price_mean <- mean(egg_data$Price, na.rm = TRUE)
price_sd   <- sd(egg_data$Price, na.rm = TRUE)

saveRDS(egg_data, "models/egg_data_prepared.rds")
saveRDS(list(price_mean = price_mean, price_sd = price_sd), "models/scaling_parameters.rds")
