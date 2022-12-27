library(readxl)
library(shiny)
library(stringr)
library(writexl)

fluidPage(
  fluidRow(
    h2("Eingaben")
  ),
  fluidRow(
    column(
      width = 4,
      textInput(
        inputId = "source_path",
        label = "Quellenverzeichnis:"
      )
    ),
    column(
      width = 4,
      textInput(
        inputId = "target_path",
        label = "Zielverzeichnis:"
      )
    ),
    column(
      width = 4,
      fileInput(
        inputId = "map_file",
        label = NULL,
        accept = c(".xlsx"), 
        multiple = FALSE, 
        buttonLabel = "Durchsuchen", 
        placeholder = "Keine Datei ausgewählt"
      )
    )
  ),
  fluidRow(
    hr(),
    br(),
    h2("Funktionen")
  ),
  fluidRow(
    column(
      width = 4,
      actionButton(
        inputId = "map_save",
        label = "Mapping Datei erstellen"
      )
    ),
    column(
      width = 4,
      actionButton(
        inputId = "copy",
        label = "Dateien kopieren"
      )
    ),
    column(
      width = 4,
      actionButton(
        inputId = "remove",
        label = "Dateien löschen"
      )
    )
  ),
  fluidRow(
    hr(),
    br(),
    h2("Ergebnisse")
  ),
  fluidRow(
    textOutput(outputId = "status")
  )
)
