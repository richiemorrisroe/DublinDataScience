library(shiny)
ui <- pageWithSidebar(
    headerPanel("Property Dashboard"),
    sidebarPanel(),
    mainPanel()

)

server <- function(input, output) {

}

shinyApp(ui, server)
