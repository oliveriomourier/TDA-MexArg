
"""
# -- --------------------------------------------------------------------------------------------------- -- #
# -- project: A SHORT DESCRIPTION OF THE PROJECT                                                         -- #
# -- script: functions.py : python script with general functions                                         -- #
# -- author: YOUR GITHUB USER NAME                                                                       -- #
# -- license: THE LICENSE TYPE AS STATED IN THE REPOSITORY                                               -- #
# -- repository: YOUR REPOSITORY URL                                                                     -- #
# -- --------------------------------------------------------------------------------------------------- -- #
"""

import pandas as pd
import numpy as np

def swap(valor):
    if valor > 0:
        return 'buy'
    else:
        return 'sell'
    

def swap_detail(valor):
    if valor > 0:
        return 'Swap USDC for WETH'
    else:
        return 'Swap WETH for USDC'


def pt_metrics(data):
    precio_promedio = np.round(data['weth/usdc'].mean(), 4)
    volumen_total = np.round(data['volume_quote'].abs().sum() + data['volume_base'].abs().sum() , 4)
    precio_max = np.round(data['weth/usdc'].max(),4)
    precio_min = np.round(data['weth/usdc'].min(),4)
    #compras = data.loc[(data['swap'] == 'buy')]
    #volumen_compra = np.round(compras['volume_quote'].sum(),2)
    #ventas = data.loc[(data['swap'] == 'sell')]
    #volumen_venta = np.round(ventas['volume_quote'].sum(),2)
    #porcentaje_compras = np.round(len(data.loc[(data['swap'] == 'buy')]) / len(data) * 100, 2)
    #porcentaje_ventas = np.round(len(data.loc[(data['swap'] == 'sell')]) / len(data)* 100, 2)
    vq_max = np.round(data['volume_quote'].max(),4)
    vb_max = np.round(data['volume_base'].max(),4)
    vq_min = np.round(data['volume_quote'].min(),4)
    vb_min = np.round(data['volume_base'].min(),4)
    buy_trades = len(data.loc[(data['swap'] == 'buy')])
    sell_trades = len(data.loc[(data['swap'] == 'sell')])
    

    pt_df = pd.DataFrame({'metric': ['Average price', 'Total Traded Tolume', 'Max Traded Price', 
                                     'Min Traded Price', 'Max Traded Volume (Base)', 'Max Traded Volume (Quote)',
                                     'Min Traded Volume (Base)', 'Min Traded Volume (Quote)',
                                     'Buy Trades', 'Sell Trades'],
                            'value': [precio_promedio, volumen_total, precio_max, precio_min, 
                                      vb_max, vq_max, vb_min, vq_min, buy_trades, sell_trades]
                                     })
    
    pt_df.loc[0, 'value'] = '${:,.2f}'.format(float(pt_df.loc[0, 'value']))
    pt_df.loc[1, 'value'] = '{:,}'.format(float(pt_df.loc[1, 'value']))
    pt_df.loc[2, 'value'] = '${:,.2f}'.format(float(pt_df.loc[2, 'value']))
    pt_df.loc[3, 'value'] = '${:,.2f}'.format(float(pt_df.loc[3, 'value']))
    pt_df.loc[4, 'value'] = '{:,}'.format(float(pt_df.loc[4, 'value']))
    pt_df.loc[5, 'value'] = '{:,}'.format(float(pt_df.loc[5, 'value']))
    pt_df.loc[6, 'value'] = '{:,}'.format(float(pt_df.loc[6, 'value']))
    pt_df.loc[7, 'value'] = '{:,}'.format(float(pt_df.loc[7, 'value']))
    pt_df.loc[8, 'value'] = '{:,}'.format(float(pt_df.loc[8, 'value']))
    pt_df.loc[9, 'value'] = '{:,}'.format(float(pt_df.loc[9, 'value']))
    

    return pt_df

