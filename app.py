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
    dcc.Dropdown(
            id='boro-choice',
            options=[
            {'label': 'New York City', 'value': 'All'},
            {'label': 'Bronx', 'value': 'Bronx'},
            {'label': 'Brooklyn', 'value': 'Brooklyn'},
            {'label': 'Manhattan', 'value': 'Manhattan'},
            {'label': 'Queens', 'value': 'Queens'},
            {'label': 'Staten Island', 'value': 'Staten Island'}
            ],
            value='All'),
    html.Div([
        html.Div([
            dcc.Graph(id='graph-stew'), 
            dcc.Dropdown(
                id='y-choice',
                options=[
                    {'label': 'View Proportion of Trees by Health', 'value': 'Proportion'},
                    {'label': 'View Number of Trees by Health', 'value': 'Count'},
                    ],
                value='Count')],
            className="six columns"),
        html.Div(dcc.Graph(id='pie-chart'), className="six columns"),
        ], className="row")
    ])


@app.callback([
    Output('pie-chart', 'figure'),
    Output('graph-stew', 'figure')
    ],
    [Input('boro-choice', 'value'),
     Input('y-choice', 'value')]
    )
def update_figure(selected_boro, selected_y):
    if selected_boro == 'All':
        data=df
    else:
        data = df[df['borough']==selected_boro]
   
    def update_pie():
    
        #create pivot table
        pie = data[['tree_id', 'health']].pivot_table(index="health", aggfunc="count").reset_index()
        pie = pie.assign(
                prop = pie['tree_id']/pie['tree_id'].sum()
                )
        pie = pie.rename(columns = {'tree_id' :'count'})
        
        #create fig
        fig = px.pie(pie, 
                     values='count', 
                     names='health', 
                     title='Share of Street Trees by Condition, ' + selected_boro,
                     hover_name="health"
                     )
        
        fig.update_layout(transition_duration=500)
        
        return fig
    def update_chart():
        stew_map = {
            'None' : 'None',
            '1or2' : '1 or 2',
            '3or4' : '3 or 4',
            '4orMore' : '4+'
            }

        table = data[['tree_id', 'health', 'steward']].pivot_table(index="health", columns="steward", aggfunc="count").unstack().reset_index()

        table = table.rename(columns={
            0:'Count',
            'health':"Tree Health"})

        table = table.assign(
            steward = table['steward'].map(stew_map),
            Proportion = table['Count']/table.groupby('steward')['Count'].transform('sum')
        )
        
        fig = px.bar(table, 
             color="steward", 
             y=selected_y, 
             x="Tree Health", 
             title="NYC Street Trees by Health Status and No.Stewards (" + selected_y + ")", 
             barmode='group',
             category_orders={
                 "Tree Health": ["Poor", "Fair", "Good"],
                "steward": ["None", "1 or 2", '3 or 4', "4+"]},

             )
        
        return fig
    
    return update_pie(), update_chart()

app.css.append_css({
    'external_url': 'https://codepen.io/chriddyp/pen/bWLwgP.css'
}) #https://community.plotly.com/t/two-graphs-side-by-side/5312/2
    
if __name__ == '__main__':
    app.run_server(debug=True)