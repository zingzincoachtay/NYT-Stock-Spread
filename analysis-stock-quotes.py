#!/usr/bin/python
#
# https://ntguardian.wordpress.com/2018/07/17/stock-data-analysis-python-v2/
# 
#import sys,json
import pandas as pd
import pandas_datareader.data as web
from datetime import datetime as dt
from datetime import timedelta as td
import numpy as np

stocks = []
# 
#	 Obtain stock prices. Only weekdays are the trading days.
#	 - Yearly
#	 - Quarterly
#	 - Monthly
#	 - Weekly
# 
duras = [5*4*12,5*4*3,5*4,5]
Units = {duras[0]:"Y",duras[1]:"Q",duras[2]:"M",duras[3]:"W"}
to0 = dt.today()
end = to0.strftime('%Y-%m-%d')
# 
#	 Getting Data
#	 - previously: AMD, LUV, CVS, PGR
#	 - eliminated: SNAP
# 
repo = "iex"
symb = ["FPI","NNA","ASC","SALT","MAXR","IVC"]
#symb = ["CHL","ORA","PGR","SQ","PYPL","NVDA"]
#symb = ["PBR","AMD"]
#symb = ["NTDOY","MU","CTLT","WDC","STX","SNE"]
#symb = ["UA","GE","CHK","SNAP"]
marketsymb = "SPY"

def spokesperson(msg,xlist):
  return msg+' '+','.join(xlist)
def empty_pd():
  df_ = pd.DataFrame()
  return df_.fillna(0)
def YYYY_mm_dd(delta,today):
  ye0 = today - td(days=delta)
  return ye0.strftime('%Y-%m-%d')

def retrieve_stock_data(symb,repo,start,end):
  symL = {}
  validsymb = []
  for s in symb:
    try:
      symL[s] = web.DataReader(s,repo,start,end)
      validsymb.append(s)
    except KeyError:
      print("Symbol:"+s+" was invalid.")
  return (symL,validsymb)
def close_price_data(symb,repo,start,end):
  symL,validsymb = retrieve_stock_data(symb,repo,start,end)
  # 
  # Carry over to the next steps with the valid symbols.
  # 
  valid_stock_data = {}
  for s in validsymb:
    valid_stock_data[s] = symL[s]['close']
  return (pd.DataFrame(valid_stock_data),validsymb)

def Risk_LR(apr,spy,rrf):
  sy = apr.drop("SPY", 1).std()
  sx = apr.SPY.std()
  ybar = apr.drop("SPY", 1).mean() - rrf
  xbar = apr.SPY.mean() - rrf
  corr = apr.drop("SPY", 1).corrwith(apr.SPY)
  beta = corr * sy/sx
  alph = ybar - beta*xbar
  srpe = (ybar-rrf)/sy
  return (corr,beta,alph,srpe)

RESULTS_CORR = empty_pd() # literary, COOR is VAR(APRY)
RESULTS_BETA = empty_pd() # literary, BETA is AVG(APRY)
RESULTS_ALPH = empty_pd()
RESULTS_SRPE = empty_pd()
# 
# Getting Data
# ... Three-Month U.S. Treasury Bill 
# ... Used for calcualting the linear regression
# 
tbill,rrfsymb = retrieve_stock_data(["TB3MS"],"fred", YYYY_mm_dd(duras[1],to0) ,end)
rrf = tbill["TB3MS"].iloc[-1,0]

for dura in duras:
  print "Analysis of Stock Prices for this Duration:",dura
  Spd,validsymb = close_price_data(symb,repo, YYYY_mm_dd(dura,to0) ,end)
  # 
  # Changes from T0 to NOW
  #stock_return = stocks.apply(lambda x: x / x[0]) #changes from T0 to NOW
  #print( stock_return.head() - 1 )
  # 
  # Get SPY data and compare stock performance w.r.t. SPY
  # 
  market,validmarketsymb = retrieve_stock_data([marketsymb],repo, YYYY_mm_dd(dura,to0) ,end)
  Spd = Spd.join(market[marketsymb].loc[:,"close"]).rename(columns={"close":marketsymb})
  stocks.append(Spd)
  # 
  # 1) Annual Percentage Rate
  # ... There are 252 trading days in a year;
  # ... Changes from T(n) to T(n+1) - x.shift(1)
  # ...     log differences represent the daily percentage(%) change.
  # 
  stock_change = Spd.apply(lambda x: np.log(x) - np.log(x.shift(1)))
  stock_change_apr = stock_change * 252 * 100
  # 
  # 2) Linear Regression model with the risk-free rate (rrf) based on the 
  # ... U.S. Treasury Bills
  # ... R-r(RF): the excess return
  # ... alph: average excess return over the market...
  # ... beta: how much a stock moves in relation to to the market...
  # 3) Sharpe ratio (s)
  # 
  smcorr,lrbeta,lralph,lrsrpe = Risk_LR(stock_change_apr,"SPY",rrf)
  RESULTS_CORR = pd.concat([RESULTS_CORR,smcorr.rename(Units[dura])],axis=1,sort=False)
  RESULTS_BETA = pd.concat([RESULTS_BETA,lrbeta.rename(Units[dura])],axis=1,sort=False)
  #RESULTS_ALPH = pd.concat([RESULTS_ALPH,lralph.rename(Units[dura])],axis=1,sort=False)
  RESULTS_SRPE = pd.concat([RESULTS_SRPE,lrsrpe.rename(Units[dura])],axis=1,sort=False)
  symb = validsymb

print 'Market correlation w.r.t. SPY'
print RESULTS_CORR
print "Linear Regression model (beta)"
print RESULTS_BETA
print 'Sharpe ratios (s)'
print RESULTS_SRPE

