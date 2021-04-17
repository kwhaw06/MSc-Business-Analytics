# %% import libraries
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.backends.backend_pdf import PdfPages
from mpl_toolkits.axes_grid1.inset_locator import inset_axes

# %% load the data
wd = os.getcwd()
infile = os.path.join(wd, 'pay_gaps_london.csv')
df_London = pd.read_csv(infile)
mean_London = np.mean(df_London['DiffMeanPercent'])

# %% analyse the data
# diff mean percent by section
df_by_section = pd.DataFrame(df_London.groupby(['Section'])
    ['DiffMeanPercent'].aggregate(np.mean))
df_by_section = df_by_section.sort_values(by = ['DiffMeanPercent'],
    ascending = True)
df_by_section = df_by_section.reset_index()

fig1 = plt.figure(figsize = (15, 8))

ax1 = fig1.add_subplot(111)

for i in df_by_section.index:
    if df_by_section.loc[i, 'DiffMeanPercent'] >= mean_London+5:
        ax1.scatter(df_by_section.loc[i, 'DiffMeanPercent'],
            i, color = 'red', s = 200)
        ax1.hlines(y = i, xmin = mean_London,
            xmax = df_by_section.loc[i, 'DiffMeanPercent'],
            color = 'red')
    elif (df_by_section.loc[i, 'DiffMeanPercent'] < mean_London+5) & (df_by_section.loc[i, 'DiffMeanPercent'] >= mean_London-5):
        ax1.scatter(df_by_section.loc[i, 'DiffMeanPercent'],
            i, color = 'orange', s = 200)
        ax1.hlines(y = i, xmin = mean_London,
            xmax = df_by_section.loc[i, 'DiffMeanPercent'],
            color = 'orange')
    else:
        ax1.scatter(df_by_section.loc[i, 'DiffMeanPercent'],
            i, color = 'green', s = 200)
        ax1.hlines(y = i, xmin = df_by_section.loc[i, 'DiffMeanPercent'],
            xmax = mean_London,
            color = 'green')
    text = round(df_by_section.loc[i, 'DiffMeanPercent'], 2)
    ax1.text(df_by_section.loc[i, 'DiffMeanPercent'], i, str(text),
        color = 'white', fontweight = 'bold', fontsize = 4,
        ha = 'center', va = 'center')

ax1.set_xticks([mean_London])
ax1.set_xticklabels(['Average Gender Pay Gap'])
ax1.set_yticks(list(df_by_section.index))
ax1.set_yticklabels(list(df_by_section.Section))
ax1.set_ylabel('Industries', fontweight = 'bold')

ax1.spines['right'].set_visible(False)
ax1.spines['left'].set_visible(False)
ax1.spines['top'].set_visible(False)
ax1.spines['bottom'].set_visible(False)

p1 = patches.Rectangle((0, -0.5), width = 18, height = 7, alpha = 0.2,
    facecolor = 'green')
p2 = patches.Rectangle((19.5, 6.5), width = 8.3, height = 6, alpha = 0.2,
    facecolor = 'orange')
p3 = patches.Rectangle((30, 12.5), width = 18.3, height = 7, alpha = 0.2,
    facecolor = 'red')
plt.gca().add_patch(p1)
plt.gca().add_patch(p2)
plt.gca().add_patch(p3)
ax1.text(0.5, 6, 'LOWER AREA',
    ha = 'left', va = 'center',
    fontweight = 'bold'
    )
ax1.text(20, 12, 'MID AREA',
    ha = 'left', va = 'center',
    fontweight = 'bold'
    )
ax1.text(47.8, 13, 'HIGHER AREA',
    ha = 'right', va = 'center',
    fontweight = 'bold'
    )

ax1.grid(ls = '--', alpha = 0.5)

ax1.set_title('Average Gender Pay Gap by Industries (%)', fontsize = 12,
    fontweight = 'bold')







# diff mean percent by employer size
df_by_size = pd.DataFrame(df_London.groupby(['EmployerSize'])
    ['DiffMeanPercent'].aggregate(np.mean))
df_by_size = df_by_size.reset_index()
df_by_size['num'] = [4, 6, 2, 3, 5, 1]
df_by_size = df_by_size.sort_values(by = ['num'])
df_by_size = df_by_size.drop('num', 1)

fig2 = plt.figure(figsize = (15, 8))

ax2 = fig2.add_subplot(111)
ax2.bar(df_by_size['EmployerSize'], df_by_size['DiffMeanPercent'])
ax2. set_title('DiffMeanPercent by Employer Sizes')
ax2.hlines(mean_London,
    df_by_size.loc[5, 'EmployerSize'],
    df_by_size.loc[1, 'EmployerSize'],
    color = 'red'
    )

