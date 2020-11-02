#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 12 14:25:40 2020

@author: alice
"""

import dash
import dash_core_components as dcc
import dash_html_components as html
import pandas as pd
import plotly.express as px
from dash.dependencies import Input, Output

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

df = pd.read_csv('data/2015_tree_sub.csv')

#initialize app
app= dash.Dash(__name__, external_stylesheets = external_stylesheets)


app.layout = html.Div([
    dcc.Graph(id='graph-with-slider'),
    dcc.Slider(
        id='boro-slider',
        min=df['borough'].min(),
        max=df['borough'].max(),
        value=df['borough'].min(),
        marks={str(borough): str(borough) for borough in df['borough'].unique()},
        step=None
    )
])


@app.callback(
    Output('graph-with-slider', 'figure'),
    [Input('boro-slider', 'value')])
def update_figure(selected_boro):
    filtered_df = df[df.borough == selected_boro]

    fig = px.scatter(filtered_df, x="steward", y="health", 
                     color="borough", hover_name="spc_common"
                     )

    fig.update_layout(transition_duration=500)

    return fig
    
if __name__ == '__main__':
    app.run_server(debug=True)