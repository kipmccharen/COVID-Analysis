from pytrends.request import TrendReq
import pandas as pd
import Levenshtein

#https://colab.research.google.com/drive/1PVpsyj6w07Qcssk13KtkJr7lE0kYm7jD?usp=sharing#scrollTo=nqD54Vv3LTmy
kwds=['homeless', 'coronavirus', 'covid homeless testing']
collist = ['date','isPartial']
collist = collist + kwds

pytrend = TrendReq()
dfs = pd.DataFrame(columns = collist)

us_state_abbrev = {'Alabama': 'AL', 'Alaska': 'AK', 'American Samoa': 'AS', 'Arizona': 'AZ', 'Arkansas': 'AR', 'California': 'CA', 'Colorado': 'CO', 'Connecticut': 'CT', 'Delaware': 'DE', 'District of Columbia': 'DC', 'Florida': 'FL', 'Georgia': 'GA', 'Guam': 'GU', 'Hawaii': 'HI', 'Idaho': 'ID', 'Illinois': 'IL', 'Indiana': 'IN', 'Iowa': 'IA', 'Kansas': 'KS', 'Kentucky': 'KY', 'Louisiana': 'LA', 'Maine': 'ME', 'Maryland': 'MD', 'Massachusetts': 'MA', 'Michigan': 'MI', 'Minnesota': 'MN', 'Mississippi': 'MS', 'Missouri': 'MO', 'Montana': 'MT', 'Nebraska': 'NE', 'Nevada': 'NV', 'New Hampshire': 'NH', 'New Jersey': 'NJ', 'New Mexico': 'NM', 'New York': 'NY', 'North Carolina': 'NC', 'North Dakota': 'ND', 'Northern Mariana Islands':'MP', 'Ohio': 'OH', 'Oklahoma': 'OK', 'Oregon': 'OR', 'Pennsylvania': 'PA', 'Puerto Rico': 'PR', 'Rhode Island': 'RI', 'South Carolina': 'SC', 'South Dakota': 'SD', 'Tennessee': 'TN', 'Texas': 'TX', 'Utah': 'UT', 'Vermont': 'VT', 'Virgin Islands': 'VI', 'Virginia': 'VA', 'Washington': 'WA', 'West Virginia': 'WV', 'Wisconsin': 'WI', 'Wyoming': 'WY' }

def lower_nospace(txt):
    return txt.lower().replace(' ', '')

def statename_to_abbr(txt):
    fullkeys = list(us_state_abbrev.keys())
    redkeys = [lower_nospace(x) for x in fullkeys]
    xtxt = lower_nospace(txt)
    dists = [Levenshtein.distance(xtxt, x) for x in redkeys]
    mtch = fullkeys[dists.index(min(dists))]
    return us_state_abbrev[mtch]

for i, k in enumerate(kwds):
    pytrend.build_payload(kw_list=[k], geo='US')
    subreg = pytrend.interest_by_region()
    subreg = subreg.reset_index().sort_values(by=k, ascending=False) #.head(5).to_string(header=False, index=False).split('\n')
    subreg['geoName'] = subreg['geoName'].apply(lambda x: statename_to_abbr(x))
    regions = subreg.head(5).to_string(header=False, index=False).split('\n')
    regions = '), '.join([' ('.join(x.split()) for x in regions]) + ')'
    print(k + r" attn ranked by state: ", regions)
    #quit()
    df = pytrend.interest_over_time()
    df = df.sort_index(ascending=False).reset_index().head(100)
    dfs = dfs.combine_first(df)

dfs = dfs[collist].drop(columns=['isPartial']).reset_index('date')
#print(dfs.head(25))

#https://vincent.readthedocs.io/en/latest/
vis = vincent.Map(width=1000, height=800)
vis.tabular_data(state_data, columns=['State', 'Unemployment'])
vis.geo_data(bind_data='data.id', reset=True, states=state_geo)
vis.update_map(scale=1000, projection='albersUsa')
vis + (['#c9cedb', '#0b0d11'], 'scales', 0, 'range')

dfs.to_csv('trends_data.csv')