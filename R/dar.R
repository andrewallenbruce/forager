#' Calculate Average Days in AR
#'
#' @template args-df-default
#'
#' @template args-date-col
#'
#' @template args-gct-col
#'
#' @template args-earb-col
#'
#' @param dart `[numeric]` Target Days in AR, default is `35` days
#'
#' @param by `[character]` string specifying the calculation period; one of
#'   `"month"`, `"quarter"`, or `"year"`; defaults to `"month"`
#'
#' @template returns-default
#'
#' @examples
#' avg_dar(df     = dar_ex(),
#'         date   = date,
#'         gct    = gross_charges,
#'         earb   = ending_ar,
#'         dart   = 35,
#'         by = "month")
#'
#' avg_dar(df     = dar_ex(),
#'         date   = date,
#'         gct    = gross_charges,
#'         earb   = ending_ar,
#'         dart   = 35,
#'         by = "quarter")
#'
#' @autoglobal
#'
#' @export
avg_dar <- function(df,
                    date,
                    gct,
                    earb,
                    dart = 35,
                    by = c("month", "quarter")) {

  by  <- match.arg(by)

  df <- dplyr::transmute(
    df,
    date = clock::as_date({{ date }}),
    gct = {{ gct }},
    earb = {{ earb }},
    ndip = lubridate::days_in_month(date))

  if (by == "quarter") {

    qtr_dates <- collapse::funique(
      lubridate::quarter(
        df$date,
        type = "date_last")) |>
      lubridate::floor_date("month")

    qtr_earb <- df |>
      dplyr::filter(date %in% qtr_dates) |>
      dplyr::transmute(date, earb)

    qtr_gct <- df |>
      dplyr::group_by(
        date = lubridate::quarter(date, type = "date_last") |>
          lubridate::floor_date("month")) |>
      dplyr::summarise(
        gct = sum(gct),
        ndip = sum(ndip))

    df <- dplyr::full_join(
      qtr_earb,
      qtr_gct,
      by = dplyr::join_by(date)
    )
  }

  df |>
    dplyr::mutate(
      adc = gct / ndip,
      dart = {{ dart }},
      dar = earb / adc,
      dar_pass = dplyr::case_when(dar < {{ dart }} ~ TRUE, TRUE ~ FALSE),

      # dar_diff = dar - {{ dart }},

      # Ratios: Ending AR to Gross Charges
      ratio_ideal = {{ dart }} / ndip,
      ratio_actual = earb / gct,
      ratio_diff = ratio_ideal - ratio_actual,

      # Ending AR Target
      earb_target = (gct * {{ dart }}) / ndip,

      # Ending AR Decrease Needed
      earb_diff = earb_target - earb,

      gct_pct = gct / (gct + earb),
      earb_pct = earb / (gct + earb)

      # Ending AR Percentage Decrease Needed
      # earb_diff_pct = earb_target / {{ earb }},
      # earb_gct_diff = {{ earb }} - {{ gct }},

      ) |>
    .add_class()
}

#' Days in AR Example Data
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
dar_ex <- function() {

  dplyr::tibble(
    date = seq(
      as.Date("2024-01-01"),
      by = "month",
      length.out = 12
    ),

    gross_charges = c(
      325982.23,
      297731.74,
      198655.14,
      186047.56,
      123654.34,
      131440.28,
      153991.95,
      156975.52,
      146878.12,
      163799.44,
      151410.74,
      169094.46
    ),

    ending_ar = c(
      288432.52,
      307871.08,
      253976.56,
      183684.92,
      204227.59,
      203460.47,
      182771.32,
      169633.64,
      179347.72,
      178051.11,
      162757.49,
      199849.32
    )
  )
}
