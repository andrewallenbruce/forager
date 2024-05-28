source(here::here("data-raw", "pins_functions.R"))
library(tidyverse)
library(clock)
library(janitor)
library(readxl)

fac_a <- read_xlsx("D:/medical_ins_large_claims/rcm_kit_ar_aging_denials/AR Snapshot/Aging_FacilityA.xlsx") |>
  clean_names() |>
  remove_empty(c("rows", "cols")) |>
  mutate(
    account_number = as.character(account_number),
    snapshot_date = as_date(snapshot_date),
    admit_date = as_date(admit_date),
    discharge_date = as_date(discharge_date),
    original_bill_date = as_date(original_bill_date),
    patient_id = if_else(is.na(patient_id), row_number(n()), patient_id),
    pid = as_factor(patient_id) |> fct_anon(prefix = "p0"),
    patient_id = NULL,
    patient_class = as_factor(patient_class),
    patient_type = case_match(
      patient_type,
      "O - OUTPATIENT" ~ "Outpatient",
      "L - LAB" ~ "Lab",
      "E - EMERGENCY DEPT PATIENT" ~ "Emergency",
      "I - INPATIENT" ~ "Inpatient",
      "V - OBV" ~ "Observation",
      "S - SAME DAY STAY" ~ "Same Day Stay",
      "PT - PHYSICAL THERAPY" ~ "Physical Therapy",
      "A - PREADMISSION TESTING CHG" ~ "Preadmission Testing",
      "PA - PAIN MGMT" ~ "Pain Management",
      "M - MINOR PROCEDURE PATIENT" ~ "Minor Procedure",
      "MH - WOMEN'S HEALTH" ~ "Women's Health",
      "INFUSION THERAPY" ~ "Infusion Therapy",
      "ANTI-COAGULATION CLINIC" ~ "Anti-Coagulation Clinic",
      "EXP FAC SO LAB" ~ "Exp Fac SO Lab",
      "WOUND CARE/LYMPHEDEMA" ~ "Wound Care",
      "CARDIAC REHAB" ~ "Cardiac Rehab",
      "DIAGNOSTIC RADIOLOGY" ~ "Diagnostic Radiology",
      "OCCUPATIONAL THERAPY" ~ "Occupational Therapy",
      "CANCER CENTER" ~ "Cancer Center",
      "RADIATION THERAPY" ~ "Radiation Therapy",
      c("OTHER THERAPY", "THERAPY/SERIES PATIENT", "N CANTON THERAPY", "THERAPY - ORRVILLE") ~ "Other Therapy",
      "LTACH/GENETIC COUNSELING" ~ "Genetic Counseling",
      "BEHAVORIAL HEALTH" ~ "Behavioral Health",
      "NON-PATIENT" ~ "Non-Patient",
      "WEIGHT MANAGEMENT" ~ "Weight Management",
      "FAMILY PRAC/CLINIC" ~ "Family Clinic",
      "SPEECH THERAPY" ~ "Speech Therapy",
      "IMMEDIATE CARE" ~ "Immediate Care",
      "AKRON CHILDRENS HOSPITAL" ~ "Children's Hospital",
      "DIALYSIS TUSC" ~ "Dialysis",
      "INPATIENT SWING" ~ "Inpatient Swing",
      "HOSPICE" ~ "Hospice"
    ) |> as_factor(),
    facility = "A",
    account_chronology = case_match(
      account_chronology,
      "Pre Admit" ~ "Pre-Admit",
      "DNFB In Suspense" ~ "DNFB: In Suspense",
      "DNFB Beyond Suspense" ~ "DNFB: Beyond Suspense",
      .default = account_chronology
      ) |> as_factor()
  ) |>
  select(
    pt_id = pid,
    pt_name = patient_name,
    pt_class = patient_class,
    pt_type = patient_type,
    date_admitted = admit_date,
    date_discharged = discharge_date,
    # days_discharged = age_from_discharge,
    date_billed = original_bill_date,
    # days_billed = age_from_original_bill_date,
    date_report = snapshot_date,
    facility,
    service = medical_service,
    ins_class = financial_class_primary,
    ins_name = insurance_rollup_primary,
    status = account_chronology,
    aging_tier = aging_tier_discharge_date,
    balance = account_balance,
    charges = total_charges
  ) |>
  mutate(date_billed = as_date(date_billed + lubridate::dyears(1)),
         aging_tier = case_match(
           aging_tier,
           "0 - 30" ~ "0-30",
           "31 - 60" ~ "31-60",
           "61 - 90" ~ "61-90",
           "91 - 120" ~ "91-120",
           c("121 - 180", "181 - 365", "366 +") ~ "121+",
           .default = aging_tier
         ) |> as_factor(),
         aging_bin = suppressWarnings(
           forcats::fct_relevel(
             aging_tier,
             c("0-30", "31-60", "61-90", "91-120", "121+"),
             after = Inf
           )
         ),
         aging_tier = NULL)


