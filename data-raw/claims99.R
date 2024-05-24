## code to prepare `claims_99` dataset goes here

#qs::qread("C:/Users/andyb/Desktop/forager/extdata/large_claims_data/claims_99")

#"D:/medical_ins_large_claims/1999/claim99fr2.txt"

claims_99 <- fst::read_fst("C:/Users/andyb/Desktop/forager/extdata/large_claims_data/claims_99")

names(claims_99)[1] <- "claim_yr"
names(claims_99)[2] <- "pt_id"
names(claims_99)[4] <- "sex"
names(claims_99)[5] <- "birth_yr"

names(claims_99)[6] <- "hosp_covd_chrg"
names(claims_99)[7] <- "hosp_allw_chrg"
names(claims_99)[8] <- "hosp_paid_chrg"

names(claims_99)[9] <- "phys_covd_chrg"
names(claims_99)[10] <- "phys_allw_chrg"
names(claims_99)[11] <- "phys_paid_chrg"

names(claims_99)[12] <- "oth_covd_chrg"
names(claims_99)[13] <- "oth_allw_chrg"
names(claims_99)[14] <- "oth_paid_chrg"

names(claims_99)[15] <- "tot_covd_chrg"
names(claims_99)[16] <- "tot_allw_chrg"
names(claims_99)[17] <- "tot_paid_chrg"

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

usethis::use_data(claims_99, overwrite = TRUE)
