library(plotly)
library(dplyr)
library(reshape)
library(tidyr)

####### Set up #############
#load and prep data
df_raw <- read.csv('data/cleaned-cdc-mortality-1999-2010-2.csv') 

df <- df_raw %>% 
  arrange(ICD.Chapter, -Crude.Rate) 

df$State <- factor(df$State)
df$year <- factor(df$Year, levels = seq(1999, 2010, 1))

USA <- df %>% 
  group_by(ICD.Chapter, Year) %>%
  summarize(State= 'USA',
            Crude.Rate = sum(Deaths)/sum(Population)*100000, 
            Population = sum(Population),
            Deaths = sum(Deaths)
            ) %>% 
  rbind(df) %>% 
  arrange(Year)

########## Functions ##########

#define function to generate map

MAP <- function(slice){
  
  fig <- plotly::plot_geo(slice, 
                  locationmode = 'USA-states'
                  )
  
  fig <- fig %>% plotly::add_trace(
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
  g <- list(scope = 'usa', 
            projection = list(type = 'albers usa'), 
            showlakes = TRUE, 
            lakecolor = toRGB('white')
            )
  
  #layout
  fig <- fig %>% plotly::layout(geo=g) %>% colorbar(title = "Deaths per 100,000")
  
  return(fig)
  
}

#define function to generate line chart


LINE <- function(cause, state_list){
  usa <- USA %>% 
    dplyr::filter(ICD.Chapter==cause) %>%
    ungroup() %>% group_by(Year) %>%
    dplyr::filter(ICD.Chapter == cause) %>%
    select(Year, State, Crude.Rate) %>%
    cast(Year ~ State, fill=NA)  
  
  fig <- plot_ly(usa, 
                 x = ~Year, 
                 y = ~USA, 
                 type = 'scatter', 
                 mode = 'lines', 
                 name="USA Average", 
                 line = list(width = 4) 
                 )  %>%
    layout(yaxis = list(rangemode = "tozero", title = "Deaths per 100,000 Pop.", fixedrange=TRUE),
           xaxis = list(fixedrange=TRUE)
    )
  
  for (state in state_list){
      print(state)
      fig <- fig %>% 
        add_trace(x = ~Year, 
                  y = as.formula(paste0("~`", state, "`")), 
                  name = state, 
                  mode = 'lines',
                  line = list(width = 1) 
                  )
    }
  
  #print(head(usa))
  return(fig) 
}


#############
#test
cause <- "Pregnancy, childbirth and the puerperium"
dft <- df %>% dplyr::filter(ICD.Chapter == cause)
state_list <- c("AK", "TX", "AL")
LINE(cause, state_list)
