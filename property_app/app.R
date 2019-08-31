library(shiny)
require(tidyverse)
require(sf)
dubmap <- readRDS("../dub_map_full.rds")
ppr_sf <- readRDS("../ppr_sf.rds")
dublin_counties <- c("Fingal", "Dn Laoghaire-Rathdown", "Dublin City", 
                     "South Dublin", "Kildare County", "Wicklow County")
dub <- filter(ppr_sf, geo_county %in% dublin_counties)
elec <- readRDS("../electoral_district_aggregates.rds")
get_unique_values <- function(df, var) {
    r <- unique(eval(substitute(var), df))
}
year_uniq  <- get_unique_values(elec, year)
county_choices <- get_unique_values(elec, COUNTYNAME)
elec_name_uniq  <- get_unique_values(elec, EDNAME)
ui <- pageWithSidebar(
    headerPanel("Property Dashboard"),
    sidebarPanel(selectInput("year", "Year:", choices = year_uniq, selected="2018"),
                 checkboxGroupInput("county", "Year:", choices = county_choices,
                                    selected=county_choices),
                 sliderInput("price", "Price", min=0, max=2e6, value=c(0, 300000))
                 ),
    mainPanel(
        plotOutput("map", width="800px", height="800px")
    )

)

server <- function(input, output) {
    
    output$map <- renderPlot({
        ggmap::ggmap(dubmap)+geom_point(data=filter(ppr_sf, year==input$year, price>input$price[1],  price<input$price[2]), aes(x=longitude, y=latitude, colour=(price)))
    })

}

shinyApp(ui, server)
