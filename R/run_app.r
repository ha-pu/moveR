#' @importFrom readr write_lines
#' @importFrom shiny runApp
#' @export

# start app --------------------------------------------------------------------
run_app <- function(id) {
  write_lines(moveR::ui, file = "ui.r")
  write_lines(moveR::server, file = "server.r")
  runApp(launch.browser = TRUE)
}
