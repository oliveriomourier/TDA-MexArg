
"""
# -- --------------------------------------------------------------------------------------------------- -- #
# -- project: A SHORT DESCRIPTION OF THE PROJECT                                                         -- #
# -- script: main.py : python script with the main functionality                                         -- #
# -- author: YOUR GITHUB USER NAME                                                                       -- #
# -- license: THE LICENSE TYPE AS STATED IN THE REPOSITORY                                               -- #
# -- repository: YOUR REPOSITORY URL                                                                     -- #
# -- --------------------------------------------------------------------------------------------------- -- #
"""


import pandas as pd
import data as dt
import os
import sys
import json
import numpy as np
project_folder = os.path.abspath('')
sys.path.insert(0,project_folder)
# -- Visualization
import plotly.graph_objects as go
# -- Project scripts
import visualizations as vs
import functions as fn
#import pyarrow.parquet as pq


with open('files\\uniswapv3_all_swaps_sqrtPriceX96.json', 'r') as archivo:
    json_data = json.load(archivo)

# 1.- OnChain Data metrics


#type(json_data)
#len(json_data)
#d0 = json_data[0]
#d0.keys()
#d0['timestamp']
#d0['pool']


price_wethusdc = []
for i in range(len(json_data)):
    data = json_data[i]
    price96 = float(data["sqrtPriceX96"])
    price1 = (price96 / (2**96)) ** 2
    decimals_weth = 10e18
    decimals_usdc = 10e6
    decimals_wethusdc = int(decimals_weth / decimals_usdc)
    price = decimals_wethusdc / price1
    price_wethusdc.append(price)
    i = i+1


nt = []
for i in range(len(json_data)):
    t = json_data[i]['timestamp']
    nt.append(t)
    i = i+1


volume_quote = []
for i in range(len(json_data)):
    t = json_data[i]['amount0']
    volume_quote.append(t)
    i = i+1


volume_base = []
for i in range(len(json_data)):
    t = json_data[i]['amount1']
    volume_base.append(t)
    i = i+1

df_swaps = pd.DataFrame({
                    'id': range(1, len(json_data) + 1),
                    'timestamp': pd.to_datetime((nt), unit='s'),
                    'weth/usdc': price_wethusdc,
                    'symbol_quote': 'USDC',
                    'volume_quote': (volume_quote),
                    'symbol_base': 'WETH',
                    'volume_base': (volume_base)
                    })
#df_swaps

#df_swaps.dtypes
df_swaps['volume_quote'] = pd.to_numeric(df_swaps['volume_quote'])
df_swaps['volume_base'] = pd.to_numeric(df_swaps['volume_base'])


df_swaps['swap'] = df_swaps['volume_base'].apply(fn.swap)
df_swaps['swap_detail'] = df_swaps['volume_base'].apply(fn.swap_detail)

df_swaps.head(10)
df_swaps.tail(10)

df_final = fn.pt_metrics(data=df_swaps)
df_final


# 2.- Does the price follow a martingale process ?

# Pt = E [Pt+1] ≡ E [Pt+1] = Pt

price_mg = [ ]
for i in range(len(json_data)):
    precios = json_data[i]['pool']["token0Price"]
    price_mg.append(precios)
    i = i+1
price_mg = list(map(float, price_mg))

price_e = sum(price_mg) / len(price_mg)

if price_e == price_mg[-1]:
    print("The price follows a martingale process")
else:
    print("The price does not follow a martingale process")