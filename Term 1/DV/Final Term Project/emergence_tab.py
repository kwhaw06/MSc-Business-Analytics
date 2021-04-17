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
from bokeh.models import Panel, ColumnDataSource, HoverTool, Div
from bokeh.models.widgets import CheckboxGroup, RangeSlider, Select, Slider
from bokeh.tile_providers import get_provider, Vendors

def emergence_tab(company_data, founder_data, gis_data):
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

    ##############################################
    # def the function to prepare data for plots #
    ##############################################
    def make_dataset(plot_indicators, map_indicators,
        range_start = 1980, range_end = 2020, year_select = 2020):
        # calculate the accumulated number of companies
        companies = company_data.copy()
        companies.loc[:, 'company_count'] = 1
        companies = companies.loc[:, ['year', 'company_count']]
        companies = pd.DataFrame(companies.groupby(['year'])
            ['company_count'].sum())
        companies.loc[:, 'company_sum'] = companies['company_count'].cumsum()
        companies = companies.reset_index()
        data = companies.loc[:, ['year', 'company_sum']]

        # calculate the accumulated number of founders
        founders = founder_data.copy()
        founders.loc[:, 'founder_count'] = 1
        founders = founders.loc[:, ['year', 'founder_count']]
        founders = pd.DataFrame(founders.groupby(['year'])
            ['founder_count'].sum())
        founders.loc[:, 'founder_sum'] = founders['founder_count'].cumsum()
        founders = founders.reset_index()
        data = pd.merge(data, founders, on = 'year')
        data = data.drop(columns = ['founder_count'], axis = 1)
        data = data[data['year'] >= range_start]
        data = data[data['year'] <= range_end]

        company_nodes = gis_data.copy()
        companies_1 = company_data.copy()

        companies_1 = companies_1.loc[:, ['RegAddress.PostCode', 'year']]
        companies_1 = companies_1[companies_1['year'] <= year_select]
        companies_1.loc[:, 'count'] = 1
        companies_1 = pd.DataFrame(companies_1.groupby(['RegAddress.PostCode'])
            ['count'].sum())
        companies_1.loc[:, 'count'] = companies_1['count'].apply(np.log)
        companies_1.loc[:, 'count'] = companies_1['count'] * 30
        companies_1 = companies_1.reset_index()
        companies_1.loc[:, 'RegAddress.PostCode'] = companies_1[
            'RegAddress.PostCode'].str.replace(' ', '')
        companies_1 = pd.merge(companies_1, company_nodes,
            left_on = 'RegAddress.PostCode', right_on = 'postcode')
        companies_1 = companies_1.loc[:, ['count', 'x', 'y']]

        founder_nodes = gis_data.copy()
        founder_1 = founder_data.copy()

        founder_1 = founder_1[founder_1['year'] <= year_select]
        founder_1.loc[:, 'count'] = 1
        founder_1 = pd.DataFrame(founder_1.groupby(['RegAddress.PostCode'])
            ['count'].sum())
        founder_1.loc[:, 'count'] = founder_1['count'].apply(np.log)
        founder_1.loc[:, 'count'] = founder_1['count'] * 30
        founder_1 = founder_1.reset_index()
        founder_1.loc[:, 'RegAddress.PostCode'] = founder_1[
            'RegAddress.PostCode'].str.replace(' ', '')
        founder_1 = pd.merge(founder_1, founder_nodes,
            left_on = 'RegAddress.PostCode', right_on = 'postcode')
        founder_1 = founder_1.loc[:, ['count', 'x', 'y']]

        if 'Num of Companies' not in plot_indicators:
            data.loc[:, 'company_sum'] = 'N/A'
        if 'Num of Founders' not in plot_indicators:
            data.loc[:, 'founder_sum'] = 'N/A'

        if map_indicators != 'Num of Companies':
            companies_1 = pd.DataFrame(columns = ['count', 'x', 'y'])
        if map_indicators != 'Num of Founders':
            founder_1 = pd.DataFrame(columns = ['count', 'x', 'y'])



        return (ColumnDataSource(data), ColumnDataSource(companies_1),
            ColumnDataSource(founder_1))

    #############################
    # plot the map of tech-city #
    #############################
    def make_map(company_src, founder_src):
        # set the range of axises
        x_min = -12000
        x_max = -8500
        y_min = 6714000
        y_max = 6716000

        # define the map tiles to use
        tile_provider = get_provider(Vendors.CARTODBPOSITRON_RETINA)

        # plot the map
        p_map = figure(
            match_aspect = True,
            x_range = (x_min, x_max),
            y_range = (y_min, y_max),
            x_axis_type = 'mercator',
            y_axis_type = 'mercator',
            height = 550)

        p_map.circle(x = 'x', y = 'y', color = 'darkslategray',
            source = company_src, size = 10, fill_alpha = 0.4,
            radius = 'count')
        p_map.circle(x = 'x', y = 'y', color = 'brown',
            source = founder_src, size = 10, fill_alpha = 0.4,
            radius = 'count')

        p_map.grid.visible = True

        # add map tiles
        map = p_map.add_tile(tile_provider)
        map.level = 'underlay'

        # formatting
        p_map.xaxis.visible = False
        p_map.yaxis.visible = False

        return p_map

    ####################################
    # define the function to plot data #
    ####################################
    def make_plot(src):
        p = figure(plot_width = 1000, plot_height = 550,
            x_axis_label = 'YEAR',
            y_axis_label = 'NUM')
        p.line(source = src, x = 'year', y = 'company_sum',
            color = 'darkslategray', legend_label = 'Num of Companies')
        p.line(source = src, x = 'year', y = 'founder_sum',
            color = 'brown', legend_label = 'Num of Founders')
        p.legend.location = 'top_left'

        hover = HoverTool(tooltips = [
            ('Year', '@year'),
            ('Num of Companies', '@company_sum'),
            ('Num of Founders', '@founder_sum')])
        p.add_tools(hover)

        return p

    ##############################
    # define the update function #
    ##############################
    def update(attr, old, new):
        plot_indicators = [plot_indicator_selection.labels[i]
            for i in plot_indicator_selection.active]

        map_indicators = map_indicator_selection.value

        new_src, new_company_src, new_founder_src = make_dataset(
            plot_indicators,
            map_indicators,
            range_start = range_select.value[0],
            range_end = range_select.value[1],
            year_select = year_select.value)

        src.data.update(new_src.data)
        company_src.data.update(new_company_src.data)
        founder_src.data.update(new_founder_src.data)

    # %% set controllers
    available_indicators = ['Num of Companies', 'Num of Founders']

    plot_indicator_selection = CheckboxGroup(labels = available_indicators,
        active = [0, 1])
    plot_indicator_selection.on_change('active', update)

    map_indicator_selection = Select(title="Choose Indicator",
        value='Num of Companies', options=available_indicators)
    map_indicator_selection.on_change('value', update)

    year_select = Slider(start = 1980, end = 2020, value = 2020, step = 1,
        title = 'Choose the year')
    year_select.on_change('value', update)

    range_select = RangeSlider(start = 1980, end = 2020,
        value = (1980, 2020), title = 'Time Period (year)')
    range_select.on_change('value', update)


    # %% initial indicators and data source
    initial_plot_indicators = [plot_indicator_selection.labels[i]
        for i in plot_indicator_selection.active]

    initial_map_indicator = map_indicator_selection.value

    src, company_src, founder_src = make_dataset(
        initial_plot_indicators, initial_map_indicator,
        range_start = range_select.value[0],
        range_end = range_select.value[1],
        year_select = year_select.value)

    p1 = make_plot(src)
    p2 = make_map(company_src, founder_src)

    # %% put controls in a single element
    plot_controls = WidgetBox(plot_indicator_selection, range_select)
    map_controls = WidgetBox(map_indicator_selection, year_select)

    # text description:
    title_1 = Div(
        text =
        '''
        <b>Emergence and Development of London Tech City</b>
        '''
        )

    description_1 = Div(
        text =
        '''
        <b>In 2008</b>, Tech City - also known as East London Tech City or
        Silicon Roundabout - came to prominence, with a variety of
        companies operating in the area, including Last.FM, Poke and
        Trampoline System. Being located in Inner East London, Tech
        City presents a large number of advantages for firms: a central
        location, cheap rents, accessibility to the rest of London and
        proximity to other like-minded tech companies. Moreover, Tech City
        offers many nightlife activaties, which is highly attractive to
        the type of workers and employees that digital and tech business
        want to retain - young, urban, creative and tech-savvy.
        '''
        )

    description_2 = Div(
        text =
        '''
        <b>In Nov 2010</b>, then UK Prime Minister made a speech to emphasize
        the importance of East London Tech firms in the UK Economy and set
        ambitious plans to further develop Tech City, promising a governmental
        support. The proposals involved building the profile of the area
        through government funding (£15 million in Government Funding) and
        support. Besides, Tech City Investment Organisation (TCIO) was created
        by the government aiming to make Tech City the leading digital hub in
        Europe.
        '''
        )

    description_3 = Div(
        text =
        '<b>The Tech City strategy presented 3 clear objectives:</b>\n'
        )

    description_4 = Div(
        text =
        '1. Supporting the cluster of start-ups and small/midium-sized\
        businesses(SMES);'
        )

    description_5 = Div(
        text =
        '2. Attracting large international investers;'
        )

    description_6 = Div(
        text =
        '3. Using this momentum to steer high-tech activity further east,\
        including into a post-Games Olympic Park.'
        )

    description_7 = Div(
        text =
        '''
        <b>In May 2011</b>, TweetDeck, a social media dashboard, was
        launched by Twitter and gave another boost to the already growing
        repulation of Tech City.
        '''
        )

    reference_1 = Div(
        text =
        '''
        <a href="https://www.mbymontcalm.co.uk/blog/history-behind-tech-city/
        ">Reference 1</a>
        '''
        )

    reference_2 = Div(
        text =
        '''
        <a href="https://www.demos.co.uk/files/A_Tale_of_Tech_City_web.pdf
        ">Reference 2</a>
        '''
        )

    reference_3 = Div(
        text =
        '''
        <a href="https://www.gov.uk/government/speeches/east-end-tech-city-speech">Reference 3</a>
        '''
        )

    reference_4 = Div(
        text =
        '''
        <a href="https://olaonikoyi.medium.com/the-problems-at-east-london
        -tech-city-london-silicon-roundabout-d0bc2d4c7181">Reference 4</a>
        '''
        )

    title_2 = Div(
        text =
        '''
        <b>Data Visual</b>
        '''
        )

    description_8 = Div(
        text =
        '''
        The programme was a major success and resulted in an important
        multiplication of the number of tech companies operating in the
        region. In 2000, the number of companies in Tech City was 628.
        After Cameron's speech in 2011, the number of companies started
        increasing exponentially - indeed, the number of companies increased
        by 1204% between 2011 and 2020 (3,208 in 2011 vs. 41,841 in 2020).
        '''
        )

    # %% design the layout
    plot_layout = column(plot_controls, p1)
    map_layout = column(map_controls, p2)
    graph_layout = row(plot_layout, map_layout)
    layout = column(
        title_1,
        description_1,
        description_2,
        description_3,
        description_4,
        description_5,
        description_6,
        description_7,
        reference_1,
        reference_2,
        reference_3,
        reference_4,
        title_2,
        description_8,
        graph_layout)

    # %% make a tab with the layout
    tab = Panel(child = layout, title = 'Emergence of Tech-City')

    return tab