fac_b <- read_xlsx("D:/medical_ins_large_claims/rcm_kit_ar_aging_denials/AR Snapshot/Aging_FacilityB.xlsx") |>
  clean_names() |>
  remove_empty(c("rows", "cols")) |>
  mutate(
    account_number = as.character(account_number),
    snapshot_date = as_date(snapshot_date),
    admit_date = as_date(admit_date),
    discharge_date = as_date(discharge_date),
    original_bill_date = as_date(original_bill_date),
    patient_id = if_else(is.na(patient_id), row_number(n()), patient_id),
    pid = as_factor(patient_id) |> fct_anon(prefix = "p0"),
    patient_id = NULL,
    patient_class = as_factor(patient_class),
    patient_type = case_match(
      patient_type,
      "O - OUTPATIENT" ~ "Outpatient",
      "L - LAB" ~ "Lab",
      "E - EMERGENCY DEPT PATIENT" ~ "Emergency",
      "I - INPATIENT" ~ "Inpatient",
      "V - OBV" ~ "Observation",
      "S - SAME DAY STAY" ~ "Same Day Stay",
      "PT - PHYSICAL THERAPY" ~ "Physical Therapy",
      "A - PREADMISSION TESTING CHG" ~ "Preadmission Testing",
      "PA - PAIN MGMT" ~ "Pain Management",
      "M - MINOR PROCEDURE PATIENT" ~ "Minor Procedure",
      "MH - WOMEN'S HEALTH" ~ "Women's Health",
      "INFUSION THERAPY" ~ "Infusion Therapy",
      "ANTI-COAGULATION CLINIC" ~ "Anti-Coagulation Clinic",
      "EXP FAC SO LAB" ~ "Exp Fac SO Lab",
      "WOUND CARE/LYMPHEDEMA" ~ "Wound Care",
      "CARDIAC REHAB" ~ "Cardiac Rehab",
      "DIAGNOSTIC RADIOLOGY" ~ "Diagnostic Radiology",
      "OCCUPATIONAL THERAPY" ~ "Occupational Therapy",
      "CANCER CENTER" ~ "Cancer Center",
      "RADIATION THERAPY" ~ "Radiation Therapy",
      c("OTHER THERAPY", "THERAPY/SERIES PATIENT", "N CANTON THERAPY", "THERAPY - ORRVILLE") ~ "Other Therapy",
      "LTACH/GENETIC COUNSELING" ~ "Genetic Counseling",
      "BEHAVORIAL HEALTH" ~ "Behavioral Health",
      "NON-PATIENT" ~ "Non-Patient",
      "WEIGHT MANAGEMENT" ~ "Weight Management",
      "FAMILY PRAC/CLINIC" ~ "Family Clinic",
      "SPEECH THERAPY" ~ "Speech Therapy",
      "IMMEDIATE CARE" ~ "Immediate Care",
      "AKRON CHILDRENS HOSPITAL" ~ "Children's Hospital",
      "DIALYSIS TUSC" ~ "Dialysis",
      "INPATIENT SWING" ~ "Inpatient Swing",
      "HOSPICE" ~ "Hospice"
    ) |> as_factor(),
    facility = "B",
    account_chronology = case_match(
      account_chronology,
      "Pre Admit" ~ "Pre-Admit",
      "DNFB In Suspense" ~ "DNFB: In Suspense",
      "DNFB Beyond Suspense" ~ "DNFB: Beyond Suspense",
      .default = account_chronology
    ) |> as_factor()
  ) |>
  select(
    pt_id = pid,
    pt_name = patient_name,
    pt_class = patient_class,
    pt_type = patient_type,
    date_admitted = admit_date,
    date_discharged = discharge_date,
    # days_discharged = age_from_discharge,
    date_billed = original_bill_date,
    # days_billed = age_from_original_bill_date,
    date_report = snapshot_date,
    facility,
    service = medical_service,
    ins_class = financial_class_primary,
    ins_name = insurance_rollup_primary,
    status = account_chronology,
    aging_tier = aging_tier_discharge_date,
    balance = account_balance,
    charges = total_charges
  ) |>
  mutate(date_billed = as_date(date_billed + lubridate::dyears(1)),
         aging_tier = case_match(
           aging_tier,
           "0 - 30" ~ "0-30",
           "31 - 60" ~ "31-60",
           "61 - 90" ~ "61-90",
           "91 - 120" ~ "91-120",
           c("121 - 180", "181 - 365", "366 +") ~ "121+",
           .default = aging_tier
         ) |> as_factor(),
         aging_bin = suppressWarnings(
           forcats::fct_relevel(
             aging_tier,
             c("0-30", "31-60", "61-90", "91-120", "121+"),
             after = Inf
           )
         ),
         aging_tier = NULL)

aging_facility <- bind_rows(
  fac_a,
  fac_b
)

pin_update(
  aging_facility,
  name = "aging_facility",
  title = "Facility A and B Aging Example",
  description = "Facility A and B Aging Example"
)
