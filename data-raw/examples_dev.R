
get_pin("aging_ex") |>
  dplyr::select(
    dos,
    charges,
    payer = ins_name
  ) |>
  days_between(dos) |>
  bin_aging(days_elapsed) |>
  dplyr::count(aging_bin, name = "claims") |>
  dplyr::mutate(prop = (claims / sum(claims)))


get_pin("aging_ex") |>
  dplyr::select(
    dos,
    charges,
    payer = ins_name
  ) |>
  days_between(dos) |>
  bin_aging(days_elapsed) |>
  dplyr::count(aging_bin, wt = charges, name = "balance") |>
  dplyr::mutate(prop = (balance / sum(balance)))


get_pin("aging_ex") |>
  dplyr::select(
    dos,
    charges,
    payer = ins_name
  ) |>
  days_between(dos) |>
  # dplyr::filter(days_elapsed > 20) |>
  ggplot2::ggplot(ggplot2::aes(days_elapsed)) +
  ggplot2::geom_bar() +
  ggplot2::scale_x_binned() +
  ggplot2::theme_minimal()


get_pin("cppm_ex")

get_pin("healthyr")[c("dos", "charges", "payer")]

get_pin("monthly_raw")

get_pin("nm_examples")

get_pin("patient_aging") |>
  dplyr::select(
    dos = date_bill_first,
    payer = ins_prim,
    dplyr::starts_with("bin_"),
    total = aging_total
    )
