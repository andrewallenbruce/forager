library(googlesheets4)
library(tidyverse)
library(janitor)
library(clock)

gs_id <- "1LM9juL8JJ1zihOMGV6kMeJ9Fe1tpmf9ka-thYpiWzt0"

nm_examples <- list(
  collections   = read_sheet(gs_id, sheet = "Collections") |> clean_names(),
  em_visits     = read_sheet(gs_id, sheet = "EM") |> clean_names(),
  reimbursement = read_sheet(gs_id, sheet = "Reimbursement") |> clean_names(),
  last_referral = read_sheet(gs_id, sheet = "LastReferral") |> clean_names()
)

nm_examples$collections <- nm_examples$collections |>
  reframe(
    patient,
    procedure  = as.character(code),
    dos        = as_date(date),
    balance    = amount,
    payer      = as_factor(payer),
    ins_class  = as_factor(payor_type),
    state      = as_factor(state),
    referring  = referring_physician,
    rendering  = doctor
    # hcpcs_desc = map(hcpcs_code, northstar::get_descriptions)
  )

nm_examples$em_visits <- nm_examples$em_visits |>
  reframe(
    patient,
    dos        = as_date(date),
    dob        = dos - years(patient_age),
    hcpcs_code = as.character(e_m_code),
    em_level   = as_factor(code_level),
    payer      = as_factor(insurance),
    city,
    state      = as_factor(state),
    referring  = referring_physician,
    rendering  = doctor
  )

nm_examples$reimbursement <- nm_examples$reimbursement |>
  reframe(
    patient,
    dos = as_date(date),
    hcpcs_code = cpt_code,
    payer = as_factor(primary_insurance),
    charges = billed,
    allowed,
    adjustment = wo,
    rendering = doctor
  )

nm_examples$last_referral <- nm_examples$last_referral |>
  reframe(
    referring_physician,
    rendering_physician = doctor,
    date_last_referral = as_date(last_referral_date),
    location,
    specialty
  )

pin_update(
  nm_examples,
  name = "nm_examples",
  title = "4 Examples from Nate Moore",
  description = "4 Examples from Nate Moore"
)

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
