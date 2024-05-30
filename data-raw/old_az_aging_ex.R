source(here::here("data-raw", "pins_functions.R"))
library(tidyverse)
library(clock)
library(janitor)

old_azalea <- read_csv(
  "C:/Users/Andrew/Desktop/Aging_NEW.csv",
  show_col_types = FALSE
  ) |>
  clean_names() |>
  mutate(
    dos = anytime::anydate(dos),
    mon = as_factor(mon) |> suppressWarnings(fct_relevel(month.abb)),
    id = strex::str_split_by_numbers(id)
  ) |>
  unnest_wider(col = id, names_sep = "_") |>
  reframe(
    report_date = date_build(2021, 8, 16),
    report_mon = mon,
    pid = as.integer(id_2),
    enc = as.integer(id_4),
    dos,
    ins_class = case_match(ins_class,
                           "ma" ~ "Medicare Advantage",
      "comm" ~ "Commercial",
      "mcr" ~ "Medicare",
      "self_pay" ~ "Self-Pay",
      "mcd" ~ "Medicaid",
      "tricare" ~ "Tricare",
      "work_comp" ~ "Worker's Comp") |> as_factor(),
    ins_name = case_match(ins_name,
                          "part_B" ~ "Medicare Part B",
      "uhc" ~ "UHC",
      "bcbs" ~ "BCBS",
      "aetna" ~ "Aetna",
      "self_pay" ~ "Self-Pay",
      "humana" ~ "Humana",
      "medicaid" ~ "Medicaid",
      "ambetter" ~ "Ambetter",
      "meritain" ~ "Meritain",
      "umr" ~ "UMR",
      "cigna" ~ "Cigna",
      "aarp" ~ "AARP",
      "pruitt" ~ "Pruitt",
      "ebms" ~ "EBMS",
      "omaha" ~ "Omaha",
      "tricare_east" ~ "Tricare East",
      "railroad" ~ "Railroad Medicare",
      "wellcare" ~ "Wellcare",
      "champva" ~ "Champva",
      "careguard" ~ "Careguard",
      "caresource" ~ "Caresource",
      "tricare_forlife" ~ "Tricare for Life",
      "amerigroup" ~ "Amerigroup",
      "newera" ~ "Newera",
      "part_A" ~ "Medicare Part A",
      "work_comp" ~ "Worker's Comp") |> as_factor(),
    across(num_range("bin", 1:7)),
    total,
    aging_bin = case_match(
      bin,
      "b30" ~ "0-30",
      "b60" ~ "31-60",
      "b90" ~ "61-90",
      "b120" ~ "91-120",
      "b150" ~ "121+"
    ) |> forcats::fct_relevel(c("0-30", "31-60", "61-90", "91-120", "121+"))
    ) |>
  arrange(pid, enc)

dos_jun <- old_azalea |>
  filter(report_mon == "Jun") |>
  mutate(pid_enc = stringr::str_c(pid, enc, sep = ":")) |>
  select(pid_enc, dos)

dos_jul <- old_azalea |>
  filter(report_mon == "Jul", !is.na(dos)) |>
  mutate(pid_enc = stringr::str_c(pid, enc, sep = ":")) |>
  select(pid_enc, dos)

dos_aug <- old_azalea |>
  filter(report_mon == "Aug", !is.na(dos)) |>
  mutate(pid_enc = stringr::str_c(pid, enc, sep = ":")) |>
  select(pid_enc, dos)

dos_unique <- dos_jun |>
  full_join(dos_jul) |>
  full_join(dos_aug)

old_azalea <- old_azalea |>
  mutate(
    pid_enc = stringr::str_c(pid, enc, sep = ":"),
    dos = NULL,
    pid = NULL,
    enc = NULL,
    .after = report_mon
    ) |>
  left_join(dos_unique,
            relationship = "many-to-many",
            by = join_by(pid_enc)) |>
  select(report_date, report_mon, pid_enc, dos, everything()) |>
  mutate(report_date = case_when(
    report_mon == "Jun" ~ clock::set_month(report_date, 6),
    report_mon == "Jul" ~ clock::set_month(report_date, 7),
    .default = report_date),
    days_in_ar = as.integer(report_date - dos))

vctrs::vec_slice(
  old_azalea,
  old_azalea$report_mon == "Jul" & is.na(old_azalea$dos) & old_azalea$aging_bin == "0-30"
  )[["days_in_ar"]] <- sample(1:30, 323, replace = TRUE)

vctrs::vec_slice(
  old_azalea,
  old_azalea$report_mon == "Jul" & is.na(old_azalea$dos) & old_azalea$aging_bin == "31-60"
  )[["days_in_ar"]] <- sample(31:60, 56, replace = TRUE)

vctrs::vec_slice(
  old_azalea,
  old_azalea$report_mon == "Jul" & is.na(old_azalea$dos) & old_azalea$aging_bin == "61-90"
)[["days_in_ar"]] <- sample(61:90, 56, replace = TRUE)

old_azalea <- old_azalea |>
  mutate(dos = if_else(is.na(dos) & report_mon == "Jul", report_date - lubridate::ddays(days_in_ar), dos)) |>
  group_by(pid_enc) |>
  fill(dos) |>
  ungroup() |>
  mutate(days_in_ar = as.integer(report_date - dos))

vctrs::vec_slice(
  old_azalea,
  old_azalea$report_mon == "Aug" & is.na(old_azalea$dos) & old_azalea$aging_bin == "0-30"
)[["days_in_ar"]] <- sample(1:30, 399, replace = TRUE)

vctrs::vec_slice(
  old_azalea,
  old_azalea$report_mon == "Aug" & is.na(old_azalea$dos) & old_azalea$aging_bin == "31-60"
)[["days_in_ar"]] <- sample(31:60, 70, replace = TRUE)

old_azalea <- old_azalea |>
  mutate(dos = if_else(is.na(dos) & report_mon == "Aug", report_date - lubridate::ddays(days_in_ar), dos)) |>
  group_by(pid_enc) |>
  fill(dos) |>
  ungroup() |>
  mutate(days_in_ar = as.integer(report_date - dos))

old_azalea <- old_azalea |>
  reframe(
    rep_date = report_date,
    rep_mon = report_mon,
    pid = pid_enc,
    dos,
    aging_bin,
    across(num_range("bin", 1:7), ~ na_if(.x, 0)),
    balance = total,
    ins_class,
    ins_name
    ) |>
  # mutate(across(num_range("bin", 1:7), ~ na_if(.x, 0))) |>
  # pivot_longer(
  #   cols = num_range("bin", 1:7),
  #   names_to = "type_bin",
  #   values_to = "balance")
  # filter(dar < 0) # -14 dar
  mutate(rep_date = rep_date + lubridate::ddays(15),
         days_in_ar = as.integer(rep_date - dos)
         ) |>
  bin_aging(days_in_ar)

pin_update(
  old_azalea,
  name = "old_azalea",
  title = "old_azalea",
  description = "old_azalea"
)
