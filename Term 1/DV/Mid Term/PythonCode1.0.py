#!/user/bin/env python 3.8

'''
-------------------------------------------------------------------------------
 Data Analysis and Visualization of the UK Performance After the 2016 Brexit
-------------------------------------------------------------------------------
Author: Eric, Halios, Samuel, Yasmine and Isa
Dates: - created 30/10/2020
       - last change 10/11/2020
'''

# %% load the libraries
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import statsmodels.api as sm
from matplotlib import rc
from matplotlib.backends.backend_pdf import PdfPages
from datetime import datetime

# %% initial set up for matplotlib
rc('font',**{'size':8})

# %% get the working directory and file path
wd = os.getcwd()
infile = os.path.join(wd, 'financials__long_term.csv')

# %% load data
longTerm = pd.read_csv(infile)

# %% clean data for shareholder dimension analysis
# add year variable
longTerm.loc[:, 'year'] = longTerm['date'].str[0:4].astype('int')

# split into three dataframes by country
BritishLT = longTerm[longTerm['country'] == 'united kingdom']
GermanyLT = longTerm[longTerm['country'] == 'germany']
FranceLT = longTerm[longTerm['country'] == 'france']

# define a function to calculate the weighted average
def getWeightedMean(df):
    '''
    The function is designed to calculate the average number with weights.
    input: df --> the initial dataframe with data of 'company name','year', 'assets', 'operating' and 'debt_to_assets'
    output: dfMean --> the dataframe with results of weighted average of ROA and D/A by year
    '''
    timeList = sorted(list(set(df['year']))) # get the list of 'year'
    ROAList = [] # create an empty list to store the weighted average of ROA by years
    DAList = [] # create an empty list to store the weighted average of D/A by years
    for year in timeList: # calculate the weighted average year by year
        dataset = df[df['year'] == year]
        totalAssets = np.sum(dataset['assets'])
        wts = list(dataset['assets']) / totalAssets # set the 'assets' to be the weight
        weightedROAMean = np.average(dataset['operating'], weights = wts)
        ROAList.append(weightedROAMean)
        weightedDAMean = np.average(dataset['debt_to_assets'], weights = wts)
        DAList.append(weightedDAMean)
    dfMean = pd.DataFrame({ # create a dataframe to include 'year' and 'weighted average of ROA'
        'year' : timeList,
        'operating' : ROAList,
        'debt_to_assets' : DAList
        })
    return dfMean

