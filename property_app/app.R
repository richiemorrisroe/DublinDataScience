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
year_uniq  <- (get_unique_values(elec, year))
county_choices <- get_unique_values(elec, COUNTYNAME)
elec_name_uniq  <- get_unique_values(elec, EDNAME)
address_uniq <- get_unique_values(ppr_sf, input_string)
ui <- pageWithSidebar(
    headerPanel("Property Dashboard"),
    sidebarPanel(selectInput("year", "Year:", choices = year_uniq, selected="2018"),
                 radioButtons("switch", "Map or Address View", choices=list("map", "address")),

                 checkboxGroupInput("county", "Location:",
                                    choices = county_choices,
                                    selected=county_choices),
                 sliderInput("price", "Price",
                             min=0, max=1e6, value=c(0, 300000)),
                 selectizeInput("add", "Address:",
                                choices=address_uniq,
                                selected=address_uniq[1],
                                multiple=TRUE)
                 ),
    mainPanel(
            plotOutput("map", width="600px", height="600px"),
            tableOutput("add_df")
        
    )

)

server <- function(input, output, session) {

    output$map <-
        renderPlot({
            if(input$switch=="map") {
        ggmap::ggmap(dubmap)+geom_point(data=filter(ppr_sf, year==input$year, price>input$price[1],  price<input$price[2], geo_county %in% input$county), aes(x=longitude, y=latitude, colour=(price))) }
    })



    output$add_df <- renderTable(
            if (input$switch=="address"){
                filter(ppr_sf, grepl(input$add, x=input_string))
            })

}

shinyApp(ui, server)
