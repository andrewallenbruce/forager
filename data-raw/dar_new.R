

dar_ex() |>
  dar_new(
    date = date,
    gct = gross_charges,
    earb = ending_ar,
    dart   = 35,
    by = "mon")

dar_new <- function(df,
                date,
                gct,
                earb,
                dart = 35,
                by = c("mon", "qtr", "year-mon", "year-qtr")) {

  by <- match.arg(by)

  df <- dplyr::reframe(
    df,
    date = {{ date }},
    date = clock::as_date({{ date }}),
    ndip = lubridate::days_in_month({{ date }}),
    gct = {{ gct }},
    earb = {{ earb }}
    )

  df <- switch(
    by,
    mon = dplyr::mutate(df, month = clock::date_month_factor(date), .after = date) |>  dplyr::group_by(month),
    qtr = dplyr::group_by(df, quarter = clock::get_quarter(date)),
    stop("no method for `by = ", by, "`")
  )

  if (by == "mon") {

    df <- dplyr::group_by(df, month) |>
      dplyr::mutate(
        adc = gct / ndip,
        dar = earb / adc,
        dar_pass = dplyr::case_when(dar < {{ dart }} ~ TRUE, TRUE ~ FALSE),
        dar_diff = dar - {{ dart }},
        ratio_actual = earb / gct,
        ratio_ideal = {{ dart }} / ndip,
        ratio_diff = ratio_actual - ratio_ideal,
        earb_target = (gct * {{ dart }}) / ndip,
        earb_decrease =  earb - earb_target,
        earb_decrease_pct =  earb_decrease - earb,
        earb_gct_diff = earb - gct
        )
  }

  df |>
    .add_class()
}


# "year-mon" = dplyr::group_by(df, year  = clock::get_year(date), month = clock::date_month_factor(date)),
# "year-qtr" = dplyr::group_by(df, year  = clock::get_year(date), quarter = clock::get_quarter(date)),
