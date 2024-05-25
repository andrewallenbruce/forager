source(here::here("data-raw", "pins_functions.R"))

library(googlesheets4)
library(tidyverse)
library(janitor)
library(clock)

# gs_id <- "1MVaKH6T6GZ39iKvrNRoiOBb47RQtMYJ4g0nvunmzsBg"

wkbk <- "1KUPLYD2dksyD4Gcc8pHL5Chw20Sjcck0HYM9VA_JZJ4"
sh1 <- read_sheet(wkbk, sheet = 1, col_types = "iicccccicccc")
sh2 <- read_sheet(wkbk, sheet = 2, col_types = "iicccccicccc")
sh3 <- read_sheet(wkbk, sheet = 3, col_types = "iicccccicccc")

practicum <- vctrs::vec_rbind(
  sh1,
  sh2,
  sh3
) |>
  mutate(
    specialty = case_match(
      specialty,
      "ER VISIT" ~ "Emergency Medicine",
      "CARDIO" ~ "Cardiology",
      "GASTRO" ~ "Gastroenterology",
      "ORTHO" ~ "Orthopedics",
      "RADIO" ~ "Radiology",
      "DERMA" ~ "Dermatology",
      "OBGYN" ~ "Obstetrics/Gynecology",
      "RESPIR" ~ "Respiratory",
      "PEDS" ~ "Pediatrics",
      "PLS SURG" ~ "Plastic Surgery",
      c("NERVOUS", "NEURO") ~ "Neurology",
      "ENT" ~ "Ear, Nose, Throat",
      "INPATIENT" ~ "Inpatient",
      "PSYCH" ~ "Behavioral Health",
      c("GENITOU", "GENITO") ~ "Genitourinary",
      "OSTEO" ~ "Osteopathy",
      "ENDOCR" ~ "Endocrinology",
      c("OPTIC", "OPTHAM") ~ "Opthamology",
      "WORKCMP" ~ "Worker's Comp"
      ) |>
      as_factor(),
    diagnosis = na_if(diagnosis, "-"),
    icd = na_if(icd, "-"),
    procedure = na_if(procedure, "-"),
    cpt = na_if(cpt, "-"),
    mod1 = na_if(mod1, "-"),
    mod2 = na_if(mod2, "-"),
    mod3 = na_if(mod3, "-"),
    notes = na_if(notes, "-"),
  ) |>
  rename(
    icd_10 = icd,
    hcpcs = cpt
  ) |>
  arrange(group, case) |>
  mutate(
    id = consecutive_id(case),
    group = NULL,
    case = NULL,
    .before = 1
    )


pin_update(
  practicum,
  name = "practicum",
  title = "AAPC CPC Practicum Case Data",
  description = "AAPC CPC Practicum Case Data"
)
