# %% import libraries
# pandas to manage data
import pandas as pd
import geopandas as gp

# numpy to manage data
import numpy as np

# bokeh to plot
from bokeh.plotting import figure
from bokeh.io import show

from bokeh.layouts import column, row, WidgetBox
from bokeh.models import Panel, ColumnDataSource, HoverTool, Div, GeoJSONDataSource, ColorBar, LinearColorMapper
from bokeh.models.widgets import CheckboxGroup, RangeSlider, Select, Slider
from bokeh.tile_providers import get_provider, Vendors
from bokeh.transform import cumsum
from bokeh.palettes import brewer, Category20c

def transformation_tab(company_data, founder_data, gis_data, industry_data,
    world_data, nation_data):
    company_data.loc[:, 'IncorporationDate'] = pd.to_datetime(
        company_data['IncorporationDate'], format = '%d/%m/%Y')
    company_data.loc[:, 'year'] = company_data[
        'IncorporationDate'].dt.to_period('Y').astype(str).astype(int)

    founder_data = founder_data.dropna()
    founder_data.loc[:, 'IncorporationDate'] = pd.to_datetime(
        founder_data['IncorporationDate'], format = '%d/%m/%Y')
    founder_data.loc[:, 'year'] = founder_data[
        'IncorporationDate'].dt.to_period('Y').astype(str).astype(int)
    founder_data.loc[:, 'age'] = founder_data[
        'year'] - founder_data['date_of_birth.year']
    founder_data.loc[:, 'age'] = founder_data['age'].astype(int)

    ###################################
    # diversification into industries #
    ###################################
    # %% prepare dataset
    def make_industry_dataset(range_start = 1980, range_end = 2020,
        year_select = 2020):
        # calculate the number of industries
        industries = company_data.copy()
        industries = industries.loc[:, ['SICCode.SicText_1', 'SICCode.SicText_2', 'SICCode.SicText_3', 'SICCode.SicText_4', 'year']]
        df1 = industries.loc[:, ['SICCode.SicText_1', 'year']].dropna()
        df1 = df1.rename(columns = {'SICCode.SicText_1' : 'siccode'})
        df2 = industries.loc[:, ['SICCode.SicText_2', 'year']].dropna()
        df2 = df1.rename(columns = {'SICCode.SicText_2' : 'siccode'})
        df3 = industries.loc[:, ['SICCode.SicText_3', 'year']].dropna()
        df3 = df1.rename(columns = {'SICCode.SicText_3' : 'siccode'})
        df4 = industries.loc[:, ['SICCode.SicText_4', 'year']].dropna()
        df4 = df1.rename(columns = {'SICCode.SicText_4' : 'siccode'})
        industries = pd.concat([df1, df2, df3, df4])
        industries = industries[industries['siccode'] != 'None Supplied']
        industries = industries.sort_values(by = ['year'])
        industries = industries.drop_duplicates(subset = ['siccode'],
            keep = 'first')
        industries.loc[:, 'count'] = 1
        industries = pd.DataFrame(industries.groupby(['year'])['count'].sum())
        industries.loc[:, 'sum'] = industries['count'].cumsum()
        industries = industries.reset_index()
        industries = industries[industries['year'] >= range_start]
        industries = industries[industries['year'] <= range_end]
        industries = industries.loc[:, ['year', 'sum']]
        industries.loc[:, 'left'] = industries['year'].astype(float) - 0.5
        industries.loc[:, 'right'] = industries['year'].astype(float) + 0.5

        # calculate the perc of industries
        sic = industry_data.copy()
        perc = company_data.copy()
        perc = perc.loc[:, ['SICCode.SicText_1', 'SICCode.SicText_2',
            'SICCode.SicText_3', 'SICCode.SicText_4', 'year']]
        perc = perc[perc['year'] <= year_select]
        df1 = perc.loc[:, ['SICCode.SicText_1', 'year']].dropna()
        df1 = df1.rename(columns = {'SICCode.SicText_1' : 'siccode'})
        df2 = perc.loc[:, ['SICCode.SicText_2', 'year']].dropna()
        df2 = df1.rename(columns = {'SICCode.SicText_2' : 'siccode'})
        df3 = perc.loc[:, ['SICCode.SicText_3', 'year']].dropna()
        df3 = df1.rename(columns = {'SICCode.SicText_3' : 'siccode'})
        df4 = perc.loc[:, ['SICCode.SicText_4', 'year']].dropna()
        df4 = df1.rename(columns = {'SICCode.SicText_4' : 'siccode'})
        perc = pd.concat([df1, df2, df3, df4])
        perc = perc[perc['siccode'] != 'None Supplied']
        perc = perc.sort_values(by = ['year'])
        perc = perc.drop_duplicates(subset = ['siccode'], keep = 'first')
        perc.loc[:, 'sector_code'] = perc['siccode'].str[0:2]
        perc.loc[:, 'sector_code'] = perc['sector_code'].astype(int)
        perc = pd.merge(perc, sic,
            left_on = 'sector_code', right_on = 'SICCode')
        perc = perc.loc[:, ['sector_code', 'Section', 'Description']]
        perc.loc[:, 'count'] = 1
        perc = pd.DataFrame(perc.groupby(['Section'])['count'].sum())
        perc = perc.reset_index()
        perc = pd.merge(perc, sic, on = 'Section')
        perc = perc.drop_duplicates(subset = ['Section'], keep = 'first')
        perc.loc[:, 'angle'] = perc['count'] / perc['count'].sum() * 2 * np.pi
        perc.loc[:, 'perc'] = perc['count'] / perc['count'].sum()
        perc.loc[:, 'perc_num'] = round(perc['perc']*100, 2)
        sections = sorted(list(set(sic['Section'])))
        color = pd.DataFrame({
            'Section' : sections
            })
        color.loc[:, 'color'] = Category20c[len(color.index)]
        perc = pd.merge(perc, color, on = 'Section', how = 'left')

        return ColumnDataSource(industries), ColumnDataSource(perc)

    # %% plot data
    def make_industry_plot(src):
        p = figure(plot_width = 1000, plot_height = 550,
            title = 'Industries in Tech-City by years',
            x_axis_label = 'YEAR',
            y_axis_label = 'NUM',
            )
        p.quad(source = src, bottom = 0, top = 'sum',
            left = 'left', right = 'right',
            color = 'lightblue', fill_alpha = 0.7,
            hover_fill_color = 'steelblue',
            hover_fill_alpha = 1.0, line_color = 'black')
        hover = HoverTool(tooltips = [
            ('Year', '@year'),
            ('Num of Industries', '@sum')])
        p.add_tools(hover)

        return p

    def make_par_chart(src):
        p = figure(plot_width = 550, plot_height = 550,
            title = 'Distribution of Sections',
            tools = 'hover',
            tooltips = '@Description (@Section) : @perc_num%',
            x_range = (-2, 2)
            )
        p.wedge(x = -0.25, y = 0, radius = 1.5, source = src,
            start_angle = cumsum('angle', include_zero = True),
            end_angle = cumsum('angle'), legend_field = 'Section',
            fill_color = 'color')
        p.axis.axis_label = None
        p.axis.visible = False
        p.grid.grid_line_color = None
        p.legend.title = 'Sections'

        return p

    #################################################
    # diversification into international background #
    #################################################
    # %% prepare dataset
    def make_nation_dataset(range_start = 1980, range_end = 2020,
        year_select = 2020):
        # calculate the number of nationalities of founders
        nations = founder_data.copy()
        nations = nations.loc[:, ['year', 'nationality']]
        nations = nations.dropna()
        nations = nations.reset_index(drop = True)
        nations = nations.drop('nationality', axis = 1).join(
            nations['nationality'].str.split(',', expand = True).stack().
            reset_index(level = 1, drop = True).rename('nationality'))

        nations_1 = nations.copy()

        nations = pd.merge(nations, nation_data, how = 'left',
            left_on = 'nationality', right_on = 'nation')
        nations = nations.sort_values(by = ['year'])
        nations = nations.drop_duplicates(subset = ['COUNTRY'],
            keep = 'first')
        nations.loc[:, 'count'] = 1
        nations = pd.DataFrame(nations.groupby(['year'])['count'].sum())
        nations.loc[1980, 'count'] = 0
        nations.loc[1981, 'count'] = 0
        nations.loc[1982, 'count'] = 0
        nations.loc[1983, 'count'] = 0
        nations.loc[1984, 'count'] = 0
        nations.loc[1988, 'count'] = 0
        nations.loc[1989, 'count'] = 0
        nations.loc[1991, 'count'] = 0
        nations.loc[1993, 'count'] = 0
        nations.loc[1994, 'count'] = 0
        nations.loc[1995, 'count'] = 0
        nations = nations.reset_index()
        nations = nations.sort_values(by = ['year'])
        nations.loc[:, 'sum'] = nations['count'].cumsum()
        nations = nations[nations['year'] >= range_start]
        nations = nations[nations['year'] <= range_end]
        nations = nations.loc[:, ['year', 'sum']]
        nations.loc[:, 'left'] = nations['year'].astype(float) - 0.5
        nations.loc[:, 'right'] = nations['year'].astype(float) + 0.5

        nations_1 = pd.merge(nations_1, nation_data, how = 'left',
            left_on = 'nationality', right_on = 'nation')
        nations_1 = nations_1.loc[:, ['year', 'COUNTRY']]
        nations_1 = nations_1[nations_1['year'] <= year_select]
        nations_1 = nations_1[nations_1['COUNTRY'] != 'TBD']
        nations_1.loc[:, 'count'] = 1
        nations_1 = pd.DataFrame(nations_1.groupby(['COUNTRY'])['count'].sum())
        nations_1 = nations_1.reset_index()

        world = world_data.copy()
        world = world.loc[:, ['COUNTRY', 'geometry']]
        world.loc[:, 'x'] = world['geometry'].apply(
            lambda x: x.representative_point().coords[0][0])
        world.loc[:, 'y'] = world['geometry'].apply(
            lambda x: x.representative_point().coords[0][1])

        world = pd.merge(world, nations_1, on = 'COUNTRY')
        world = world.drop(['geometry'], axis = 1)
        world.loc[:, 'radius'] = world['count'].apply(np.log)

        return ColumnDataSource(nations), ColumnDataSource(world)

    # %% plot data
    def make_nation_plot(src):
        p = figure(plot_width = 700, plot_height = 550,
            title = 'International Background in Tech-City by years',
            x_axis_label = 'YEAR',
            y_axis_label = 'NUM',
            )
        p.quad(source = src, bottom = 0, top = 'sum',
            left = 'left', right = 'right',
            color = 'peru', fill_alpha = 0.7,
            hover_fill_color = 'maroon',
            hover_fill_alpha = 1.0, line_color = 'black')
        hover = HoverTool(tooltips = [
            ('Year', '@year'),
            ('Number of Countries', '@sum')])
        p.add_tools(hover)

        return p

    # %% plot map
    def make_nation_map(src):
        world = world_data.copy()
        world_src = GeoJSONDataSource(geojson = world.to_json())

        p = figure(title = 'world map', plot_height = 550, plot_width = 850)
        p.xgrid.grid_line_color = None
        p.ygrid.grid_line_color = None

        p1 = p.patches('xs', 'ys', source = world_src,
            fill_color = 'linen',
            line_color = 'gray',
            name = 'map')

        p2 = p.circle(x = 'x', y = 'y', color = 'peru', source = src,
            size = 10, fill_alpha = 0.4, radius = 'radius', name = 'circle')

        hover = HoverTool(tooltips = [
            ('Country', '@COUNTRY'),
            ('Number of Founders', '@count')], names = ['circle'])

        p.add_tools(hover)

        p.xaxis.visible = False
        p.yaxis.visible = False

        notes1 = Div(text =
            '''
            <b>The location of dots:</b> Country Region (city-level info is
            not available)
            ''')

        notes2 = Div(text =
            '''
            <b>The size of dots:</b> the size of Founder Numbers
            ''')

        layout = column(p, notes1, notes2)

        return layout






    ###############################
    # diversification into gender #
    ###############################
    # %% prepare dataset
    def make_gender_dataset(gender_indicators,
        range_start = 1980, range_end = 2020):
        # calculate the number of male and female founders each year
        genders = founder_data.copy()
        genders = genders.loc[:, ['name', 'year']]
        genders = genders.dropna()
        genders.loc[:, 'gender'] = genders['name'].str[0:3]
        genders = genders[
            (genders['gender'] == 'Mr ') |
            (genders['gender'] == 'Mrs') |
            (genders['gender'] == 'Mis') |
            (genders['gender'] == 'Ms ') |
            (genders['gender'] == 'Ms.')]
        males = genders[genders['gender'] == 'Mr ']
        males.loc[:, 'male_count'] = 1
        males = pd.DataFrame(males.groupby(['year'])['male_count'].sum())
        males = males.reset_index()

        females = genders[genders['gender'] != 'Mr ']
        females.loc[:, 'female_count'] = 1
        females = pd.DataFrame(females.groupby(['year'])['female_count'].sum())
        females = females.reset_index()

        genders = pd.merge(males, females, on = 'year', how = 'outer')
        genders = genders.sort_values(by = ['year']).reset_index(drop = True)
        genders = genders.fillna(0)

        genders.loc[:, 'male_sum'] = genders['male_count'].cumsum()
        genders.loc[:, 'female_sum'] = genders['female_count'].cumsum()
        genders.loc[:, 'total_count'] = genders[
            'male_count'] + genders['female_count']
        genders.loc[:, 'total_sum'] = genders[
            'male_sum'] + genders['female_sum']
        genders.loc[:, 'male_perc'] = genders[
            'male_sum'] * 100 / genders['total_sum']
        genders.loc[:, 'female_perc'] = genders[
            'female_sum'] * 100 / genders['total_sum']

        ages = founder_data.copy()
        ages = ages.loc[:, ['year', 'age']]
        ages = ages.dropna()

        means = pd.DataFrame(ages.groupby(['year'])['age'].mean())
        means = means.reset_index()

        genders = pd.merge(genders, means, on = 'year')

        if 'Num of New Male Founders' not in gender_indicators:
            genders.loc[:, 'male_count'] = 'N/A'
        if 'Num of New Female Founders' not in gender_indicators:
            genders.loc[:, 'female_count'] = 'N/A'
        if 'Average Age of New Founders' not in gender_indicators:
            genders.loc[:, 'age'] = 'N/A'

        genders = genders[genders['year'] >= range_start]
        genders = genders[genders['year'] <= range_end]

        genders.loc[:, 'left'] = genders['year'].astype(float) - 0.5
        genders.loc[:, 'right'] = genders['year'].astype(float) + 0.5

        return ColumnDataSource(genders)

    # %% plot data
    def make_gender_plot(src):
        p1 = figure(plot_width = 800, plot_height = 550,
            title = 'Genders of New Founders in Tech-City by years',
            x_axis_label = 'YEAR',
            y_axis_label = 'NUM',
            )

        p1.line(source = src, x = 'year', y = 'female_count',
            color = 'mediumvioletred',
            legend_label = 'Num of New Female Founders')
        p1.line(source = src, x = 'year', y = 'male_count',
            color = 'goldenrod',
            legend_label = 'Num of New Male Founders')

        hover1 = HoverTool(tooltips = [
            ('Year', '@year'),
            ('Number of New Male Founders', '@male_count'),
            ('Number of New Female Founders', '@female_count')])
        p1.add_tools(hover1)
        p1.legend.location = 'top_left'

        p2 = figure(plot_width = 800, plot_height = 550,
            title= 'Accumulated Distribution of Genders in Tech-City by years',
            x_axis_label = 'YEAR',
            y_axis_label = 'PERCENTAGE',
            y_range = (0, 120),
            )
        p2.quad(source = src, bottom = 0, top = 'female_perc',
            left = 'left', right = 'right',
            color = 'lightpink', fill_alpha = 0.7,
            hover_fill_color = 'mediumvioletred',
            legend = 'Female Founders',
            hover_fill_alpha = 1.0, line_color = 'black')
        p2.quad(source = src, bottom = 'female_perc', top = 100,
            left = 'left', right = 'right',
            color = 'darkorange', fill_alpha = 0.7,
            hover_fill_color = 'goldenrod',
            legend = 'Male Founders',
            hover_fill_alpha = 1.0, line_color = 'black')
        hover2 = HoverTool(tooltips = [
            ('Year', '@year'),
            ('Accumulated Proportion of Male Founders', '@male_perc%'),
            ('Accumulated Proportion of Female Founders', '@female_perc%')
            ])
        p2.add_tools(hover2)

        p = row(p1, p2)

        return p



    ##########
    # update #
    ##########
    def update_industry(attr, old, new):
        # %% industry
        new_industry_src, new_industry_par_src = make_industry_dataset(
            range_start = industry_range_select.value[0],
            range_end = industry_range_select.value[1],
            year_select = industry_year_select.value)

        industry_src.data.update(new_industry_src.data)
        industry_par_src.data.update(new_industry_par_src.data)

    def update_nation(attr, old, new):
        # %% nation
        new_nation_src, new_nation_1_src = make_nation_dataset(
            range_start = nation_range_select.value[0],
            range_end = nation_range_select.value[1],
            year_select = nation_year_select.value)

        nation_src.data.update(new_nation_src.data)
        nation_1_src.data.update(new_nation_1_src.data)

    def update_gender(attr, old, new):
        # %% gender
        gender_indicators = [gender_indicator_selection.labels[i]
            for i in gender_indicator_selection.active]
        new_gender_src = make_gender_dataset(
            gender_indicators,
            range_start = gender_range_select.value[0],
            range_end = gender_range_select.value[1])

        gender_src.data.update(new_gender_src.data)


    ###################
    # set controllers #
    ###################
    # %% industries
    industry_year_select = Slider(start = 1980, end = 2020, value = 2020,
        step = 1, title = 'Choose the year')
    industry_year_select.on_change('value', update_industry)

    industry_range_select = RangeSlider(start = 1980, end = 2020,
        value = (1980, 2020), title = 'Time Period (year)')
    industry_range_select.on_change('value', update_industry)

    # %% nations
    nation_year_select = Slider(start = 1980, end = 2020, value = 2020,
        step = 1, title = 'Choose the year')
    nation_year_select.on_change('value', update_nation)

    nation_range_select = RangeSlider(start = 1980, end = 2020,
        value = (1980, 2020), title = 'Time Period (year)')
    nation_range_select.on_change('value', update_nation)

    # %% gender
    gender_range_select = RangeSlider(start = 1980, end = 2020,
        value = (1980, 2020), title = 'Time Period (year)')
    gender_range_select.on_change('value', update_gender)

    available_indicators = [
        'Num of New Male Founders', 'Num of New Female Founders']
    gender_indicator_selection = CheckboxGroup(labels = available_indicators,
        active = [0, 1])
    gender_indicator_selection.on_change('active', update_gender)

    initial_gender_indicators = [gender_indicator_selection.labels[i]
        for i in gender_indicator_selection.active]




    #######################
    # make plots and maps #
    #######################
    # %% industries
    industry_src, industry_par_src = make_industry_dataset(
        range_start = industry_range_select.value[0],
        range_end = industry_range_select.value[1],
        year_select = industry_year_select.value)

    industry_plot = make_industry_plot(industry_src)
    industry_par = make_par_chart(industry_par_src)

    # %% nations
    nation_src, nation_1_src = make_nation_dataset(
        range_start = nation_range_select.value[0],
        range_end = nation_range_select.value[1],
        year_select = nation_year_select.value)

    nation_plot = make_nation_plot(nation_src)
    nation_map = make_nation_map(nation_1_src)

    # %% gender
    gender_src = make_gender_dataset(
        initial_gender_indicators,
        range_start = gender_range_select.value[0],
        range_end = gender_range_select.value[1])

    gender_plot = make_gender_plot(gender_src)



    ########
    # text #
    ########
    # %% industries
    industry_title_1 = Div(
        text =
        '''
        <b>Diversification of Industries in Tech City</b>
        '''
        )

    industry_description_1 = Div(
        text =
        '''
        Tech City observed an industry diversification in the comapnies
        present in the area. Indeed, the number of different industries
        in the Tech City increased from 164 in 2000, to 325 in 2011 and
        651 in 2020 which represents a 100% increase in the number of
        industries between 2011 and 2020
        '''
        )

    industry_title_2 = Div(
        text =
        '''
        <b>Data Visual</b>
        '''
        )

    # %% nation
    nation_title_1 = Div(
        text =
        '''
        <b>Diversification of International Background in Tech City</b>
        '''
        )

    nation_description_1 = Div(
        text =
        '''
        The second goal of the Tech City strategy was to attract foreign
        investors and international companies. Thus, immigration played a
        central role - <b>since 2011</b>, the government is trying to
        stimulate domestic talent growth while aiming to build and sustain
        a globally competitive technology cluster at the same time.
        '''
        )

    nation_description_2 = Div(
        text =
        '''
        <b>In order to do so, the government took some initiatives:</b>
        '''
        )

    nation_description_3 = Div(
        text =
        '''
        1. Invitation of 300 international start-ups to Tech City in <b>
        2012</b> to take part in a 'StartUp Games' initiative to show
        these startups what their eventual relocation to Tech City has to
        offer
        '''
        )

    nation_description_4 = Div(
        text =
        '''
        2. Facilitation of entrepreneur visas since <b>2012</b>
        '''
        )

    nation_description_5 = Div(
        text =
        '''
        3. Creation of Tech Nation Visa Scheme in <b>2018</b> enables the
        brightest and best tech talent from around the world to come and
        work in the UK's digital technology sector, contributing to
        maintaining the UK's position at the forefront of the global digital
        economy
        '''
        )

    nation_description_6 = Div(
        text =
        '''
        4. Tax breaks
        '''
        )

    nation_description_7 = Div(
        text =
        '''
        5. Creation of the LaunchPad competition for digital firms in
        <b>2011</b>
        '''
        )

    nation_description_8 = Div(
        text =
        '''
        6. Cheaper finance for SMES
        '''
        )

    nation_reference_1 = Div(
        text =
        '''
        <a href="https://startups.co.uk/news/startup-games-to-attract-foreign-start-ups-to-tech-city/">Reference 1</a>
        '''
        )

    nation_reference_2 = Div(
        text =
        '''
        <a href="https://technation.io/visa/">Reference 2</a>
        '''
        )

    nation_reference_3 = Div(
        text =
        '''
        <a href="https://www.demos.co.uk/files/A_Tale_of_Tech_City_web.pdf">
        Reference 3</a>
        '''
        )

    nation_title_2 = Div(
        text =
        '''
        <b>Data Visual</b>
        '''
        )

    nation_description_9 = Div(
        text =
        '''
        Following these initiatives, Tech City saw a tremendous diversity
        in the companies' countries of origin. Indeed, the number of countries
        of origin of the companies in that area increased from 33 to 84
        in 2011 to 161 in 2020 which represents a 92% increase between 2011
        and 2020. Companies from Asia, Africa and America began to be more
        present in Tech City.
        '''
        )

    # %% gender
    gender_title_1 = Div(
        text =
        '''
        <b>Diversification of Genders in Tech City</b>
        '''
        )

    gender_description_1 = Div(
        text =
        '''
        In 2018, only 19% of the digital tech workforce was female, compared
        to 49% for all UK jobs. Many governmental, public and privately-run
        organisations took some initiatives to help promote gender diversity
        in tech city:
        '''
        )

    gender_description_2 = Div(
        text =
        '''
        <b>Tech Talent Charter in 2018</b> - A commitment by public and
        privately-run organisations to a set of undertakings that aim to
        deliver greater gender diversity in the tech workforce of the UK,
        one that better reflects the makeup of the population.
        '''
        )

    gender_description_3 = Div(
        text =
        '''
        <b>Wiki edit-a-thon</b> - Supported by the Wikimedia Foundation,
        the edit-a-thon was organised to tackle the gender imbalance in
        Wikipedia pages and to encourage more women to edit entries. The
        teenage girls and tech entrepreneurs worked together to create
        new profiles of London women in order to increase the recognition
        of these women on the internet.
        '''
        )

    gender_reference_1 = Div(
        text =
        '''
        <a href="https://smartlondon.medium.com/three-city-initiatives-to-
        promote-diversity-in-londons-tech-community-8d31c7bc9453">
        Reference 1</a>
        '''
        )

    gender_title_2 = Div(
        text =
        '''
        <b>Data Visual</b>
        '''
        )


    ###############
    # set layouts #
    ###############
    # %% industries
    industry_plot_controls = WidgetBox(industry_range_select)
    industry_par_controls = WidgetBox(industry_year_select)

    industry_plot_layout = column(industry_plot_controls, industry_plot)
    industry_par_layout = column(industry_par_controls, industry_par)
    industry_graph_layout = row(industry_plot_layout, industry_par_layout)
    industry_layout = column(
        industry_title_1,
        industry_title_2,
        industry_description_1,
        industry_graph_layout)

    # %% nation
    nation_plot_controls = WidgetBox(nation_range_select)
    nation_map_controls = WidgetBox(nation_year_select)

    nation_plot_layout = column(nation_plot_controls, nation_plot)
    nation_map_layout = column(nation_map_controls, nation_map)
    nation_graph_layout = row(nation_plot_layout, nation_map_layout)
    nation_layout = column(
        nation_title_1,
        nation_description_1,
        nation_description_2,
        nation_description_3,
        nation_description_4,
        nation_description_5,
        nation_description_6,
        nation_description_7,
        nation_description_8,
        nation_reference_1,
        nation_reference_2,
        nation_reference_3,
        nation_title_2,
        nation_description_9,
        nation_graph_layout)

    # %% gender
    gender_plot_controls = WidgetBox(gender_indicator_selection,
        gender_range_select)

    gender_plot_layout = column(gender_plot_controls, gender_plot)
    gender_layout = column(
        gender_title_1,
        gender_description_1,
        gender_description_2,
        gender_description_3,
        gender_reference_1,
        gender_title_2,
        gender_plot_layout)


    # %% finalization
    layout = column(industry_layout, nation_layout, gender_layout)


    #######
    # tab #
    #######
    tab = Panel(child = layout, title = 'Transformation of Tech-City --- Diversification')

    return tab



















