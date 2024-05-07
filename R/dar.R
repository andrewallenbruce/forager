#' Calculate Average Days in AR
#'
#' @param df `<data.frame>` or `<tibble>` with three required columns: date,
#'   gross charges column and ending Accounts Receivables balance
#'
#' @param date column of `<date>`s
#'
#' @param gct `<dbl>` column of Gross Charges
#'
#' @param earb `<dbl>` column of Ending AR balances
#'
#' @param dart `<dbl>` Target Days in AR, default is `35` days
#'
#' @param period `<chr>` string specifying the calculation period; one of
#'   `"month"`, `"quarter"`, or `"year"`; defaults to `"month"`
#'
#' @returns a [tibble][tibble::tibble-package]
#'
#' @examples
#' avg_dar(df     = dar_ex(),
#'         date   = monthdate,
#'         gct    = gross_charges,
#'         earb   = ending_ar,
#'         dart   = 35,
#'         period = "month")
#'
#' avg_dar(df     = dar_ex(),
#'         date   = monthdate,
#'         gct    = gross_charges,
#'         earb   = ending_ar,
#'         dart   = 35,
#'         period = "quarter")
#'
#' @autoglobal
#'
#' @export
avg_dar <- function(df,
                    date,
                    gct,
                    earb,
                    dart = 35,
                    period = c("month", "quarter")) {

  period  <- match.arg(period)
  datecol <- rlang::englue("{{ date }}")
  earbcol <- rlang::englue("{{ earb }}")
  gctcol  <- rlang::englue("{{ gct }}")

  df <- dplyr::mutate(
    df,
    "{datecol}" := clock::as_date({{ date }}),
    nmon         = lubridate::month({{ date }}, label = FALSE),
    month        = lubridate::month({{ date }}, label = TRUE, abbr = FALSE),
    nqtr         = lubridate::quarter({{ date }}),
    ndip         = lubridate::days_in_month({{ date }})
  )

  if (period == "quarter") {

    qtr_max_nmons <- df |>
      dplyr::summarise(
        max_nmon = max(nmon),
        .by = nqtr) |>
      dplyr::pull(max_nmon)

    earb_sub <- df |>
      dplyr::filter(nmon %in% qtr_max_nmons) |>
      dplyr::select({{ date }}, {{ earb }}, nmon, nqtr, month)

    gct_sub <- df |>
      dplyr::summarise(
        "{gctcol}" := sum({{ gct }}),
        ndip = sum(ndip),
        .by = nqtr)

    df <- dplyr::left_join(
      earb_sub,
      gct_sub,
      by = dplyr::join_by(nqtr)
    )
  }

  earb_trg_col <- rlang::sym(rlang::englue("{{ earb }}_target"))
  earb_dc_col <- rlang::sym(rlang::englue("{{ earb }}_dec_abs"))

  df |>
    dplyr::mutate(

      # Average Daily Charge
      adc = {{ gct }} / ndip,

      # Days in Accounts Receivable
      dar = {{ earb }} / adc,

      # Actual Ratio of Ending AR to Gross Charges
      actual_ratio = {{ earb }} / {{ gct }},

      # Ideal Ratio of Ending AR to Gross Charges
      ideal_ratio = {{ dart }} / ndip,

      # Actual - Ideal Ratio
      diff_ratio = actual_ratio - ideal_ratio,

      # Ending AR Target
      "{{ earb }}_target" := ({{ gct }} * {{ dart }}) / ndip,

      # Ending AR Decrease Needed
      "{{ earb }}_dec_abs" := {{ earb }} - !!earb_trg_col,

      # Ending AR Percentage Decrease Needed
      "{{ earb }}_dec_pct" := !!earb_dc_col / {{ earb }},

      # <lgl> indicating whether DAR was under/over DARt
      pass = dplyr::case_when(dar < {{ dart }} ~ TRUE, TRUE ~ FALSE))
  # |>
  #   dplyr::select(
  #     dplyr::any_of(
  #       c("date",
  #         "month",
  #         "nmon",
  #         "nqtr",
  #         "ndip",
  #         "gct",
  #         "earb",
  #         "earb_trg",
  #         "earb_dc",
  #         "earb_pct",
  #         "adc",
  #         "dar",
  #         "pass",
  #         "actual",
  #         "ideal",
  #         "radiff")
  #     )
  #   )
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
    monthdate = seq(
      as.Date("2024-01-01"),
      by = "month",
      length.out = 10
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
      163799.44
      # 151410.74,
      # 169094.46
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
      178051.11
      # 162757.49,
      # 199849.32
    )
  )
}
