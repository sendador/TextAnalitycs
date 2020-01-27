library(shiny)
# Jest to miejsce w którym definiujemy widok oraz zmienne,
# które zostaną przekazane do części odpowiadającej za logikę
ui <- fluidPage(
  # Tytuł aplikacji
  titlePanel("Check the most common words in your text!"),
  
  # Panel boczny określający widok na wybór pliku
  sidebarLayout(
    sidebarPanel(
      fileInput(
        "wc",
        "Upload a file for your word cloud!",
        multiple = F,
        accept = "text/plain"
      ),
      sliderInput(
        "freq",
        "Minimum Frequency:",
        min = 1,
        max = 300,
        value = 20
      ),
      sliderInput(
        "max_words",
        "Maximum number of words:",
        min = 1,
        max = 500,
        value = 100
      ),
    ),
    
    # Panel główny, który wyświetli żądaną chmurę słów
    mainPanel(plotOutput("wcplot"))
  )
)