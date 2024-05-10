#' Lirov's Net Payment Estimation
#'
#' @template args-df-default
#'
#' @template args-date-col
#'
#' @template args-gct-col
#'
#' @template args-earb-col
#'
#' @param net column of net payments
#'
#' @param parb_120 column of percentage of AR beyond 120 days old
#'
#' @template returns-default
#'
#' @examples
#' predict_net(
#'   net_ex(),
#'   date,
#'   gct,
#'   earb,
#'   net,
#'   parb_120)
#'
#' @autoglobal
#'
#' @export
predict_net <- function(df, date, gct, earb, net, parb_120) {

  df <- df |>
    dplyr::mutate(
      date = lubridate::ymd({{ date }}),
      pct_paid = {{ net }} / {{ gct }},
      parl_120 = 1 - {{ parb_120 }},
      net_pred = ({{ gct }} * pct_paid) * parl_120,
      earb_gt120 = {{ earb }} * parb_120,
      earb_lt120 = {{ earb }} * parl_120
    )

  pred <- dplyr::tibble(
    date = df$date[nrow(df)] + months(1),
    net_pred = df$net_pred[nrow(df)]
  )

  df <- df |>
    dplyr::mutate(
      net_pred = dplyr::lag(net_pred),
      net_diff = net_pred - net
    )

  vctrs::vec_rbind(df, pred) |>
    dplyr::select(
      date,
      gct,
      earb,
      earb_lt120,
      earb_gt120,
      parl_120,
      parb_120,
      pct_paid,
      net,
      net_pred,
      net_diff
    )
}

#' Net Prediction Example Data
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
net_ex <- function() {

  load_ex("monthly_raw") |>
    dplyr::select(date,
                  gct = gross_charges,
                  earb = ending_ar,
                  net = net_payment,) |>
    dplyr::mutate(date = lubridate::ymd(date),
                  parb_120 = rep(c(0.021, 0.047, 0.075), 4)
                  )
}
