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
#' @param add_day_counts `[logical]` add_day_counts add columns for days between events; default is `TRUE`
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
generate_data <- function(rows = 100, add_day_counts = TRUE, ...) {

  payer_names <- c(
    "Medicare",
    "Medicaid",
    "Cigna",
    "Humana",
    "United Health",
    "Anthem",
    "BCBS",
    "Centene"
  )

  rsmpl <- sample(1:rows, size = (75 * rows / 100))

  df <- dplyr::tibble(
    clm_id    = wakefield::id_factor(n = rows),
    payer     = forcats::as_factor(fixtuRes::set_vector(size = rows, set = payer_names)),
    charges   = as.double(wakefield::income(n = rows, digits = 2) / 300),
    date_srvc = lubridate::as_date(wakefield::date_stamp(
        n      = rows,
        start  = lubridate::today() - lubridate::dyears(1),
        random = TRUE)
    ),
    date_rlse   = date_srvc   + stats::rpois(rows, 1:15),
    date_submit = date_rlse   + stats::rpois(rows, 1:5),
    date_accept = date_submit + stats::rpois(rows, 5:20),
    date_adjud  = date_accept + stats::rpois(rows, 30:120),
    date_recon  = date_adjud  + stats::rpois(rows, 1:10)
  ) |>
    dplyr::mutate(
      balance = charges,
      balance = dplyr::if_else(date_adjud == date_recon, 0, balance),
      date_recon = dplyr::if_else(
        lubridate::year(date_srvc) == max(
          lubridate::year(date_srvc)) & balance > 0 & dplyr::row_number(date_recon) %in% rsmpl, NA, date_recon),
      balance = dplyr::if_else(!is.na(date_recon), 0, balance),
      .after  = charges
    ) |>
    dplyr::arrange(dplyr::desc(date_srvc))

  if (add_day_counts) {

    df <- df |>
      dplyr::mutate(
      days_rlse   = as.integer(date_rlse   - date_srvc),
      days_submit = as.integer(date_submit - date_rlse),
      days_accept = as.integer(date_accept - date_submit),
      days_adjud  = as.integer(date_adjud  - date_accept),
      days_recon  = as.integer(date_recon  - date_adjud),
      days_in_ar  = dplyr::if_else(
        is.na(date_recon),
        as.integer(date_adjud - date_srvc),
        as.integer(date_recon - date_srvc)
      )
    )
  }
  return(df)
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
