function(input, output, session) {
  
  # create mapping file --------------------------------------------------------
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
      write_xlsx(out, file)
      output$status <- renderText(paste0("Mapping Datei ", file, " erfolgreich erstellt."))
    }
  })
  
  # check mapping file ---------------------------------------------------------
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
  
  # copy files -----------------------------------------------------------------
  observeEvent(input$copy, {
    output$status <- renderText("")
    inFile <- input$map_file
    if (!is.null(inFile)) {
      mapping <- read_xlsx(inFile$datapath)
      
      check <- check_file(mapping)
      
      if (check) {
        
        # create dirs ----------------------------------------------------------
        dirs <- unique(mapping$Zielordner)
        dirs <- dirs[!is.na(dirs)]
        if (length(dirs) > 0) {
          dirs <- file.path(input$target_path, dirs)
          n <- length(dirs)
          withProgress(message = "Erstelle", value = 0, {
            for (i in seq(n)) {
              incProgress(1 / n, detail = paste0("Ordner ", i, "/", n))
              if (!dir.exists(dirs[[i]])) dir.create(dirs[[i]], recursive = TRUE)
            }
          })
        }
        
        # move files -----------------------------------------------------------
        mapping$Quelldatei <- file.path(input$source_path, mapping$Quelldatei)
        mapping$Zieldatei[!is.na(mapping$Zielordner)] <- file.path(mapping$Zielordner[!is.na(mapping$Zielordner)], mapping$Zieldatei[!is.na(mapping$Zielordner)])
        mapping$Zieldatei <- file.path(input$target_path, mapping$Zieldatei)
        n <- length(mapping$Quelldatei)
        output_files <- vector(length = n)
        withProgress(message = "Kopiere", value = 0, {
          for (i in seq(n)) {
            incProgress(1 / n, detail = paste0("Datei ", i, "/", n))
            output_files[[i]] <- file.copy(from = mapping$Quelldatei[[i]], to = mapping$Zieldatei[[i]], overwrite = FALSE)
          }
        })
        log_files <- data.frame(
          Quelldatei = mapping$Quelldatei,
          Status = "Fehler"
        )
        log_files$Quelldatei <- str_replace_all(log_files$Quelldatei, "/", "\\\\")
        log_files$Status[output_files] <- "Erfolg"
        file <- file.path(input$source_path, "Log_Kopieren.xlsx")
        write_xlsx(log_files, file)
        output$status <- renderText(paste0("Kopieren abgeschlossen und Log Datei in ", file, " erstellt."))
      }
    } else {
      output$status <- renderText("Keine Mapping Datei ausgewählt!")
    }
  })
  
  # remove files ---------------------------------------------------------------
  observeEvent(input$remove, {
    output$status <- renderText("")
    inFile <- input$map_file
    if (!is.null(inFile)) {
      mapping <- read_xlsx(inFile$datapath)
      
      check <- check_file(mapping)
      
      if (check) {
        
        # remove files -----------------------------------------------------------
        mapping$Quelldatei <- file.path(input$source_path, mapping$Quelldatei)
        n <- length(mapping$Quelldatei)
        output_files <- vector(length = n)
        withProgress(message = "Entferne", value = 0, {
          for (i in seq(n)) {
            incProgress(1 / n, detail = paste0("Datei ", i, "/", n))
            output_files[[i]] <- file.remove(mapping$Quelldatei[[i]])
          }
        })
        log_files <- data.frame(
          Quelldatei = mapping$Quelldatei,
          Status = "Fehler"
        )
        log_files$Quelldatei <- str_replace_all(log_files$Quelldatei, "/", "\\\\")
        log_files$Status[output_files] <- "Erfolg"
        file <- file.path(input$source_path, "Log_Entfernen.xlsx")
        write_xlsx(log_files, file)
        output$status <- renderText(paste0("Entfernen abgeschlossen und Log Datei in ", file, " erstellt."))
      }
    } else {
      output$status <- renderText("Keine Mapping Datei ausgewählt!")
    }
  })
}