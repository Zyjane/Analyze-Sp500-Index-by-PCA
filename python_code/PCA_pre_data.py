# -*- coding: utf-8 -*-
"""
Created on Sun Apr 21 13:49:22 2019

@author: Jane
"""

import numpy as np
import os
import pandas as pd
               
## get the SP500 value for reference, we need to fit all stocks' date with SP500's date

#get the adjust closing value of 
#sp500_raw.iloc[:,5]

##delete BHF because its price changes too much at the date (2017/7/12)
stock_loc = 'D:/biostat_2019_spring/Bios_669/Final Project'


names = os.listdir(stock_loc+'/SP500')
close = np.zeros((2529,504))

sp500 = pd.read_csv(stock_loc+'/result_from_python/sp500.csv')
sp500.index=pd.to_datetime(sp500.iloc[:,0])

for i, stock in enumerate(names):
    sloc = stock_loc +'/SP500/'+ stock
    stock= pd.read_csv(sloc )
    stock.index=pd.to_datetime(stock.iloc[:,0])
    # method of filling missing value
    ##ffill uses former daily value and bfill uses next daily value. 
    stock2 = stock.reindex(index = sp500.index, method = 'ffill')
    stock3 = stock2.fillna(method = 'bfill')
    ## Use the adjusted close price to calculate return matrix
    close[:,i] = stock3.iloc[:,5]


type(close)




## delete the csv for every elements in the name list
names_fordf=[name.replace(".csv", "") for name in names]+['Date']
## The close matrix is for the matrix starting from the second rows - the matrix starting the first row
ret_matx = (close[1:,:] - close[:-1,:])/close[:-1,:]*100

## To get the return rate from the start date
## The close[1:,:] matrix record from the second row to the last row
## The close[0,:] matrix is from the first row to the last two row.

ret_matx_from_start = (close[1:,:] - close[0,:])/close[0,:]*100


ret_df=pd.DataFrame(ret_matx)
ret_df['Date']=sp500.index[1:]

ret_matx_from_start_df=pd.DataFrame(ret_matx_from_start)
ret_matx_from_start_df['Date']=sp500.index[1:]
## rename every columns in the dataframe by column
ret_df.columns=names_fordf
ret_df.to_csv(stock_loc+'/return_matrix.csv')

ret_matx_from_start_df.columns=names_fordf
ret_matx_from_start_df.to_csv(stock_loc+'/return_matrix_from_start.csv')




import numpy.linalg as la
## The return has been standarized, so we could use covariance 
covx = np.cov(ret_matx.T)
w,v = la.eig(covx)
vector=pd.DataFrame(v)
vector["stock_name"]=[name.replace(".csv", "") for name in names]
vector.to_csv(stock_loc+'/eigenvector.csv')
pd.DataFrame(w).to_csv(stock_loc+'/eigenvalue.csv')



##To get the daily return of PC1;

v1= np.array(v[:,0])
PC1=np.dot(ret_matx,v1*v1)

##get the daliy return of SP500
arraysp=np.array(sp500)
sp500_return_from_start = (arraysp[1:,5] - arraysp[:-1,5])/arraysp[:-1,5]*100

y=pd.DataFrame(PC1)
y["Sp500"]=sp500_return_from_start
name=['PC1','Sp500']
y.columns=name
y.to_csv(stock_loc+'/result_from_python/PC1_sp500.csv')