# eliminate repeated data and calculate the weighted average
# clean by countries
# United Kingdom
dataB = pd.DataFrame(BritishLT.groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
operatingByYearforB = getWeightedMean(dataB)
# Germany
dataG = pd.DataFrame(GermanyLT.groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
operatingByYearforG = getWeightedMean(dataG)
#France
dataF = pd.DataFrame(FranceLT.groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
operatingByYearforF = getWeightedMean(dataF)

# clean by countries by industries
# United Kingdom
#consumer discretionary industry
dataBCD = pd.DataFrame(BritishLT[BritishLT['sector'] ==
    'consumer discretionary'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataBCDMean = getWeightedMean(dataBCD)
#consumer staples industry
dataBCS = pd.DataFrame(BritishLT[BritishLT['sector'] ==
    'consumer staples'].groupby(['company_name', 'year'])
    ['operating','assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataBCSMean = getWeightedMean(dataBCS)
#energy and materials industry
dataBEM = pd.DataFrame(BritishLT[BritishLT['sector'] ==
    'energy and materials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataBEMMean = getWeightedMean(dataBEM)
#financials industry
dataBFin = pd.DataFrame(BritishLT[BritishLT['sector'] ==
    'financials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataBFinMean = getWeightedMean(dataBFin)
#industrials industry
dataBInd = pd.DataFrame(BritishLT[BritishLT['sector'] ==
    'industrials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataBIndMean = getWeightedMean(dataBInd)
#utilities industry
dataBUti = pd.DataFrame(BritishLT[BritishLT['sector'] ==
    'utilities'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataBUtiMean = getWeightedMean(dataBUti)
##Germany
#consumer discretionary industry
dataGCD = pd.DataFrame(GermanyLT[GermanyLT['sector'] ==
    'consumer discretionary'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataGCDMean = getWeightedMean(dataGCD)
#consumer staples industry
dataGCS = pd.DataFrame(GermanyLT[GermanyLT['sector'] ==
    'consumer staples'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataGCSMean = getWeightedMean(dataGCS)
#energy and materials industry
dataGEM = pd.DataFrame(GermanyLT[GermanyLT['sector'] ==
    'energy and materials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataGEMMean = getWeightedMean(dataGEM)
#financials industry
dataGFin = pd.DataFrame(GermanyLT[GermanyLT['sector'] ==
    'financials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataGFinMean = getWeightedMean(dataGFin)
#industrials industry
dataGInd = pd.DataFrame(GermanyLT[GermanyLT['sector'] ==
    'industrials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataGIndMean = getWeightedMean(dataGInd)
#utilities industry
dataGUti =  pd.DataFrame(GermanyLT[GermanyLT['sector'] ==
    'utilities'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataGUtiMean = getWeightedMean(dataGUti)
##France
#consumer discretionary industry
dataFCD = pd.DataFrame(FranceLT[FranceLT['sector'] ==
    'consumer discretionary'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataFCDMean = getWeightedMean(dataFCD)
#consumer staples industry
dataFCS = pd.DataFrame(FranceLT[FranceLT['sector'] ==
    'consumer staples'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataFCSMean = getWeightedMean(dataFCS)
#energy and materials industry
dataFEM = pd.DataFrame(FranceLT[FranceLT['sector'] ==
    'energy and materials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataFEMMean = getWeightedMean(dataFEM)
#financials industry
dataFFin = pd.DataFrame(FranceLT[FranceLT['sector'] ==
    'financials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataFFinMean = getWeightedMean(dataFFin)
#industrials industry
dataFInd = pd.DataFrame(FranceLT[FranceLT['sector'] ==
    'industrials'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataFIndMean = getWeightedMean(dataFInd)
#utilities industry
dataFUti = pd.DataFrame(FranceLT[FranceLT['sector'] ==
    'utilities'].groupby(['company_name', 'year'])
    ['operating', 'assets', 'debt_to_assets'].aggregate(np.mean)).reset_index()
dataFUtiMean = getWeightedMean(dataFUti)

# %% draw plot for shareholder dimension analysis
# % First Page
# create plot
fig1 = plt.figure(figsize = (11.69, 8.27)) # design the figure to fit an A4 paper
fig1.suptitle('ROTA and D/A Analysis (1/2)', fontsize=20,
    fontweight='bold')

# set the layout of the figure
widths = [2, 0.2, 1, 1, 1] #width ratio
heights = [1, 1] #height ratio
gs = GridSpec(ncols = 5, nrows = 2, width_ratios = widths,
    height_ratios = heights, wspace = 0.2)

# create subplots
ax1 = fig1.add_subplot(gs[0:2, 0], facecolor = 'azure') #plot the weighted average ROA by countries
ax2 = fig1.add_subplot(gs[0, 2]) #plot the weighted average ROA in British by industry
ax3 = fig1.add_subplot(gs[0, 3]) #plot the weighted average ROA in Germany by industry
ax4 = fig1.add_subplot(gs[0, 4]) #plot the weighted average ROA in France by industry
ax5 = fig1.add_subplot(gs[1, 2]) #plot the weighted average D/A in British by industry
ax6 = fig1.add_subplot(gs[1, 3]) #plot the weighted average D/A in Germany by industry
ax7 = fig1.add_subplot(gs[1, 4]) #plot the weighted average D/A in France by industry

# plot the data
# ax1
ax1.plot(operatingByYearforB['year'], operatingByYearforB['operating'],
    label = 'United Kingdom WARTA',marker = 'o', color = 'indianred',
    markeredgecolor = 'white')
ax1.plot(operatingByYearforG['year'], operatingByYearforG['operating'],
    label = 'Germany WARTA',marker = '*', color = '#4a4a4a',
    markeredgecolor = 'white')
ax1.plot(operatingByYearforF['year'], operatingByYearforF['operating'],
    label = 'France WARTA',marker = '^', color = '#8abbd0',
    markeredgecolor = 'white')
ax1a = ax1.twinx()
ax1a.plot(operatingByYearforB['year'], operatingByYearforB['debt_to_assets'],
    label = 'United Kingdom WADA',marker = 'o', color = 'indianred',
    markeredgecolor = 'white', ls = '--')
ax1a.plot(operatingByYearforG['year'], operatingByYearforG['debt_to_assets'],
    label = 'Germany WADA',marker = '*', color = '#4a4a4a',
    markeredgecolor = 'white', ls = '--')
ax1a.plot(operatingByYearforF['year'], operatingByYearforF['debt_to_assets'],
    label = 'France WADA',marker = '^', color = '#8abbd0',
    markeredgecolor = 'white', ls = '--')
ax1.set_xticks([2014, 2015, 2016, 2017, 2018])
ax1.set_yticks([-30, -15, 0, 15, 30])
ax1.set_yticklabels(['', '', 0, 15, 30])
ax1a.set_yticks([0, 15, 30, 45, 60])
ax1a.set_yticklabels([0, 15, 30, '', ''])
ax1.legend(loc = 'upper left', fontsize = 6)
ax1a.legend(loc = 'lower right', fontsize = 6)
ax1.grid(True, axis = 'y', color = 'gainsboro', ls = ':')
ax1.spines['right'].set_visible(False)
ax1.spines['top'].set_visible(False)
ax1.spines['left'].set_visible(False)
ax1a.spines['right'].set_visible(False)
ax1a.spines['top'].set_visible(False)
ax1a.spines['left'].set_visible(False)
ax1.set_title('Plot8 - WARTA and WADA (%)', color = 'k',
    fontweight = 'bold')
ax1.text(2013.2, 31, 'WARTA')
ax1a.text(2018.2, 61, 'WADA')

# ax2
ax2.plot(dataBCDMean['year'], dataBCDMean['operating'], color = 'darkgray')
ax2.plot(dataBCSMean['year'], dataBCSMean['operating'], color = 'burlywood')
ax2.plot(dataBEMMean['year'], dataBEMMean['operating'], color ='darkslategray')
ax2.plot(dataBFinMean['year'], dataBFinMean['operating'], color = 'lightsteelblue')
ax2.plot(dataBIndMean['year'], dataBIndMean['operating'], color = 'steelblue')
ax2.plot(dataBUtiMean['year'], dataBUtiMean['operating'], color ='darkturquoise')
ax2.set_xticks([2014, 2015, 2016, 2017, 2018])
ax2.set_xticklabels([])
ax2.set_yticks([-20, -10, 0, 10, 20, 30])
ax2.spines['right'].set_visible(False)
ax2.spines['top'].set_visible(False)
ax2.spines['left'].set_visible(False)
ax2.grid(True, axis = 'y', color ='gainsboro', ls = ':')


# ax3
ax3.plot(dataGCDMean['year'], dataGCDMean['operating'], color = 'darkgray')
ax3.plot(dataGCSMean['year'], dataGCSMean['operating'], color = 'burlywood')
ax3.plot(dataGEMMean['year'], dataGEMMean['operating'], color = 'darkslategray')
ax3.plot(dataGFinMean['year'], dataGFinMean['operating'], color = 'lightsteelblue')
ax3.plot(dataGIndMean['year'], dataGIndMean['operating'], color = 'steelblue')
ax3.plot(dataGUtiMean['year'], dataGUtiMean['operating'], color = 'darkturquoise')
ax3.set_xticks([2014, 2015, 2016, 2017, 2018])
ax3.set_xticklabels([])
ax3.set_yticks([-20, -10, 0, 10, 20, 30])
ax3.set_yticklabels([])
ax3.set_title('Plot9 - WARTA in 3 countries by industries (%)', fontweight = 'bold')
ax3.spines['right'].set_visible(False)
ax3.spines['top'].set_visible(False)
ax3.spines['left'].set_visible(False)
ax3.grid(True, axis = 'y', color = 'gainsboro', ls = ':')

# ax4
ax4.plot(dataFCDMean['year'], dataFCDMean['operating'],label = 'Consumer Discretionary', color = 'darkgray')
ax4.plot(dataFCSMean['year'], dataFCSMean['operating'],label = 'Consumer Staples', color = 'burlywood')
ax4.plot(dataFEMMean['year'], dataFEMMean['operating'],label = 'Energy and Materials', color = 'darkslategray')
ax4.plot(dataFFinMean['year'], dataFFinMean['operating'],label = 'Financials', color = 'lightsteelblue')
ax4.plot(dataFIndMean['year'], dataFIndMean['operating'],label = 'Industrials', color = 'steelblue')
ax4.plot(dataFUtiMean['year'], dataFUtiMean['operating'],label = 'Utilities', color = 'darkturquoise')
ax4.set_xticks([2014, 2015, 2016, 2017, 2018])
ax4.set_xticklabels([])
ax4.set_yticks([-20, -10, 0, 10, 20, 30])
ax4.set_yticklabels([])
ax4.spines['right'].set_visible(False)
ax4.spines['top'].set_visible(False)
ax4.spines['left'].set_visible(False)
ax4.grid(True, axis = 'y', color = 'gainsboro', ls = ':')
ax4.legend(loc = 'lower right', fontsize = 6)

# ax5
ax5.plot(dataBCDMean['year'], dataBCDMean['debt_to_assets'], color = 'darkgray')
ax5.plot(dataBCSMean['year'], dataBCSMean['debt_to_assets'], color = 'burlywood')
ax5.plot(dataBEMMean['year'], dataBEMMean['debt_to_assets'], color = 'darkslategray')
ax5.plot(dataBFinMean['year'], dataBFinMean['debt_to_assets'], color = 'lightsteelblue')
ax5.plot(dataBIndMean['year'], dataBIndMean['debt_to_assets'], color = 'steelblue')
ax5.plot(dataBUtiMean['year'], dataBUtiMean['debt_to_assets'], color = 'darkturquoise')
ax5.set_xticks([2014, 2015, 2016, 2017, 2018])
ax5.set_yticks([0, 10, 20, 30, 40, 50])
ax5.spines['right'].set_visible(False)
ax5.spines['top'].set_visible(False)
ax5.spines['left'].set_visible(False)
ax5.grid(True, axis = 'y', color = 'gainsboro', ls = ':')
ax5.set_xlabel('United Kingdom', fontweight = 'bold')

# ax6
ax6.plot(dataGCDMean['year'], dataGCDMean['debt_to_assets'], color = 'darkgray')
ax6.plot(dataGCSMean['year'], dataGCSMean['debt_to_assets'], color = 'burlywood')
ax6.plot(dataGEMMean['year'], dataGEMMean['debt_to_assets'], color = 'darkslategray')
ax6.plot(dataGFinMean['year'], dataGFinMean['debt_to_assets'], color = 'lightsteelblue')
ax6.plot(dataGIndMean['year'], dataGIndMean['debt_to_assets'], color = 'steelblue')
ax6.plot(dataGUtiMean['year'], dataGUtiMean['debt_to_assets'], color = 'darkturquoise')
ax6.set_xticks([2014, 2015, 2016, 2017, 2018])
ax6.set_yticks([0, 10, 20, 30, 40, 50])
ax6.set_yticklabels([])
ax6.set_title('Plot10 - WADA of 3 countries by industries (%)', fontweight = 'bold')
ax6.spines['right'].set_visible(False)
ax6.spines['top'].set_visible(False)
ax6.spines['left'].set_visible(False)
ax6.grid(True, axis = 'y', color = 'gainsboro', ls = ':')
ax6.set_xlabel('Germany', fontweight = 'bold')

# ax7
ax7.plot(dataFCDMean['year'], dataFCDMean['debt_to_assets'],label = 'Consumer Discretionary', color = 'darkgray')
ax7.plot(dataFCSMean['year'], dataFCSMean['debt_to_assets'],label = 'Consumer Staples', color = 'burlywood')
ax7.plot(dataFEMMean['year'], dataFEMMean['debt_to_assets'],label = 'Energy and Materials', color = 'darkslategray')
ax7.plot(dataFFinMean['year'], dataFFinMean['debt_to_assets'],label = 'Financials', color = 'lightsteelblue')
ax7.plot(dataFIndMean['year'], dataFIndMean['debt_to_assets'],label = 'Industrials', color = 'steelblue')
ax7.plot(dataFUtiMean['year'], dataFUtiMean['debt_to_assets'],label = 'Utilities', color = 'darkturquoise')
ax7.set_xticks([2014, 2015, 2016, 2017, 2018])
ax7.set_yticks([0, 10, 20, 30, 40, 50])
ax7.set_yticklabels([])
ax7.spines['right'].set_visible(False)
ax7.spines['top'].set_visible(False)
ax7.spines['left'].set_visible(False)
ax7.grid(True, axis = 'y', color = 'gainsboro', ls = ':')
ax7.legend(loc = 'upper right', fontsize = 6)
ax7.set_xlabel('France', fontweight = 'bold')


# % Second Page
# create plot
fig2 = plt.figure(figsize = (11.69, 8.27)) # design the figure to fit an A4 paper
fig2.suptitle('ROTA and D/A Analysis (2/2)', fontsize=20,
    fontweight='bold')

# set the layout of the figure
widths = [1, 0.5, 1, 0.5, 1, 0.5] #width ratio
heights = [1, 1] #height ratio
gs = GridSpec(ncols = 6, nrows = 2, width_ratios = widths,
    height_ratios = heights, wspace = 0.2)

# create subplots
ax8 = fig2.add_subplot(gs[0, 0], facecolor = 'azure') #plot the weighted average ROA D/A of CD
ax9 = fig2.add_subplot(gs[0, 2], facecolor = 'azure') #plot the weighted average ROA D/A of CS
ax10 = fig2.add_subplot(gs[0, 4], facecolor = 'azure') #plot the weighted average ROA D/A of EM
ax11 = fig2.add_subplot(gs[1, 0], facecolor = 'azure') #plot the weighted average ROA D/A of Fin
ax12 = fig2.add_subplot(gs[1, 2], facecolor = 'azure') #plot the weighted average ROA D/A of Ind
ax13 = fig2.add_subplot(gs[1, 4], facecolor = 'azure') #plot the weighted average ROA D/A of Uti


ax14 = fig2.add_subplot(gs[0, 1]) #plot the Brexit Impact of CD
ax15 = fig2.add_subplot(gs[0, 3]) #plot the Brexit Impact of CS
ax16 = fig2.add_subplot(gs[0, 5]) #plot the Brexit Impact of EM
ax17 = fig2.add_subplot(gs[1, 1]) #plot the Brexit Impact of Fin
ax18 = fig2.add_subplot(gs[1, 3]) #plot the Brexit Impact of Ind
ax19 = fig2.add_subplot(gs[1, 5]) #plot the Brexit Impact of Uti

# define the function to plot ROA and D/A together
def plotTogether(ax, axa, dataB, dataG, dataF, l):
    '''
    The function is designed to plot data of both WARTA and WADA together
    input: ax -> the subplot for data of WARTA
           axa -> the twins of ax for data of WADA
           dataB -> the dataframe which contains data of United Kingdom
           dataG -> the dataframe which contains data of Germany
           dataF -> the dataframe which contains data of France
           sec -> the name of sector
    '''
    ax.plot(dataB['year'], dataB['operating'],
        label = 'United Kingdom WARTA',marker = 'o', color = 'indianred',
        markeredgecolor = 'white')
    ax.plot(dataG['year'], dataG['operating'],
        label = 'Germany WARTA',marker = '*', color = '#4a4a4a',
        markeredgecolor = 'white')
    ax.plot(dataF['year'], dataF['operating'],
        label = 'France WARTA',marker = '^', color = '#8abbd0',
        markeredgecolor = 'white')
    axa.plot(dataB['year'], dataB['debt_to_assets'],
        label = 'United Kingdom WADA',marker = 'o', color = 'indianred',
        markeredgecolor = 'white', ls = '--')
    axa.plot(dataG['year'], dataG['debt_to_assets'],
        label = 'Germany WADA',marker = '*', color = '#4a4a4a',
        markeredgecolor = 'white', ls = '--')
    axa.plot(dataF['year'], dataF['debt_to_assets'],
        label = 'France WADA',marker = '^', color = '#8abbd0',
        markeredgecolor = 'white', ls = '--')
    ax.set_xticks([2014, 2015, 2016, 2017, 2018])
    ax.set_yticks([-30, -15, 0, 15, 30])
    ax.set_yticklabels([])
    axa.set_yticks([0, 15, 30, 45, 60])
    axa.set_yticklabels([])
    ax.grid(True, axis = 'y', color = 'gainsboro', ls = ':')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    axa.spines['right'].set_visible(False)
    axa.spines['top'].set_visible(False)
    axa.spines['left'].set_visible(False)
    ax.set_title(l, fontweight = 'bold')

# plot ax8-13
ax8a = ax8.twinx()
ax9a = ax9.twinx()
ax10a = ax10.twinx()
ax11a = ax11.twinx()
ax12a = ax12.twinx()
ax13a = ax13.twinx()
plotTogether(ax8, ax8a, dataBCDMean, dataGCDMean, dataFCDMean, 'Consumer Discretionary')
plotTogether(ax9, ax9a, dataBCSMean, dataGCSMean, dataFCSMean, 'Consumer Staples')
plotTogether(ax10, ax10a, dataBEMMean, dataGEMMean, dataFEMMean, 'Energy and Materials')
plotTogether(ax11, ax11a, dataBFinMean, dataGFinMean, dataFFinMean, 'Financials')
plotTogether(ax12, ax12a, dataBIndMean, dataGIndMean, dataFIndMean, 'Industrials')
plotTogether(ax13, ax13a, dataBUtiMean, dataGUtiMean, dataFUtiMean, 'Utilities')
ax8.set_yticklabels([-30, -15, 0, 15, 30])
ax11.set_yticklabels([-30, -15, 0, 15, 30])
ax10a.set_yticklabels([0, 15, 30, 45, 60])
ax13a.set_yticklabels([0, 15, 30, 45, 60])
ax8.text(2012.5, 31.5, 'WARTA')
ax11.text(2012.5, 31.5, 'WARTA')
ax10a.text(2018.3, 61.5, 'WADA')
ax13a.text(2018.3, 61.5, 'WADA')
ax9.text(2017, 36, 'Plot11 - WARTA and WADA of 3 countries by industry', fontsize = 10, fontweight = 'bold', ha = 'center')
ax10.legend(loc = 'upper right', fontsize = 6)
ax10a.legend(loc = 'lower right', fontsize = 6)


#define the function to calculate the change term
def getChange(df):
    '''
    The function is designed to assess the Brexit Impact on ROA by industry by comparing the slope of ROA before and after the Brexit. The slope will be computed by statsmodels.OLS
    input: df --> the initial dataframe with data of year', 'operating' and 'debt to assets'
    output: change --> difference between the slope of ROA and D/A before and after the Brexit
    '''
    x = [0, 1, 2]
    ROAmodelBeforeBrexit = sm.OLS( # fit the model by ROA of 2014, 2015 and 2016
        endog = df['operating'][0:3],
        exog = x,
        hasconst = None).fit()
    ROAmodelAfterBrexit = sm.OLS( # fit the model by ROA of 2016, 2017 and 2018
        endog = df['operating'][2:5],
        exog = x,
        hasconst = None).fit()
    ROAslopeBeforeBrexit = float(ROAmodelBeforeBrexit.params) # get the slope before
    ROAslopeAfterBrexit = float(ROAmodelAfterBrexit.params) # get the slope after
    ROAchange = ROAslopeAfterBrexit - ROAslopeBeforeBrexit # get the difference

    DAmodelBeforeBrexit = sm.OLS( # fit the model by D/A of 2014, 2015 and 2016
        endog = df['debt_to_assets'][0:3],
        exog = x,
        hasconst = None).fit()
    DAmodelAfterBrexit = sm.OLS( # fit the model by D/A of 2016, 2017 and 2018
        endog = df['debt_to_assets'][2:5],
        exog = x,
        hasconst = None).fit()
    DAslopeBeforeBrexit = float(DAmodelBeforeBrexit.params) # get the slope before
    DAslopeAfterBrexit = float(DAmodelAfterBrexit.params) # get the slope after
    DAchange = DAslopeAfterBrexit - DAslopeBeforeBrexit # get the difference

    change = [ROAchange, DAchange]

    return change

#define the function to plot the Brexit Impact
def plotChang(ax, x, y, c , l = None):
    '''
    The function is designed to plot the Brexit Impact on ROA by industry
    input: ax --> location of the plot
           x --> industry
           y --> Brexit Impact data list
           c --> color of the data
           l --> label of the data
    output:
    '''
    # plot the data with horizontal bar chat
    if l == None:
        ax.barh(x, y, color = c)
    else:
        ax.barh(x, y, color = c, label = l)
    ax.set_xticks([-2, 0, 11])
    ax.set_xticklabels([])
    ax.set_yticks([])
    ax.get_xaxis().set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    # add data label
    if y >= 0:
        ax.text(y+0.4, x, round(y, 2), ha = 'left', va = 'center',
            color = c, fontsize = 6, fontweight = 'bold')
    else:
        ax.text(0.4, x, round(y, 2), ha = 'left', va = 'center',
            color = c, fontsize = 6, fontweight = 'bold')

# plot ax14-19
plotChang(ax14, 'F CD D/A', getChange(dataFCDMean)[1], c = '#8abbd0')
plotChang(ax14, 'G CD D/A', getChange(dataGCDMean)[1], c = '#4a4a4a')
plotChang(ax14, 'UK CD D/A', getChange(dataBCDMean)[1], c = 'indianred')
plotChang(ax14, 'F CD ROA', getChange(dataFCDMean)[0], c = '#8abbd0')
plotChang(ax14, 'G CD ROA', getChange(dataGCDMean)[0], c = '#4a4a4a')
plotChang(ax14, 'UK CD ROA', getChange(dataBCDMean)[0], c = 'indianred')

plotChang(ax15, 'F CS D/A', getChange(dataFCSMean)[1], c = '#8abbd0')
plotChang(ax15, 'G CS D/A', getChange(dataGCSMean)[1], c = '#4a4a4a')
plotChang(ax15, 'UK CS D/A', getChange(dataBCSMean)[1], c = 'indianred')
plotChang(ax15, 'F CS ROA', getChange(dataFCSMean)[0], c = '#8abbd0')
plotChang(ax15, 'G CS ROA', getChange(dataGCSMean)[0], c = '#4a4a4a')
plotChang(ax15, 'UK CS ROA', getChange(dataBCSMean)[0], c = 'indianred')

plotChang(ax16, 'F EM D/A', getChange(dataFEMMean)[1], c = '#8abbd0')
plotChang(ax16, 'G EM D/A', getChange(dataGEMMean)[1], c = '#4a4a4a')
plotChang(ax16, 'UK EM D/A', getChange(dataBEMMean)[1], c = 'indianred')
plotChang(ax16, 'F EM ROA', getChange(dataFEMMean)[0], c = '#8abbd0')
plotChang(ax16, 'G EM ROA', getChange(dataGEMMean)[0], c = '#4a4a4a')
plotChang(ax16, 'UK EM ROA', getChange(dataBEMMean)[0], c = 'indianred')

plotChang(ax17, 'F Fin D/A', getChange(dataFFinMean)[1], c = '#8abbd0')
plotChang(ax17, 'G Fin D/A', getChange(dataGFinMean)[1], c = '#4a4a4a')
plotChang(ax17, 'UK Fin D/A', getChange(dataBFinMean)[1],c = 'indianred')
plotChang(ax17, 'F Fin ROA', getChange(dataFFinMean)[0], c = '#8abbd0')
plotChang(ax17, 'G Fin ROA', getChange(dataGFinMean)[0], c = '#4a4a4a')
plotChang(ax17, 'UK Fin ROA', getChange(dataBFinMean)[0],c = 'indianred')

plotChang(ax18, 'F Ind D/A', getChange(dataFIndMean)[1], c = '#8abbd0')
plotChang(ax18, 'G Ind D/A', getChange(dataGIndMean)[1], c = '#4a4a4a')
plotChang(ax18, 'UK Ind D/A', getChange(dataBIndMean)[1],c = 'indianred')
plotChang(ax18, 'F Ind ROA', getChange(dataFIndMean)[0], c = '#8abbd0')
plotChang(ax18, 'G Ind ROA', getChange(dataGIndMean)[0], c = '#4a4a4a')
plotChang(ax18, 'UK Ind ROA', getChange(dataBIndMean)[0],c = 'indianred')

plotChang(ax19, 'F Uti D/A', getChange(dataFUtiMean)[1], c = '#8abbd0')
plotChang(ax19, 'G Uti D/A', getChange(dataGUtiMean)[1], c = '#4a4a4a')
plotChang(ax19, 'UK Uti D/A', getChange(dataBUtiMean)[1],c = 'indianred')
plotChang(ax19, 'F Uti ROA', getChange(dataFUtiMean)[0], c = '#8abbd0')
plotChang(ax19, 'G Uti ROA', getChange(dataGUtiMean)[0], c = '#4a4a4a')
plotChang(ax19, 'UK Uti ROA', getChange(dataBUtiMean)[0],c = 'indianred')

ax14.axvline(0, color = 'k', ls = '--', linewidth = 0.5)
ax15.axvline(0, color = 'k', ls = '--', linewidth = 0.5)
ax16.axvline(0, color = 'k', ls = '--', linewidth = 0.5)
ax17.axvline(0, color = 'k', ls = '--', linewidth = 0.5)
ax18.axvline(0, color = 'k', ls = '--', linewidth = 0.5)
ax19.axvline(0, color = 'k', ls = '--', linewidth = 0.5)

# add some notes to explain the figure
fig2.text(0.7, 0.01,
    '''
    Note: The Brexit Impact is computed by comparing the slope of changes
              of weighted average ROA between 2014-2016 and 2016-2018, which
              is calculated by fitting linear models
    '''
    , fontsize = 6)

# %% clean data for investor dimension analysis
# converting the data type of date for financial csv files into datetime
longTerm['date'] = pd.to_datetime(longTerm['date'])# new df
df0 = longTerm.groupby(['sector','country','date'], as_index=False)['price'].aggregate(np.mean)
df0 = longTerm.rename(columns={'price':'ave price'})

df1 = pd.DataFrame(
    # set 'date' as index
    df0.set_index('date').
    # group the dataframe by 'sector' and 'country'
    groupby(['sector', 'country'], as_index = False).
    # get the sub-sample by quarters of average number of stock prices
    resample('QS')['ave price'].aggregate(np.mean).
    # get the percentage of change
    pct_change(axis = 'columns') * 100
    ).T


# dataframe for subplots
df_cd = df1['consumer discretionary']
df_fin = df1['financials']
df_cs = df1['consumer staples']
df_em = df1['energy and materials']
df_ind = df1['industrials']
df_uti = df1['utilities']

## dataframe for summary plot
# create the data frame that groups all the values by countries only
df_sum = df1.T
df_sum = df_sum.groupby(['country']).aggregate(np.mean).T

# %% plot the data for investor dimension analysis

# fig
fig4 = plt.figure(figsize=(11.69, 8.27))   # design the figure to fit an A4 paper

# parition the figure into 4 subplots with 'gridspec'
gs = GridSpec(3, 6, # we want 3 rows, 6 cols
                       figure=fig4, # this gs applies to figure
                       hspace=0.5, wspace=1, # separation between plots
                       width_ratios=[1, 1, 1, 1, 1, 1], # ration between the first and second column
                       height_ratios=[1, 1, 1]) # ration between the first and second row

# creating 6 sub-plots
ax20 = fig4.add_subplot(gs[0, 0:2])
ax21 = fig4.add_subplot(gs[0, 2:4])
ax22 = fig4.add_subplot(gs[0, 4:6])
ax23 = fig4.add_subplot(gs[1, 0:2])
ax24 = fig4.add_subplot(gs[1, 2:4])
ax25 = fig4.add_subplot(gs[1, 4:6])
ax26 = fig4.add_subplot(gs[2, 0:6])

### Plot the data for consumer discretionary
df_cd.plot(ax=ax20,color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax20.set_title('Plot1 - Consumer Discretionary', fontweight = 'bold')

### Plot the data for financials
df_fin.plot(ax=ax21,color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax21.set_title('Plot2 - Financials', fontweight = 'bold')

### Plot the data for energy and materials
df_em.plot(ax=ax22, color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax22.set_title('Plot3 - Energy and Materials', fontweight = 'bold')

### Plot the data for consumer staples
df_cs.plot(ax=ax23, color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax23.set_title('Plot4 - Consumer Staples', fontweight = 'bold')

### Plot the data for industrials
df_ind.plot(ax=ax24, color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax24.set_title('Plot5 - Industrials', fontweight = 'bold')

### Plot the data for utilities
df_uti.plot(ax=ax25, color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax25.set_title('Plot6 - Utilities', fontweight = 'bold')

### Plot the summary for all industries
df_sum.plot(ax=ax26, color = ['#8abbd0','#4a4a4a','indianred'], legend = False)
# Add title
ax26.set_title('Plot7 - Average Percentage Change in the Stock Prices over years', fontweight = 'bold')
# add legend
ax26.legend(loc = 'lower left', fontsize = 6)

### Grid, axis labels, spines
graphs = [ax20, ax21, ax22, ax23, ax24, ax25, ax26]

for i in range(7):
    # grid, axis labels, spines
    graphs[i].grid(True, axis = 'y', color = 'gainsboro', ls = ':')
    graphs[i].spines['right'].set_visible(False)
    graphs[i].spines['top'].set_visible(False)
    graphs[i].spines['left'].set_visible(False)

ax20.set_yticks([-40, -30, -20, -10, 0, 10, 20])
ax21.set_yticks([-40, -30, -20, -10, 0, 10, 20])
ax22.set_yticks([-40, -30, -20, -10, 0, 10, 20])
ax23.set_yticks([-40, -30, -20, -10, 0, 10, 20])
ax24.set_yticks([-40, -30, -20, -10, 0, 10, 20])
ax25.set_yticks([-40, -30, -20, -10, 0, 10, 20])
ax26.set_yticks([-10, 0, 10])

ax21.set_yticklabels(['', '', '', '', 0, '', ''])
ax22.set_yticklabels(['', '', '', '', 0, '', ''])
ax24.set_yticklabels(['', '', '', '', 0, '', ''])
ax25.set_yticklabels(['', '', '', '', 0, '', ''])

ax20.set_xticklabels([])
ax21.set_xticklabels([])
ax22.set_xticklabels([])

# y labels
graphs_ylabel = [ax20, ax23, ax26]
for i in range(3):
    graphs_ylabel[i].set_ylabel('% Stock Price Change', fontweight = 'bold')

# x labels
ax26.set_xlabel('Time', fontweight = 'bold')

graphs_xlabel = [ax20, ax21, ax22, ax23, ax24, ax25]
for i in range(6):
    graphs_xlabel[i].xaxis.label.set_color('white')


### add a vertical line indicating the Brexit referendum date: 23 june 2016
# Our data is tranformed into quarterly data so the data are recorded for Jan, April, July, and Oct.
# The exact Brexit data (2016, 6, 23) is closer to July than April, we set the approximate the referedum data to
# 1 July 2016 for visualization purpose.
ref_date = pd.Timestamp(2016, 7, 1)
for i in range(7):
    graphs[i].axvline(x=ref_date, color='red', linestyle='--', linewidth=1)

# text for the vertical line
ann_date = pd.Timestamp(2016, 8, 1)
ax26.annotate('Brexit Referendum 23 June 2016', xy=(ann_date, -9), color='black', fontweight = 'bold')

### adjust the figure
fig4.suptitle('Stock Price Analysis', fontsize = 20, fontweight = 'bold')



# %% create a cover page
# create plot
fig3 = plt.figure(figsize = (11.69, 8.27)) # design the figure to fit an A4 paper

# add the title of this project
fig3.text(0.5, 0.7, 'Mid-Term Project of SMM635 Data Visualization', fontsize = 20, fontweight = 'bold', va = 'center', ha = 'center')
fig3.text(0.5, 0.6, 'MSc Business Analytics', fontsize = 20, fontweight = 'bold', va = 'center', ha = 'center')
fig3.text(0.65, 0.5, 'Group 3', fontsize = 16, fontweight = 'bold', va = 'center', ha = 'center')
fig3.text(0.35, 0.5, 'Lecturer', fontsize = 16, fontweight = 'bold', va = 'center', ha = 'center')
fig3.text(0.65, 0.48,
    '''
Georgios Halios
Jinze Yi (Eric)
Kar Whing Haw
Xuehui Sun (Samuel)
Yasmine Turki
Ziyun Yuan (Isabella)
    ''',
    fontsize = 14, ha = 'center', va = 'top'
    )
fig3.text(0.35, 0.455, 'Dr. Simone Santoni', fontsize = 14, ha = 'center', va = 'top')
fig3.text(0.7, 0.2, 'Submission Date: 11/11/2020', fontsize = 12, ha = 'left', va = 'center', fontweight = 'bold')


# %% save all figure in 1 pdf file
with PdfPages('DataVisualization1.0.pdf') as pdf:
    pdf.savefig(fig3)
    pdf.savefig(fig4)
    pdf.savefig(fig1)
    pdf.savefig(fig2)

# plt.show()

