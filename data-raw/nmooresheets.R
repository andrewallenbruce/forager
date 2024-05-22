library(googlesheets4)
library(tidyverse)
library(janitor)
library(clock)

nm_collect <- read_sheet(
  "1LM9juL8JJ1zihOMGV6kMeJ9Fe1tpmf9ka-thYpiWzt0",
  sheet = "Collections") |>
  clean_names()

nm_em <- read_sheet(
  "1LM9juL8JJ1zihOMGV6kMeJ9Fe1tpmf9ka-thYpiWzt0",
  sheet = "EM") |>
  clean_names()

nm_reimburse <- read_sheet(
  "1LM9juL8JJ1zihOMGV6kMeJ9Fe1tpmf9ka-thYpiWzt0",
  sheet = "Reimbursement") |>
  clean_names()

nm_refer <- read_sheet(
  "1LM9juL8JJ1zihOMGV6kMeJ9Fe1tpmf9ka-thYpiWzt0",
  sheet = "LastReferral") |>
  clean_names()


# Nate Moore Medicare Rate Example
#
nm_rate <- dplyr::tibble(
  payer = c("Aetna", "BCBS", "Cigna", "United", "Humana", "Anthem", "Centene"),
  rate = c(1.31, 1.3, 1.1, 1.68, 1.66, 1.55, 1.48),
  rvus = c(8100, 6000, 5700, 4000, 1990, 1000, 799))

ggplot(nm_rate, aes(x = rvus, y = rate)) +
  geom_point() +
  stat_smooth(method = "lm", se = FALSE, fullrange = TRUE, color = "red", span = 1, n = 100) +
  ggrepel::geom_label_repel(aes(label = paste0(rate * 100, "%, ", format(rvus, big.mark = ","), " RVUs"))) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Percentage of Reimbursement Compared to RVU Volume",
    x = "RVU Volume",
    y = "Rate as A Pct% of Medicare Reimbursement") +
  ggthemes::theme_fivethirtyeight()
