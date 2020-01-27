library(shiny) #Biblioteka frameworka Shiny
library(tm)    #Biblioteka potrzebna do wyczyszczenia tekstu
library(wordcloud) #Biblioteka potrzebna do stworzenia chmury tekstu

# Jest to miejsce odpowiadające za całą logikę strony
server <- function(input, output, session) {
    wc_data <- reactive({
        # Pobranie zmiennej wc zadeklarowanej w FileInput w ui.R
        input$wc
        # Pasek progressu jest potrzebny aby w ładny sposób wyświetlić plik, który będzie się przetwarzać
        withProgress({
            # Wiadomość dla użytkownika, że dane są wciąż przetwarzane
            setProgress(message = "Still processing...")
            # Deklaracja zmiennej wc_file dla dalszej pracy na pliku tekstowym
            wc_file <- input$wc
            # Sprawdzenie czy plik aktualnie jest pusty. Dzieje się to podczas załadowania strony
            if (!is.null(wc_file)) {
                # Jeżeli nie jest pusty (!is.null - nie jest nullem) to czytaj linię
                wc_text <- readLines(wc_file$datapath)
                wc_text <- gsub("[^0-9A-Za-z///' ]","'" , wc_text ,ignore.case = TRUE)
                wc_text <- gsub("''","" , wc_text ,ignore.case = TRUE)
                
            }
            # W innym wypadku -> Wyświetl przykładową chmurę zbudowaną z krótkiego tekstu
            else{
                wc_text <- "crated Kamil Ulfik"
            }
            # Zmiana tekstu w korpus dla ułatwienia pracy przy czyszczeniu tekstu
            wc_corpus <- VCorpus(VectorSource(wc_text))
            # Deklaracja funkcji, która zamieni znaki specjalne na spacje
            toSpace <-
                content_transformer(function (x , pattern)
                    gsub(pattern, " ", x))
            wc_corpus <- tm_map(wc_corpus, toSpace, "/")
            wc_corpus <- tm_map(wc_corpus, toSpace, "@")
            wc_corpus <- tm_map(wc_corpus, toSpace, "\\|")
            # Zmiana tekstu na małe litery. Ma to zapobiec liczeniu osobno
            wc_corpus <-
                tm_map(wc_corpus, content_transformer(tolower))
            # Usunięcie liczb
            wc_corpus <- tm_map(wc_corpus, removeNumbers)
            # Usunięcie popularnych słów w j. angielskim jak np. with
            wc_corpus <-
                tm_map(wc_corpus, removeWords, stopwords("english"))
            # Usunięcie interpunkcji
            wc_corpus <- tm_map(wc_corpus, removePunctuation)
            # Usunięcię białych znaków np. spacji
            wc_corpus <- tm_map(wc_corpus, stripWhitespace)
            
        })
    })
    # repeatable to generator potrzebny funkcji wordcloud
    wordcloud_rep <- repeatable(wordcloud)
    # W tym miejscu przekazane są parametry wykresu
    output$wcplot <- renderPlot({
        # Pasek postępu jest tutaj z takich samych powodów jak wyzej
        withProgress({
            setProgress(message = "Creating a plot...")
            # Dane z funkcji wc_data (linia7) są tutaj przekazane
            wc_corpus <- wc_data()
            # Parametry wykresu
            wordcloud(wc_corpus,
                          min.freq = input$freq, max.words=input$max_words,
                          colors=brewer.pal(8, "Dark2"))
        })
        
    })
    
}
