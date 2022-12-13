#' Calculate Quarterly Days in AR
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
#'dar_qtr(dar_mon_ex, date, gct, earb, dart = 40)

dar_qtr <- function(df, date = date, gct = gct, earb = earb, dart = 35) {

  stopifnot(inherits(df, "data.frame"))

  base <- dplyr::mutate(df,
                        date = as.Date({{ date }}, "%yyyy-%mm-%dd", tz = "EST"),
                        nmon = lubridate::month({{ date }}, label = FALSE),
                        nqtr = lubridate::quarter({{ date }}),
                        ndip = lubridate::days_in_month({{ date }}))

  earb_sub <- base |>
    dplyr::filter(nmon == 3 |
                    nmon == 6 |
                    nmon == 9 |
                    nmon == 12) |>
    dplyr::select(nqtr, date, {{ earb }})

  gct_sub <- base |>
    dplyr::group_by(nqtr) |>
    dplyr::summarise(gct_qtr = janitor::round_half_up(sum({{ gct }}), digits = 2),
                     ndip = sum(ndip), .groups = "drop")

  results <- merge(earb_sub, gct_sub)

  results <- results |> dplyr::mutate(

    # Average Daily Charge
    adc = janitor::round_half_up(gct_qtr / ndip, digits = 2),

    # Days in Accounts Receivable
    dar = janitor::round_half_up({{ earb }} / adc, digits = 2),

    # Ratio of Ending AR to Gross Charges
    actual = janitor::round_half_up({{ earb }} / gct_qtr, digits = 2),

    # Ideal Ratio of Ending AR to Gross Charges
    ideal = janitor::round_half_up({{ dart }} / ndip, digits = 2),

    # Actual - Ideal Ratio
    radiff = janitor::round_half_up(actual - ideal, digits = 2),

    # Ending AR Target
    earb_trg = janitor::round_half_up((gct_qtr * {{ dart }} / ndip),
                                      digits = 2),

    # Ending AR Decrease Needed
    earb_dc = janitor::round_half_up({{ earb }} - earb_trg, digits = 2),

    # Ending AR Percentage Decrease Needed
    earb_pct = janitor::round_half_up(((earb_dc / {{ earb }}) * 100), digits = 2),

    # Boolean indicating whether DAR was under/over DARt
    pass = dplyr::case_when(dar < {{ dart }} ~ TRUE, TRUE ~ FALSE)) |>

    # Reorder columns
    dplyr::select(date,
                  nqtr,
                  ndip,
                  gct_qtr,
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
