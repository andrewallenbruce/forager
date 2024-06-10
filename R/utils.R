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

#' Remove empty rows and columns
#'
#' @param df data frame
#'
#' @autoglobal
#'
#' @keywords internal
#'
#' @export
remove_quiet <- function(df) {

  janitor::remove_empty(
    df,
    which = c("rows", "cols")
    )
}

#' `mean()` with `NA` removal
#'
#' @param x numeric vector
#'
#' @autoglobal
#'
#' @keywords internal
#'
#' @export
mean_na <- function(x) {

  mean(x, na.rm = TRUE)
}

#' `sum()` with `NA` removal
#'
#' @param x numeric vector
#'
#' @autoglobal
#'
#' @keywords internal
#'
#' @export
sum_na <- function(x) {

  sum(x, na.rm = TRUE)
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
