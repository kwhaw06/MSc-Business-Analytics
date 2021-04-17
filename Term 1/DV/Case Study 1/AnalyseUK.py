# %% import library
import os
import pandas as pd
import geopandas as gp
import matplotlib.pyplot as plt
from matplotlib import rc
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import contextily as ctx

# %% basic set-up
rc('font',**{'size' : 10})

# %% import data
# geo data
wd = os.getcwd()
infile = os.path.join(wd, 'dataset',
    'NUTS_Level_1__January_2018__Boundaries-shp',
    'NUTS_Level_1__January_2018__Boundaries.shp')
df1 = gp.read_file(infile)

# rename the regions
df1.loc[0, 'nuts118nm'] = 'North East England'
df1.loc[1, 'nuts118nm'] = 'North West England'
df1.loc[2, 'nuts118nm'] = 'Yorkshire and the Humber'
df1.loc[3, 'nuts118nm'] = 'East Midlands'
df1.loc[4, 'nuts118nm'] = 'West Midlands'
df1.loc[7, 'nuts118nm'] = 'South East England'
df1.loc[8, 'nuts118nm'] = 'South West England'

# pay gap data
infile = os.path.join(wd, 'pay_gaps_uk_by_regions.csv')
df2 = pd.read_csv(infile)

# merge the dataframe
df = pd.merge(df1, df2, left_on = 'nuts118nm', right_on = 'Region')

# %% plot the geo pay gap
# conver the data to Web Mercator
df = df.to_crs(epsg = 3857)

# set up the figure and subplot
fig = plt.figure(figsize = (20, 20))
ax = fig.add_subplot(1, 1, 1)

# plot the pay gap by regions
df.plot(column = 'DiffMeanPercent',
    scheme = 'FisherJenks',
    legend = True,
    legend_kwds = {'loc' : 'upper left', 'fontsize' : 20},
    cmap = 'Blues',
    edgecolor = 'k',
    alpha = 0.5,
    ax = ax
    )

# add basemap
ctx.add_basemap(ax)

# add the name of regions
df['coords'] = df['geometry'].apply(lambda x: x.representative_point()
    .coords[0])
#df.loc[6, 'Region'] = ''
for n, i in enumerate(df['coords']):
    if df['Region'][n] != 'London':
        plt.text(i[0], i[1],
            df['Region'][n],
            ha = 'center',
            fontweight = 'bold')

# set the axis
ax.axis('off')

# inset plot of London
axins = inset_axes(ax, width = 2.3, height = 2.3, loc = 4)
df_london = df[df['Region'] == 'London']
df_london.plot(ax = axins, alpha = 0.5,
    edgecolor = 'k', color = 'darkslategrey')
ctx.add_basemap(axins)
x, y = df_london.loc[6, 'coords'][0], df_london.loc[6, 'coords'][1]
plt.text(x, y, 'London', ha = 'center',
    fontsize = 16, fontweight = 'bold')
axins.axis('off')

# set the title
ax.set_title('Gender Pay Gap of UK by Regions',\
    fontsize = 20, fontweight = 'bold')

# save the plot
outfile = os.path.join(wd, 'gap_by_regions.png')
plt.savefig(outfile)

# show the plot
#plt.show()
