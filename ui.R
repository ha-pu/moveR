library(readxl)
library(shiny)
library(stringr)
library(writexl)

fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      textInput(
        inputId = "source_path",
        label = "Quellenverzeichnis:"
      ),
      br(),
      textInput(
        inputId = "target_path",
        label = "Zielverzeichnis:"
      ),
      br(),
      actionButton(
        inputId = "map_save",
        label = "Mapping Datei erstellen"
      ),
      br(),
      fileInput(
        inputId = "map_file",
        label = NULL,
        accept = c(".xlsx"), 
        multiple = FALSE, 
        buttonLabel = "Durchsuchen", 
        placeholder = "Keine Datei ausgewählt"
        ),
      actionButton(
        inputId = "map_load",
        label = "Mapping Datei laden"
      )
    ),
    
    mainPanel(
      textOutput(outputId = "source_path"),
      br(),
      textOutput(outputId = "target_path"),
      br(),
      textOutput(outputId = "status")
    )
  )
)
