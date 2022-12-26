function(input, output, session) {
    output$source_path <- renderText({
      input$source_path
    })
    
    output$target_path <- renderText({
      input$target_path
    })
    
    observeEvent(input$map_save, {
      if (input$source_path == "") {
        output$status <- renderText("Quellverzeichnis muss angegeben werden!")
      } else {
        out <- list.files(path = input$source_path, full.names = TRUE, recursive = TRUE)
        out <- str_sub(out, start = str_length(paste0(input$source_path, "/")) + 1)
        out <- data.frame(
          Quelldatei = out,
          Zielordner = NA,
          Zieldatei = NA
        )
        file <- file.path(input$source_path, "mapping_datei.xlsx")
        write_xlsx(out, path = file)
        output$status <- renderText(paste0("Mapping Datei ", file, " erfolgreich erstellt."))
      }
    })
    
    check_file <- function(mapping) {
      check <- TRUE
      if (any(names(mapping) != c("Quelldatei", "Zielordner", "Zieldatei"))) {
        output$status <- renderText("Die Mapping Datei muss die folgenden Spalten haben: Quelldatei, Zielordner, Zieldatei!")
        check <- FALSE
      }
      
      if (check & any(is.na(mapping$Quelldatei))) {
        output$status <- renderText("Die Spalte Quelldatei darf keine fehlenden Werte enthalten!")
        check <- FALSE
      }
      
      if (check & any(is.na(mapping$Zieldatei))) {
        output$status <- renderText("Die Spalte Zieldatei darf keine fehlenden Werte enthalten!")
        check <- FALSE
      }
      return(check)
    }
    
    move_files <- function(mapping) {
      mapping$Quelldatei <- file.path(input$source_path, mapping$Quelldatei)
      mapping$Zieldatei <- file.path(input$target_path, mapping$Zieldatei)
      for (i in seq_along(mapping$Quelldatei)) {
        file.copy(from = mapping$Quelldatei[[i]], to = mapping$Zieldatei[[i]], overwrite = FALSE)
      }
    }
    
    observeEvent(input$map_load, {
      inFile <- input$map_file
      if (is.null(inFile)) {
        return(NULL)
      }
      mapping <- read_xlsx(inFile$datapath)
      
      check <- check_file(mapping)
      
      if (check) {
        move_files(mapping)
      }
    })
}
