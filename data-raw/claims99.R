path99 <- "D:/medical_ins_large_claims/1999/claim99fr2.txt"

claims_99 <- tidytable::fread(path99)

names_new <- c(
  "CLAIMYR"  = "claim_yr",
  "CLAIMANT" = "claimant",
  "RELATION" = "relation",
  "PATSEX"   = "sex",
  "PATBRTYR" = "dob",
  "HOSCVCHG" = "hosp_covd_chrg",
  "HOSLWCHG" = "hosp_allw_chrg",
  "HOSPDCHG" = "hosp_paid_chrg",
  "PHYCVCHG" = "phys_covd_chrg",
  "PHYLWCHG" = "phys_allw_chrg",
  "PHYPDCHG" = "phys_paid_chrg",
  "OTHCVCHG" = "oth_covd_chrg",
  "OTHLWCHG" = "oth_allw_chrg",
  "OTHPDCHG" = "oth_paid_chrg",
  "TOTCVCHG" = "tot_covd_chrg",
  "TOTLWCHG" = "tot_allw_chrg",
  "TOTPDCHG" = "tot_paid_chrg",
  "DIAG1"    = "diag1",
  "DIAG1CHG" = "diag1chg",
  "DIAG2"    = "diag2",
  "DIAG2CHG" = "diag2chg",
  "DIAG3"    = "diag3",
  "DIAG3CHG" = "diag3chg",
  "DGCAT"    = "dgcat",
  "DGCATCHG" = "dgcatchg",
  "EXPOSMEM" = "exposmem",
  "PPO"      = "ppo"
  )


names(claims_99) |>
  rlang::set_names(names_new)

claims_99 <- claims_99 |>
  dplyr::tibble() |>
  janitor::clean_names() |>
  dplyr::mutate(relation = dplyr::case_when(
    relation == "E" ~ "Employee",
    relation == "S" ~ "Spouse",
    relation == "D" ~ "Dependent")) |>
  dplyr::mutate(sex = dplyr::case_when(
    sex == "F" ~ "Female",
    sex == "M" ~ "Male"))

# dplyr::mutate(exposmem = dplyr::case_when(exposmem == "Y" ~ TRUE,
#          exposmem == "N" ~ FALSE),
#               ppo = dplyr::case_when(ppo == "Y" ~ TRUE,
#       ppo == "N" ~ FALSE)) |>
# dplyr::mutate(diag2 = dplyr::na_if(diag2, ""),
#               diag3 = dplyr::na_if(diag3, ""))

