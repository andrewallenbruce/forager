#' @export
print.forager <- function(x, ...) {

  withr::with_options(
    list(
      pillar.bold = TRUE,
      pillar.subtle_num = TRUE,
      pillar.print_min = 20
      ),
    NextMethod()
  )
  invisible(x)
}

#' @keywords internal
#'
#' @noRd
.add_class <- function(data) {

  data <- dplyr::as_tibble(data)

  class(data) <- unique(c("forager", class(data)))

  data
}
