#!/usr/bin/env python
# coding: utf-8

# In[1]:


import dash
import dash_core_components as dcc
import dash_html_components as html


# In[8]:


app = dash.Dash()

#Create dict for CSS vals
css = {
    'background': '#111111',
    'text_color': '#7FDBFF',
    'textAlign': 'center'
}

app.layout = html.Div(
    style = {
        'backgroundColor' : css['background'], 
        'textAlign' : css['textAlign']}, 
    children = [
        html.H1(
            children = 'Hello Dash'
        ),
        html.Div(
            style={'color': css['text_color']},
            children='Dash: A web application framework for Python.'
        ),
        dcc.Graph(
            id='Graph1',
            figure = {
                'data' : [
                    {'x': [1, 2, 3], 'y': [4, 1, 2], 'type': 'bar', 'name': 'SF'},
                    {'x': [1, 2, 3], 'y': [2, 4, 5], 'type': 'bar', 'name': u'Montréal'}
                ],
                'layout': {
                    'plot_bgcolor': css['background'],
                    'paper_bgcolor': css['background'],
                    'font': {'color': css['text_color']}
                
            }}
        )
    ]
)


if __name__ == '__main__':
    app.run_server(debug=True)
        
        


# In[ ]:




