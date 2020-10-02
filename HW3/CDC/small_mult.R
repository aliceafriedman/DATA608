library(plotly)
library(dplyr)


#load data
df <- read.csv('data/cleaned-cdc-mortality-1999-2010-2.csv') 
df$State <- factor(df$State)
df <- df %>% arrange(ICD.Chapter, -Crude.Rate)

#test params
cause <- "Certain infectious and parasitic diseases"
slice <- df %>% filter(ICD.Chapter == cause, State == 'NV') %>% arrange(Year)


#define function to generate map

MAP <- function(slice){
  
  fig <- plotly::plot_geo(slice, 
                  locationmode = 'USA-states'
                  )
  
  fig <- fig %>% plotly::add_trace(
    showscale = FALSE,
    z = ~Crude.Rate, 
    locations = ~State,
    color = ~Crude.Rate, 
    colors = 'Purples',
    hovertemplate = paste('<b>State</b></i>: ', slice$State, '<br>',
                          '<i><b>Deaths per 100k: ', slice$Crude.Rate, '</b></i><br>',
                          'Population: ', format(slice$Population, big.mark=","), '<br>',
                          'Total Deaths: ', slice$Deaths)
  )
  
  #map params
  g <-list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showlakes = TRUE,
    lakecolor = toRGB('white')
  )
  
  #layout
  fig <- fig %>% plotly::layout(title = slice$Year, 
                                margin = list(l = 50, r = 50, b = 100, t = 100, pad = 4),
                                geo=g)
  
  return(fig)
  
}

#define function to generate single figure

LINE <- function(slice){
  fig <- plot_ly(slice, x = ~Year, y = ~Crude.Rate, type = 'scatter', mode = 'lines')
  fig
}

#define function to generate small multiples

MULT <- function(slice){
  slice <- slice %>% group_by(State)
  
  #create dataframe of figures, using single geo for consistent colorscale
  df_fig <- slice %>% do(mafig = LINE(.)) 

  #generate subplots  
  fig <- df_fig %>% subplot(nrows = 5)

  return(fig)

}