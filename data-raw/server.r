function(input, output, session) {
  
  # create mapping file --------------------------------------------------------
  observeEvent(input$map_save, {
    if (input$source_path == "") {
      output$status <- renderText("Quellverzeichnis muss angegeben werden!")
    } else {
      source_path <- str_remove_all(input$source_path, '\\"')
      source_path <- str_remove_all(source_path, "\\'")
      if (dir.exists(source_path)) {
        out <- list.files(path = source_path, full.names = TRUE, recursive = TRUE)
        out <- str_sub(out, start = str_length(paste0(source_path, "/")) + 1)
        out <- data.frame(
          Quelldatei = out,
          Zielordner = NA,
          Zieldatei = NA
        )
        file <- file.path(source_path, "mapping_datei.xlsx")
        write_xlsx(out, file)
        file <- str_replace_all(file, "/", "\\\\")
        output$status <- renderText(paste0("Mapping Datei ", file, " erfolgreich erstellt."))
      } else {
        output$status <- renderText("Quellverzeichnis exisitert nicht!")
      }
    }
  })
  
  # check mapping file ---------------------------------------------------------
  check_file <- function(mapping) {
    check <- TRUE
    if (any(names(mapping)[1:3] != c("Quelldatei", "Zielordner", "Zieldatei"))) {
      output$status <- renderText("Die ersten drei Spalten der Mapping Datei müssen die folgenden Namen haben: Quelldatei, Zielordner, Zieldatei!")
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
      source_path <- str_remove_all(input$source_path, '\\"')
      source_path <- str_remove_all(source_path, "\\'")
      target_path <- str_remove_all(input$target_path, '\\"')
      target_path <- str_remove_all(target_path, "\\'")
      mapping <- read_xlsx(inFile$datapath, range = cell_cols("A:C"))
      if (!dir.exists(source_path)) {
        output$status <- renderText("Quellverzeichnis exisitert nicht!")
      } else if (!dir.exists(target_path)) {
        output$status <- renderText("Zielverzeichnis exisitert nicht!")
      } else {
        check <- check_file(mapping)
        if (check) {
          # create dirs --------------------------------------------------------
          dirs <- unique(mapping$Zielordner)
          dirs <- dirs[!is.na(dirs)]
          if (length(dirs) > 0) {
            dirs <- file.path(target_path, dirs)
            n <- length(dirs)
            withProgress(message = "Erstelle", value = 0, {
              for (i in seq(n)) {
                incProgress(1 / n, detail = paste0("Ordner ", i, "/", n))
                if (!dir.exists(dirs[[i]])) dir.create(dirs[[i]], recursive = TRUE)
              }
            })
          }
          
          # move files ---------------------------------------------------------
          mapping$Quelldatei <- file.path(source_path, mapping$Quelldatei)
          mapping$Zieldatei[!is.na(mapping$Zielordner)] <- file.path(mapping$Zielordner[!is.na(mapping$Zielordner)], mapping$Zieldatei[!is.na(mapping$Zielordner)])
          mapping$Zieldatei <- file.path(target_path, mapping$Zieldatei)
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
          file <- file.path(source_path, "Log_Kopieren.xlsx")
          write_xlsx(log_files, file)
          file <- str_replace_all(file, "/", "\\\\")
          output$status <- renderText(paste0("Kopieren abgeschlossen und Log Datei in ", file, " erstellt."))
        }
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
      source_path <- str_remove_all(input$source_path, '\\"')
      source_path <- str_remove_all(source_path, "\\'")
      mapping <- read_xlsx(inFile$datapath, range = cell_cols("A:C"))
      if (!dir.exists(source_path)) {
        output$status <- renderText("Quellverzeichnis exisitert nicht!")
      } else {
        check <- check_file(mapping)
        if (check) {
          
          
          # remove files -------------------------------------------------------
          mapping$Quelldatei <- file.path(source_path, mapping$Quelldatei)
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
          file <- file.path(source_path, "Log_Entfernen.xlsx")
          write_xlsx(log_files, file)
          file <- str_replace_all(file, "/", "\\\\")
          output$status <- renderText(paste0("Entfernen abgeschlossen und Log Datei in ", file, " erstellt."))
        }
      }
    } else {
      output$status <- renderText("Keine Mapping Datei ausgewählt!")
    }
  })
  
  # close session --------------------------------------------------------------
  session$onSessionEnded(function() {
    file.remove("ui.r")
    file.remove("server.r")
    stopApp()
  })
}