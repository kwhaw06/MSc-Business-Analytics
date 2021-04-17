# %% import libraries
import os
import pandas as pd
import numpy as np

# %% load the data
# load the dataset
wd = os.getcwd()
infile = os.path.join(wd, 'dataset', 'pay-gaps-all-employers.csv')
df_UK = pd.read_csv(infile)
print(df_UK.columns)
# clean the dataset
df_UK = df_UK[['EmployerName', 'Address', 'DiffMeanHourlyPercent',
'DiffMeanBonusPercent']]
df_UK = df_UK.dropna()

# %% get the postcode
df_UK.loc[:, 'Postcode'] = ''
for i in df_UK.index:
    address = str(df_UK.loc[i, 'Address']).split()
    df_UK.loc[i, 'Postcode'] = address[-2].upper()

# %% load the region data and get the region for employers
# load the region data
infile = os.path.join(wd, 'dataset', 'PostCode-Assignments.csv')
df_Region = pd.read_csv(infile).set_index('Prefix')

# get the region
df_UK.loc[:, 'Region'] = ''
for i in df_UK.index:
    postcode = df_UK.loc[i, 'Postcode']
    df_UK.loc[i, 'Region'] = df_Region.loc[postcode, 'Region']

# %% get the mean pay gap by regions
df_UK.loc[:, 'DiffMeanPercent'] = df_UK['DiffMeanHourlyPercent'] * (1 + df_UK['DiffMeanBonusPercent'] / 100)
df_by_regions = pd.DataFrame(df_UK.groupby(['Region'])
    ['DiffMeanPercent'].aggregate(np.mean))
df_by_regions = df_by_regions.drop(labels = ['Channel Islands', 'Isle of Man'])
df_by_regions = df_by_regions.reset_index()
print(df_by_regions)

# %% save the dataset
outfile = os.path.join(wd, 'pay_gaps_uk_by_regions.csv')
df_by_regions.to_csv(outfile, index = False)
