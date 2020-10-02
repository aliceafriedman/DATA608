library(dplyr)
library(plotly)

###### DATA PREP #######

#load data
df <- read.csv('data/cleaned-cdc-mortality-1999-2010-2.csv') 
df$State <- factor(df$State)
df <- df %>% arrange(ICD.Chapter, -Crude.Rate)

#create data slice based on inputs
SLICE<- function(cause, year){
  
  #filter data
  slice <- df %>%
    filter(ICD.Chapter == cause,
           Year == year)
  

  return (slice)
} 



###### MAP ########

#create figure
FIG <- function(slice){
  fig <- plot_geo(slice, locationmode = 'USA-states')
  
  fig <- fig %>% add_trace(
    
    z = ~Crude.Rate, 
    locations = ~State,
    color = ~Crude.Rate, colors = 'Purples',
    
    hovertemplate = paste('<b>State</b></i>: ', slice$State, '<br>',
                          '<i><b>Deaths per 100k: ', slice$Crude.Rate, '</b></i><br>',
                          'Population: ', format(slice$Population, big.mark=","), '<br>',
                          'Total Deaths: ', slice$Deaths)
  )
  
  
  fig <- fig %>% colorbar()
  
  fig_title <- paste( slice$ICD.Chapter[1], '<br>',
                      slice$Year[1], 'Deaths per 100,000 Residents By State'
                     )

  fig <- fig %>% layout(
    title = fig_title,
    geo = list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    ),
    showlegend = FALSE
  )
  return(fig)
  
}

#test
#cause <- "Certain infectious and parasitic diseases"
#year <- 2010
#slice <- SLICE(cause, year)
#FIG(slice)
