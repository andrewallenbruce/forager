#' Mount [pins][pins::pins-package] board
#'
#' @param source `<chr>` `"local"` or `"remote"`
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
#' @param pin `<chr>` string name of pinned dataset
#'
#' @template args-dots
#'
#' @returns `<tibble>`
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
#' @returns `<list>` of [pins][pins::pins-package]
#'
#' @noRd
list_pins <- function(...) {

  board <- mount_board(...)

  pins::pin_list(board)

}

#' Load example data
#'
#' @param name `<chr>` name of example dataset
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
#' @param rows number of rows to generate; default is 100
#'
#' @returns A [tibble][tibble::tibble-package]
#'
#' @examples
#' generate_data(rows = 5)
#'
#' @autoglobal
#'
#' @export
generate_data <- function(rows = 100){

  dplyr::tibble(
    claim_id        = wakefield::id(n = rows),
    date_of_service = wakefield::date_stamp(
      n             = rows,
      start         = lubridate::today() - lubridate::dyears(1),
      random        = TRUE),
    payer           = fixtuRes::set_vector(
      rows,
      set           = c("Medicare", "Medicaid", "Cigna", "Humana", "UnitedHealth", "Anthem", "BCBS", "Centene")),
    ins_class       = fixtuRes::set_vector(rows, set = c("Primary", "Secondary")),
    balance         = wakefield::income(n = rows, digits = 2) / 300) |>
    dplyr::mutate(
      date_of_service = lubridate::as_date(date_of_service),
      date_of_release = date_of_service + round(abs(stats::rnorm(length(date_of_service), 11, 4))),
      date_of_submission = date_of_release + round(abs(stats::rnorm(length(date_of_release), 2, 2))),
      date_of_acceptance = date_of_submission + round(abs(stats::rnorm(length(date_of_submission), 3, 2))),
      date_of_adjudication = date_of_acceptance + round(abs(stats::rnorm(length(date_of_acceptance), 30, 3))))
  # |>
  #   tidyr::nest(dates = tidyr::contains("date"))

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
    dplyr::mutate({{ var }} := forcats::fct_rev(forcats::fct_infreq({{ var }})))  |>
    ggplot2::ggplot(ggplot2::aes(y = {{ var }})) +
    ggplot2::geom_bar()
}
