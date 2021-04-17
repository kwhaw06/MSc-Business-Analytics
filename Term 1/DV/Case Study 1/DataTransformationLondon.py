# %% import libraries
import os
import pandas as pd

# %% load the data
wd = os.getcwd()
infile = os.path.join(wd, 'dataset', 'pay-gaps-london-employers.csv')
df_London = pd.read_csv(infile, skiprows = [0])

# %% clean data
# drop NA
df_London = df_London.loc[:, ['EmployerName', 'SicCodes',
    'DiffMeanHourlyPercent', 'DiffMeanBonusPercent', 'EmployerSize']]
df_London = df_London.dropna()
df_London = df_London[df_London['EmployerSize'] != 'Not Provided']

# split SIC code
df_London = df_London.set_index(['EmployerName', 'DiffMeanHourlyPercent',
    'DiffMeanBonusPercent', 'EmployerSize'])
df_London = df_London['SicCodes'].str.split(',', expand = True).stack()
df_London = df_London.reset_index(level = 4, drop = True)
df_London = df_London.reset_index(name = 'SicCodes')
df_London['SicCodes'] = df_London['SicCodes'].str[-5:]

# update siccode
df_London = df_London[df_London['SicCodes'] != '1']
for i in df_London.index:
    if len(df_London.loc[i, 'SicCodes']) == 4:
        df_London.loc[i, 'SicCodes'] = '0' + str(df_London.loc[i, 'SicCodes'])
    elif df_London.loc[i, 'SicCodes'] == '\n1630':
        df_London.loc[i, 'SicCodes'] = '01630'
    elif df_London.loc[i, 'SicCodes'] == '\n6200':
        df_London.loc[i, 'SicCodes'] = '06200'


# %% calculate mean wage diff percent
df_London.loc[:, 'DiffMeanPercent'] = df_London['DiffMeanHourlyPercent'] * (1 + df_London['DiffMeanBonusPercent'] / 100)

# %% get the sector
# load sector data
infile = os.path.join(wd, 'dataset', 'SIC_Code.csv')
df_SIC = pd.read_csv(infile).set_index('SICCode')
df_London.loc[:, 'SectionCode'] = df_London['SicCodes'].str[0:2]
df_London.loc[:, 'Section'] = ''
for i in df_London.index:
    code = int(df_London.loc[i, 'SectionCode'])
    df_London.loc[i, 'Section'] = df_SIC.loc[code, 'Section']

# %% save the data
df_London = df_London[['EmployerName', 'EmployerSize', 'Section',
    'DiffMeanPercent']]
outfile = os.path.join(wd, 'pay_gaps_london.csv')
df_London.to_csv(outfile, index = False)











