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
  datecol <- rlang::englue("{{ date }}")
  earbcol <- rlang::englue("{{ earb }}")
  gctcol  <- rlang::englue("{{ gct }}")

  df <- dplyr::mutate(
    df,
    "{datecol}" := clock::as_date({{ date }}),
    nmon         = lubridate::month({{ date }}, label = FALSE),
    mon          = lubridate::month({{ date }}, label = TRUE, abbr = TRUE),
    month        = lubridate::month({{ date }}, label = TRUE, abbr = FALSE),
    nqtr         = lubridate::quarter({{ date }}),
    yqtr         = lubridate::quarter({{ date }}, with_year = TRUE),
    dqtr         = paste0(lubridate::quarter({{ date }}), "Q", format({{ date }}, "%y")),
    year         = lubridate::year({{ date }}),
    ymon         = as.numeric(format({{ date }}, "%Y.%m")),
    myear        = format({{ date }}, "%b %Y"),
    nhalf        = lubridate::semester({{ date }}),
    yhalf        = lubridate::semester({{ date }}, with_year = TRUE),
    dhalf        = paste0(lubridate::semester({{ date }}), "H", format({{ date }}, "%y")),
    ndip         = lubridate::days_in_month({{ date }})
  )

  if (by == "quarter") {

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
      dar_pass = dplyr::case_when(dar < {{ dart }} ~ TRUE, TRUE ~ FALSE),
      dar_diff = dar - {{ dart }},

      # Ratios: Ending AR to Gross Charges
      ratio_actual = {{ earb }} / {{ gct }},
      ratio_ideal = {{ dart }} / ndip,
      ratio_diff = ratio_actual - ratio_ideal,

      # Ending AR Target
      "{{ earb }}_target" := ({{ gct }} * {{ dart }}) / ndip,

      # Ending AR Decrease Needed
      "{{ earb }}_dec_abs" := {{ earb }} - !!earb_trg_col,

      # Ending AR Percentage Decrease Needed
      "{{ earb }}_dec_pct" := !!earb_dc_col / {{ earb }},

      earb_gct_diff = {{ earb }} - {{ gct }},

      )
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
