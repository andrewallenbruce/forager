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
#'
#' @examples
#'dar_month(dar_mon_ex, date, gct, earb, dart = 39.445)

dar_month <- function(df, date = date, gct = gct, earb = earb, dart = 35) {

  stopifnot(inherits(df, "data.frame"))

  results <- dplyr::mutate(df,
    nmon = lubridate::month({{ date }},
                            label = FALSE),
    month = lubridate::month({{ date }},
                             label = TRUE,
                             abbr = FALSE),
    # Number of Days in Period
    ndip = lubridate::days_in_month({{ date }}),
    # Average Daily Charge
    adc = janitor::round_half_up({{ gct }} / ndip,
                                  digits = 2),
    # Days in Accounts Receivable
    dar = janitor::round_half_up({{ earb }} / adc,
                                  digits = 2),
    # Ratio of Ending AR to Gross Charges
    actual = janitor::round_half_up({{ earb }} / {{ gct }},
                                     digits = 2),
    # Ideal Ratio of Ending AR to Gross Charges
    ideal = janitor::round_half_up({{ dart }} / ndip,
                                    digits = 2),
    # Actual - Ideal Ratio
    radiff = janitor::round_half_up(actual - ideal,
                                       digits = 2),
    # Ending AR Target
    earb_trg = janitor::round_half_up(({{ gct }} * {{ dart }} / ndip),
                                       digits = 2),
    # Ending AR Decrease Needed
    earb_dc = janitor::round_half_up({{ earb }} - earb_trg,
                                      digits = 2),
    # Ending AR Percentage Decrease Needed
    earb_dcpct = janitor::round_half_up(earb_dc / {{ earb }}, digits = 2),
    # Boolean indicating whether DAR was under/over DARt
    pass = dplyr::case_when(dar < {{ dart }} ~ TRUE,
                     TRUE ~ FALSE)
  )

  return(results)

}