# distribution of employer size by industries
df_es_by_section = pd.DataFrame({'Section' : df_by_section['Section']})
df_es_by_section['size'] = 0
df_es_by_section['less250'] = 0
df_es_by_section['250-499'] = 0
df_es_by_section['500-999'] = 0
df_es_by_section['1000-4999'] = 0
df_es_by_section['5000-19999'] = 0
df_es_by_section['20000more'] = 0
for i in df_es_by_section.index:
    section = df_es_by_section.loc[i, 'Section']
    data = df_London[df_London['Section'] == section]
    df_es_by_section.loc[i, 'size'] = len(data)
    df_es_by_section.loc[i, 'less250'] = len(data
        [data['EmployerSize'] == 'Less than 250']) / len(data)
    df_es_by_section.loc[i, '250-499'] = len(data
        [data['EmployerSize'] == '250 to 499']) / len(data)
    df_es_by_section.loc[i, '500-999'] = len(data
        [data['EmployerSize'] == '500 to 999']) / len(data)
    df_es_by_section.loc[i, '1000-4999'] = len(data
        [data['EmployerSize'] == '1000 to 4999']) / len(data)
    df_es_by_section.loc[i, '5000-19999'] = len(data
        [data['EmployerSize'] == '5000 to 19,999']) / len(data)
    df_es_by_section.loc[i, '20000more'] = len(data
        [data['EmployerSize'] == '20,000 or more']) / len(data)

fig3 = plt.figure(figsize = (15, 8))
ax3 = fig3.add_subplot(111)

color = ['lightgray', 'lightsteelblue', 'cornflowerblue', 'royalblue',
    'blue', 'midnightblue']
category = ['Less than 250', '250 to 499', '500 to 999', '1000 to 4999',
    '5000 to 19,999', '20,000 or more']
for i in df_es_by_section.index:
    for j in np.arange(2, 8):
        section = df_es_by_section.loc[i, 'Section']
        widths = df_es_by_section.iloc[i, j]
        starts = 0
        num = 2
        while num < j:
            starts += df_es_by_section.iloc[i, num]
            num += 1
        if i == 0:
            ax3.barh(section, widths,
                left = starts, height = 0.5,
                color = color[j-2], label = category[j-2])
        else:
            ax3.barh(section, widths,
                left = starts, height = 0.5,
                color = color[j-2])
    ax3.text(0.01, df_es_by_section.loc[i, 'Section'],
        df_es_by_section.loc[i, 'Section'], color = 'white', va = 'center',
        fontweight = 'bold')
ax3.legend(ncol = 6, bbox_to_anchor = (0, -0.05),
    loc = 'lower left', fontsize = 12)
ax3.axis('off')
ax3.set_title('Distribution of Employer Sizes by Industries')



# diff mean by section by employer size
df_by_section_by_es = pd.DataFrame(
    df_London.groupby(['Section', 'EmployerSize']).
    aggregate(np.mean)).reset_index()

fig4 = plt.figure(figsize = (15, 8))
ax4 = fig4.add_subplot(1, 1, 1)

sections = {
    'B' : 'Mining and Quarrying',
    'M' : 'Professional, Scientific\nand Tech',
    'A' : 'Agriculture, Forestry\nand Fishing',
    'L' : 'Real Estate',
    'F' : 'Contruction',
    'R' : 'Art, Entertainment\nand Recreation',
    'K' : 'Financial\nand Insurance'
}

color = ['lightgray', 'lightsteelblue', 'cornflowerblue', 'royalblue',
    'blue', 'midnightblue']
category = ['Less than 250', '250 to 499', '500 to 999', '1000 to 4999',
    '5000 to 19,999', '20,000 or more']

for key, value in sections.items():
    data = df_by_section_by_es[df_by_section_by_es['Section'] == key]
    data.loc[:, 'percent'] = float(0)
    data.loc[:, 'cumpercent'] = float(0)
    data.loc[:, 'order'] = int(0)
    total = len(df_London[df_London['Section'] == key])
    ptotal = 0
    for i in data.index:
        num = len(df_London[(df_London['Section'] == key) &
            (df_London['EmployerSize'] == data.loc[i, 'EmployerSize'])])
        p = num / total
        data.loc[i, 'percent'] = p
        es = data.loc[i, 'EmployerSize']
        for j in np.arange(len(category)):
            if category[j] == es:
                data.loc[i, 'order'] = j+1
    data = data.sort_values(by = ['order'])
    for i in data.index:
        ptotal += data.loc[i, 'percent']
        data.loc[i, 'cumpercent'] = ptotal
    data = data.reset_index(drop = True)

    for i in data.index:
        widths = data.loc[i, 'percent']
        starts = data.loc[i, 'cumpercent'] - data.loc[i, 'percent']
        h = data.loc[i, 'DiffMeanPercent'] / 75
        if data.loc[i, 'Section'] == 'K':
            ax4.barh(value, widths, left = starts, height = h,
                label = data.loc[i, 'EmployerSize'],
                color = color[data.loc[i, 'order']-1])
        else:
            ax4.barh(value, widths, left = starts, height = h,
                color = color[data.loc[i, 'order']-1])


ax4.get_xaxis().set_visible(False)
ax4.spines['right'].set_visible(False)
ax4.spines['left'].set_visible(False)
ax4.spines['top'].set_visible(False)
ax4.spines['bottom'].set_visible(False)
ax4.set_title('Proportion of Employers by Sizes', fontweight = 'bold')
ax4.legend(ncol = 6, bbox_to_anchor = (0, -0.03),
    loc = 'lower left', fontsize = 10)







# %% save all figure in 1 pdf file
with PdfPages('plot_london.pdf') as pdf:
    pdf.savefig(fig1)
    pdf.savefig(fig2)
    pdf.savefig(fig3)
    pdf.savefig(fig4)




