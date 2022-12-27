server <- readr::read_lines("data-raw/server.r")
save(server, file = "data/server.rda")

ui <- readr::read_lines("data-raw/ui.r")
save(ui, file = "data/ui.rda")
