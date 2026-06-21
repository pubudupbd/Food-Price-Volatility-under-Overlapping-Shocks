# 01_setup.R
# Project setup. Run from the repository root folder.

required_packages <- c(
  "dplyr", "tibble", "tidyr", "lubridate",
  "brms", "posterior", "bayesplot",
  "ggplot2", "tidybayes", "patchwork"
)

missing_packages <- required_packages[
  !required_packages %in% rownames(installed.packages())
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages, dependencies = TRUE)
}

invisible(lapply(required_packages, library, character.only = TRUE))

dir.create("figures", showWarnings = FALSE)
dir.create("models", showWarnings = FALSE)

source("R/functions.R")

cb <- list(
  blue   = "#0072B2",
  orange = "#E69F00",
  green  = "#009E73",
  red    = "#D55E00",
  purple = "#CC79A7",
  sky    = "#56B4E9",
  black  = "#000000",
  gray   = "grey35"
)

theme_pub <- ggplot2::theme_bw(base_size = 11) +
  ggplot2::theme(
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major = ggplot2::element_line(linewidth = 0.25, colour = "grey90"),
    plot.title = ggplot2::element_text(face = "bold"),
    legend.title = ggplot2::element_text(face = "bold"),
    legend.position = "top"
  )
