calculate_dar <- function(date = clock::date_build(2024, 1, 1),
                          gct = 198655.14,
                          earb = 256976.56,
                          dart = 39.445
                          ) {

  dplyr::lst(
    date = date,
    ndip = as.integer(lubridate::days_in_month(date)),
    gct = gct,
    earb = earb,
    adc = gct / ndip,
    dart = dart,
    dar = earb / adc,
    dar_pass = if (dar < dart) TRUE else FALSE,
    dar_diff = dart - dar,

    ratio_ideal = dart / ndip,
    ratio_actual = earb / gct,
    ratio_diff = ratio_ideal - ratio_actual,

    target_earb = (gct * dart) / ndip,
    target_earb_diff = target_earb - earb,

    target_gct = (earb * ndip) / dart,
    target_gct_diff = target_gct - gct,

    prop_gct = gct / (gct + earb),
    prop_earb = earb / (gct + earb),
    pct_gct = prop_gct * 100,
    pct_earb = prop_earb * 100
  )
}

cli::cli_inform(c(
  "{.strong {.emph Facility}} Amounts:",
  "\n",
  "RVU Total ............ {.strong {.val {rlang::sym(gt::vec_fmt_number(f$rvu))}}}",
  "Participating ........ {.strong {.val {rlang::sym(gt::vec_fmt_currency(f$par))}}}",
  "Non-Particpating ..... {.strong {.val {rlang::sym(gt::vec_fmt_currency(f$nonpar))}}}",
  "Limiting Charge ...... {.strong {.val {rlang::sym(gt::vec_fmt_currency(f$limit))}}}",
  "\n\n",

  "{.strong {.emph Non-Facility}} Amounts:",
  "\n",
  "RVU Total ............ {.strong {.val {rlang::sym(gt::vec_fmt_number(n$rvu))}}}",
  "Participating ........ {.strong {.val {rlang::sym(gt::vec_fmt_currency(n$par))}}}",
  "Non-Particpating ..... {.strong {.val {rlang::sym(gt::vec_fmt_currency(n$nonpar))}}}",
  "Limiting Charge ...... {.strong {.val {rlang::sym(gt::vec_fmt_currency(n$limit))}}}"
)
)





