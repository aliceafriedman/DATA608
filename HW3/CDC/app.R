###################################################################
#SETUP
###################################################################

library(shiny)
source('helpers.R')



###################################################################
#UI
###################################################################

ui <- fluidPage(
  
  titlePanel('Mortality Rates by State and Cause of Death'),
  
  sidebarLayout(
    sidebarPanel(
      fluidRow(column(12, selectInput("cause", 
                       "Choose cause of death for visualization", 
                       unique(df$ICD.Chapter), 
                       width = '100%'))),
      uiOutput('states')
      #fluidRow(column(12, checkboxGroupInput("state", 
      #                        "Choose states for comparison", 
      #                        choices = sort(unique(USA$State)), 
      #                        selected = 'DC')))
      ),#end sidebarPanel
    
    mainPanel(
      fluidRow(column(12, h3(textOutput('title1')), h4("Crude Mortality Rate by State, 2010"), p("Source: CDC Data"))),
      fluidRow(column(12, plotlyOutput('plot1'))),
      fluidRow(column(12, 
                      h4("Crude Mortality Rate by State Over Time, 1999-2010"), 
                      p("Deaths per 100,000 Residents.Source: CDC Data"),
                      p("Note: Some states missing data for some causes of death/years."))),
      fluidRow(column(12, plotlyOutput('plot2')))
      ), #end mainPanel 
    
    position = "right"
    
    )#end sidebarLayout

)#end fluidPage


###################################################################
#SERVER
###################################################################

server <- function(input, output, session) {
  
  choices <- reactive({
    partial_df <- df %>% dplyr::filter(ICD.Chapter==input$cause)
    state_list <- unique(partial_df$State) %>% sort()
    return(state_list)
  })
  
  output$states = renderUI({
    checkboxGroupInput('state', 'Choose states for comparison', choices(), selected="DC")
  })
  
  output$title1 <- renderText({
    paste("Cause of Death:", input$cause)
  })
  
  output$plot1 <- renderPlotly({ 
    slice <- df %>% dplyr::filter(ICD.Chapter == input$cause, Year == 2010)
    MAP(slice)
  })
  
  output$plot2 <- renderPlotly({ 
    LINE(input$cause, input$state)
  })
  
  
}


###################################################################

shinyApp(ui = ui, server = server)