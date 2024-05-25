source(here::here("data-raw", "pins_functions.R"))

cppm_ex <- tidytable::fread(here::here("cppm_ex.csv")) |>
  janitor::clean_names() |>
  dplyr::tibble() |>
  dplyr::reframe(
    date = readr::parse_date(
      month,
      format = "%b-%y"
      ) + lubridate::years(3),
    gross_charges = charges,
    ending_ar = ar_balance,
    adjustments,
    collections
    )


pin_update(
  cppm_ex,
  name = "cppm_ex",
  title = "CPPM Example",
  description = "CPPM Example"
)
