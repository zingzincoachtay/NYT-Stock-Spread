#!/usr/bin/python
#
# https://ntguardian.wordpress.com/2018/07/17/stock-data-analysis-python-v2/
# These scripts follow Curtis Miller's Stock Data Analysis with Python (Second Edition)
# - notes and commentaries left for study purposes
#  
#import sys,json
import pandas as pd
import pandas_datareader.data as web
#import quandl as qdl
import datetime as dt
import numpy as np

def spokesperson(msg,xlist):
  return msg+' '+','.join(xlist)

# 
#	 Seeking quarterly stock prices.
#
start = dt.datetime(2018,10,11)
end = dt.datetime(2019,1,11)

# 
#	 Getting Data
# 
#s = "AMD" # AMD
#q = qdl.get("WIKI/"+s,start_date=start,end_date=end)
symb = ["UA","X","LB","SNAP","GE"] # + Southwest, CVS(CVS), Progressive
#amd,luv,pgr = (web.DataReader(s,'iex',start,end) for s in sym)
symL = {}
validsymb = []
for s in symb:
  try:
    symL[s] = web.DataReader(s,"iex",start,end)
    validsymb.append( s )
  except KeyError:
    print("Symbol:"+s+" was invalid.")
  #print( type(symL[s]),pd.core.frame.DataFrame )
valid_stock_data = {}
for s in validsymb:
  valid_stock_data[s] = symL[s]['close']
stocks = pd.DataFrame(valid_stock_data)
# 
# 	Transforming the data in the stocks object,
# using a lambda function, which allows a 
# small function defined as a parameter to 
# another function or method.
# 
#stock_return = stocks.apply(lambda x: x / x[0])
#print( stock_return.head() - 1 )
# 
# 	Log differences of the data in stocks
# ... 'shift(1)' moves dates back by 1
#   effectively calculating the daily changes
#   from the previous dates
# 
#stock_change = stocks.apply(lambda x: np.log(x) - np.log(x.shift(1)))
#print( stock_change.head() )
# 
# Get SPY data and compare stock performance
#     w.r.t. SPY
# We often compare the performance of stocks 
# to the performance of the overall market. 
# SPY, which is the ticker symbol for the 
# SPDR S&P 500 exchange-traded mutual fund 
# (ETF), is a fund that attempts only to 
# imitate the composition of the S&P 500 
# stock index, and thus represents the value
# in 'the market'
# 
spyder = web.DataReader("SPY","iex",start,end)
#spyderdat = pd.read_csv("./spyhist.csv")
#spyderdat = pd.DataFrame(spyderdat.loc[:,["open","high","low","close","close"]].iloc[1:].as_matrix(),
#                          index=pd.DatetimeIndex(spyderdat.iloc[1:, 0]),
#                          columns=["Open", "High", "Low", "Close", "Adj Close"]).sort_index()
#spyder = spyderdat.loc[start:end]
stocks = stocks.join(spyder.loc[:,"close"]).rename(columns={"close": "SPY"})
print( spokesperson('Stock prices of:',validsymb) )
print( stocks.head() )
# 
# Classical Risk Metrics
# 1) Annual Percentage Rate
# ... There are 252 trading days in a year;
# ... the 100 converts to percentages.
# 
stock_change = stocks.apply(lambda x: np.log(x) - np.log(x.shift(1)))
stock_change_apr = stock_change * 252 * 100
print( spokesperson('Anual Percentage Rate of:',validsymb) )
print( stock_change_apr.tail() )
# 
# Linear Regression model with the risk-free
#     rate (rrf) based on U.S. Treasury Bills
#     Bills
# R - r(RF): the excess return
# alph: average excess return over the market
# beta: how much a stock moves in relation to
#     to the market...
# beta>1: stock generally moves in the same
#       direction as the market
# beta=1: stock moves strongly in response to
#       the market
# |beta|<1: stock is less responsive to the 
#         market
# 
sy = stock_change_apr.drop("SPY", 1).std()
sx = stock_change_apr.SPY.std()
tbill = web.DataReader("TB3MS","fred",start,end)
rrf = tbill.iloc[-1,0]
ybar = stock_change_apr.drop("SPY", 1).mean() - rrf
xbar = stock_change_apr.SPY.mean() - rrf
smcorr = stock_change_apr.drop("SPY", 1).corrwith(stock_change_apr.SPY)
print( spokesperson('Market correlation w.r.t. SPY:',validsymb) )
print(smcorr)
beta = smcorr * sy/sx
print("Linear Regression model (alph)")
print(beta)
alpha = ybar - beta*xbar
print("Linear Regression model (beta)")
print(alpha)
# 
#	 Sharpe ratio (s)
# The value represents the volatility of the 
# stock. Larger the Sharpe ratio, larger the 
# stock's excess returns relative to the 
# stock's volatility.
# It is also tied to the t-test to determine 
# if a stock earns more on average than the
# risk-free rate; 
# 
sharpe = (ybar-rrf)/sy
print( spokesperson('Sharpe ratios of:',validsymb) )
print( sharpe )


