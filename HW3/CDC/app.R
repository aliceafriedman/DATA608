###################################################################
#SETUP
###################################################################

library(shiny)
source('small_mult.R')



###################################################################
#UI
###################################################################

ui <- fluidPage(

  titlePanel('CDC Data 2010, Deaths per 100,000 by State'),
  
  fluidRow(
    column(12, 
           selectInput("cause", 
                       "Choose Cause of Death for Visualization", 
                       unique(df$ICD.Chapter), 
                       width = '100%') 
           )
    ),
  
  fluidRow(
    column(12, plotlyOutput('plot1') )
    ),
  
  fluidRow(
    column(12, plotlyOutput('plot2') )
  )
)


###################################################################
#SERVER
###################################################################

server <- function(input, output, session) {
  
  output$plot1 <- renderPlotly({ 
    
    slice <- df %>% dplyr::filter(ICD.Chapter == input$cause, Year == 2010)
    MAP(slice)  %>% layout (geo=g)
   
  })
  
  output$plot2 <- renderPlotly({ 
    
    slice2 <- df %>% dplyr::filter(ICD.Chapter == input$cause) %>% 
      group_by(State) %>%
      arrange(Year)
  
    MULT(slice2) 
    
  })
}


###################################################################

shinyApp(ui = ui, server = server)