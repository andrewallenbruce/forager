#' Calculate Monthly Days in AR
#'
#' @param df data frame containing at least three columns:
#' a date column, a gross charges column and an ending AR column
#' @param date column containing a date within the month that
#' Days in AR is to be calculated
#' @param gct column containing a month's total Gross Charges
#' @param earb column containing a month's Ending AR balance
#' @param dart target Days in AR, default is 35 days
#'
#' @return data frame
#' @export
#' @autoglobal
#' @examples
#' dar_mon_ex <- data.frame(
#' date = as.Date(c(
#' "2022-01-01", "2022-02-01", "2022-03-01",
#' "2022-04-01", "2022-05-01", "2022-06-01",
#' "2022-07-01", "2022-08-01", "2022-09-01",
#' "2022-10-01", "2022-11-01", "2022-12-01")),
#'
#' gct = c(
#' 325982.23, 297731.74, 198655.14,
#' 186047.56, 123654.34, 131440.28,
#' 153991.95, 156975.52, 146878.12,
#' 163799.44, 151410.74, 169094.46),
#'
#' earb = c(
#' 288432.52, 307871.08, 253976.56,
#' 183684.92, 204227.59, 203460.47,
#' 182771.32, 169633.64, 179347.72,
#' 178051.11, 162757.49, 199849.32))
#'
#'dar_month(dar_mon_ex, date, gct, earb, dart = 40)

dar_month <- function(df, date, gct, earb, dart = 35) {

  results <- df |> dplyr::mutate(
    date = clock::as_date({{ date }}),
    nmon = lubridate::month(date, label = FALSE),
    month = lubridate::month(date, label = TRUE, abbr = FALSE),
    ndip = lubridate::days_in_month(date),
    adc = {{ gct }} / ndip,
    dar = {{ earb }} / adc,
    actual = {{ earb }} / {{ gct }},
    ideal = {{ dart }} / ndip,
    radiff = actual - ideal,
    earb_trg = ({{ gct }} * {{ dart }}) / ndip,
    earb_dc = {{ earb }} - earb_trg,
    earb_pct = (earb_dc / {{ earb }}) * 100,
    pass = dplyr::case_when(
      dar < {{ dart }} ~ TRUE,
      TRUE ~ FALSE)) |>
    dplyr::select(date,
                  month,
                  nmon,
                  ndip,
                  gct,
                  earb,
                  earb_trg,
                  earb_dc,
                  earb_pct,
                  adc,
                  dar,
                  pass,
                  actual,
                  ideal,
                  radiff)

  return(results)

}
