#' Mount [pins][pins::pins-package] board
#'
#' @param source `[character]` string: `"local"` (default) or `"remote"`
#'
#' @returns `<pins_board_folder>` or `<pins_board_url>`
#'
#' @noRd
mount_board <- function(source = c("local", "remote")) {

  source <- match.arg(source)

  switch(
    source,
    local  = pins::board_folder(
      fs::path_package(
        "extdata/pins",
        package = "forager")
    ),
    remote = pins::board_url(
      fuimus::gh_raw(
        "andrewallenbruce/forager/master/inst/extdata/pins/")
    )
  )
}

#' Get a pinned dataset from a [pins][pins::pins-package] board
#'
#' @param pin `[character]` string name of pinned dataset
#'
#' @template args-dots
#'
#' @returns A [tibble][tibble::tibble-package]
#'
#' @noRd
get_pin <- function(pin, ...) {

  board <- mount_board(...)

  pin <- rlang::arg_match0(pin, list_pins())

  pins::pin_read(board, pin)

}

#' List pins from a [pins][pins::pins-package] board
#'
#' @param ... arguments to pass to [mount_board()]
#'
#' @returns A `[list]` of [pins][pins::pins-package]
#'
#' @noRd
list_pins <- function(...) {

  board <- mount_board(...)

  pins::pin_list(board)

}

#' Load example data
#'
#' @param name `[character]` name of example dataset
#'
#' @returns A [tibble][tibble::tibble-package]
#'
#' @keywords internal
#'
#' @export
load_ex <- function(name) {

  get_pin(name)

}

#' Generate mock coding/billing data frame
#'
#' @param rows `[integerish]` rows number of rows to generate; default is `100`
#'
#' @param count_days `[logical]` add columns for days between events; default is `FALSE`
#'
#' @param ... `[dots]` additional arguments
#'
#' @returns A [tibble][tibble::tibble-package]
#'
#' @examples
#' generate_data(rows = 5)
#'
#' @autoglobal
#'
#' @export
generate_data <- function(rows = 100, count_days = FALSE, ...) {

  payer_names <- c(
    "Medicare",
    "Medicaid",
    "Cigna",
    "Humana",
    "UHC",
    "Anthem",
    "BCBS",
    "Centene"
  )

  # df$column <- sample(c("A", "B", "C"), nrow(relig_income), replace = TRUE)

  rsmpl <- sample(1:rows, size = (75 * rows / 100))

  df <- dplyr::tibble(
    claimid             = wakefield::id_factor(n = rows),
    payer               = forcats::as_factor(fixtuRes::set_vector(size = rows, set = payer_names)),
    charges             = as.double(wakefield::income(n = rows, digits = 2) / 300),
    age                 = as.double(wakefield::age(n = rows, x = 15:100)),
    date_service        = clock::date_today("") - age,
    date_release        = date_service + stats::rpois(rows, 1:15),
    date_submission     = date_release + stats::rpois(rows, 1:5),
    date_acceptance     = date_submission + stats::rpois(rows, 5:10),
    date_adjudication   = date_acceptance + stats::rpois(rows, 10:20),
    date_reconciliation = date_adjudication + stats::rpois(rows, 1:5)
  ) |>
    dplyr::mutate(
      age                 = NULL,
      balance             = charges,
      balance             = dplyr::if_else(date_adjudication == date_reconciliation, 0, balance),
      date_reconciliation = dplyr::if_else(lubridate::year(date_service) == max(lubridate::year(date_service)) & balance > 0 & dplyr::row_number(date_reconciliation) %in% rsmpl, NA, date_reconciliation),
      balance             = dplyr::if_else(!is.na(date_reconciliation), 0, balance),
      .after              = charges
    ) |>
    dplyr::arrange(dplyr::desc(date_service))

  if (count_days) {

    df <- df |>
      dplyr::mutate(
        days_release        = as.integer(date_release - date_service),
        days_submission     = as.integer(date_submission - date_release),
        days_acceptance     = as.integer(date_acceptance - date_submission),
        days_adjudication   = as.integer(date_adjudication  - date_acceptance),
        days_reconciliation = as.integer(date_reconciliation  - date_adjudication),
        days_in_ar          = dplyr::if_else(is.na(date_reconciliation),
                                    as.integer(date_adjudication - date_service),
                                    as.integer(date_reconciliation - date_service)
        )
      )
  }
  return(.add_class(df))
}

#' Sorted Bar Chart
#'
#' @param df data frame
#'
#' @param var column to plot
#'
#' @returns A [ggplot2][ggplot2::ggplot2-package] object
#'
#' @autoglobal
#'
#' @keywords internal
#'
#' @export
sorted_bars <- function(df, var) {
  df |>
    dplyr::mutate({{ var }} := forcats::fct_rev(
      forcats::fct_infreq({{ var }})))  |>
    ggplot2::ggplot(ggplot2::aes(y = {{ var }})) +
    ggplot2::geom_bar()
}


col_palette <- c(
  "#8ba58e",
  "#192a38",
  "#528084",
  "#2c3e50",
  "#8ca0aa"
)
