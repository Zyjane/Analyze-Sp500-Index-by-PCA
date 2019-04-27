# -*- coding: utf-8 -*-
"""
Created on Mon Apr 22 21:21:24 2019

@author: Jane
"""

from pandas_datareader import data as pdr
import pandas as pd
import fix_yahoo_finance as yf
yf.pdr_override() # <== that's all it takes :-)

stock_loc = 'D:/biostat_2019_spring/Bios_669/Final Project/result_from_python'

stocks_list = pd.read_excel(stock_loc+'/namelist.xlsx').iloc[:,1].tolist()

#stocks_list.index("CASH_USD")
#stocks_list=stocks_list[334:]

for stock in stocks_list:
    data = pdr.get_data_yahoo(stock, start="2009-03-30", end="2019-04-15")
    data.to_csv('D:/biostat_2019_spring/Bios_669/Final Project/SP500/'+stock+'.csv')



