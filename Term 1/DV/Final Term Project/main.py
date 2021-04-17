# %% import libraries
# os mathods to manipulate paths
from os.path import dirname, join

# glob to read file
from glob import glob

# pandas for data management
import pandas as pd
import geopandas as gp
import contextily as ctx

# bokeh basics
from bokeh.io import curdoc, output_file
from bokeh.models.widgets import Tabs

# import tabs
from scripts.emergence_tab import emergence_tab
from scripts.transformation_tab_1 import transformation_tab

# %% load data
# company data
companies = pd.read_csv(
    glob(join(dirname(__file__), 'data', 'company_data.csv'))[0])

# founders data
founders = pd.read_csv(
    glob(join(dirname(__file__), 'data', 'london_data.csv'))[0])

# Islington post data
df_islington = gp.read_file(
    glob(join(dirname(__file__), 'data',
        'Code-Point London Borough (shapefile)', 'Islington.shp'))[0])

# Hackney post data
df_hackney = gp.read_file(
    glob(join(dirname(__file__), 'data',
        'Code-Point London Borough (shapefile)', 'Hackney.shp'))[0])

# industry data
industry = pd.read_csv(
    glob(join(dirname(__file__), 'data', 'SIC_Code.csv'))[0])

# world map data
world = gp.read_file(
    glob(join(dirname(__file__), 'data', 'word_map',
        'World_Countries__Generalized_.shp'))[0])

# nation data
nation = pd.read_csv(
    glob(join(dirname(__file__), 'data', 'country.csv'))[0])

# %% clean data
# get gis for tech city
df_hackney_tech_city = df_hackney[df_hackney[
    'postcode'].str[0:4] == 'EC1V']
df_islington_tech_city = df_islington[df_islington[
    'postcode'].str[0:4] == 'EC1V']
df_tc = pd.concat([df_hackney_tech_city, df_islington_tech_city])
df_tc = df_tc.loc[:, ['postcode', 'geometry']]
df_tc = df_tc.to_crs(epsg = 3857)
df_tc.loc[:, 'geometry'] = df_tc['geometry'].astype(str)
df_tc.loc[:, 'x'] = df_tc['geometry'].str.split().str[1].str[1:].astype(float)
df_tc.loc[:, 'y'] = df_tc['geometry'].str.split().str[2].str[:-1].astype(float)

#  get gis for world map
#world = world.to_crs(epsg = 3857)

# clean founders
founders = founders.loc[:, ['RegAddress.PostCode', 'IncorporationDate',
    'date_of_birth.year', 'name', 'nationality']]

# %% create each of the tabs
tab1 = emergence_tab(companies, founders, df_tc)
tab2 = transformation_tab(companies, founders, df_tc, industry, world, nation)

# %% put all tabs into one application
tabs = Tabs(tabs = [tab1, tab2])

# %% put the tabs in the current document for display
curdoc().add_root(tabs)
curdoc().title = 'Emergence and Transformation of Tech City'

#output_file('Tech-City.html')
