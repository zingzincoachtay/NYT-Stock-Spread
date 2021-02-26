#!/usr/bin/python
import sys, csv, re, json, time

import pandas as pd
from datetime import datetime as dt
from datetime import timedelta as td
import pandas_datareader.data as web
from pandas_datareader.nasdaq_trader import get_nasdaq_symbols
#from PIL import Image, ImageDraw
#from cairosvg

#
#  initial values
#
apiname = 'iex'
records_suffix = '_'+apiname+'.rec'
td0 = 5 * 2
to0 = dt.today()
ye0 = to0 - td(days=td0)
#
#  https://pydata.github.io/pandas-datareader/stable/remote_data.html#iex
#
start = ye0.strftime('%Y-%m-%d')
end = to0.strftime('%Y-%m-%d')

#
#  lists were curl-ed with a separate shell script
#  lists of stock quote symbols in json
#  json should be the dict format
#
if len(sys.argv)!=2:
  print "Specify only the json file to convert into SQL."
  sys.exit()
f = sys.argv[1]
re_name = '([^\/]+)\/([^\/]+?)\.json$'
fidatsrc = re.search(re_name,f,re.IGNORECASE)
if( fidatsrc is None ):
  print "Errored"
  sys.exit()

try:
  records_parent = fidatsrc.group(1)
except:
  print "Could not parse the parent directory."
try:
  symbfilename = fidatsrc.group(2)
except:
  print "Does not seem to be the json file."

#
#  all data retrieved through panda in in.rec
#  in.rec: { 'Symbol':[{'date':...}, ...], ... }
#
#  filename inherits the input file
#    (symbol dict in json)
#  retrieve the past records (the file will be
#    updated after the successful retrieval) and
#    the records will be merged.
#
records = symbfilename+records_suffix
records_fin = records_parent+'/'+records+'.json'
records_tmp = records_parent+'/'+records+'.0'

#
#  open the existing record file to append
#    the new records in it
#  if the file does not already exist,
#    create a new dict to store current session.
#
print 'Final record file (JSON) will be written: '+records_fin
try:
  with open(records_fin,'r') as fh:
    history = json.load(fh)
except IOError:
  history = {}
#
#  prepare this temp file in case of sudden
#    interruptions (e.g., network, ^C)
#
print 'Temp record file (JSON) will be written: '+records_tmp
fb = open(records_tmp,'w')

with open(f,'r') as sf:
    indices = json.load(sf)
fb_sep = ''
for q in indices:
  sym = str( q['Symbol'] )
  try:
    df = web.DataReader(sym,apiname,start,end)
    #df = web.DataReader(sym,"robinhood")
  except KeyError:
    print("Symbol:"+sym+" was invalid.")
    df = {}
  if isinstance(df, pd.DataFrame):
    # Pandas dataframes have an index that is
    # used for grouping and fast lookups. The
    # index is not considered one of the columns.
    # To move the dates from the index to the
    # columns, you can use reset_index(),
    # which will make Date a column.
    # add symbol:[date,dj]
    #print(df)
    dj = df.reset_index().to_json(orient='records',date_format='iso')
    #print(dj)
    try:
      h = list(set( history[sym]+json.loads(dj) ))
    except:
      h = json.loads(dj)
    fb.write( fb_sep+sym+':'+json.dumps(h) )
    fb_sep = ','
    history[sym] = h
    print('Symbol:'+sym+' was successful.')
  #if sym == 'YI':
  #  break
  time.sleep(1.3)
fb.close()
with open(records_fin,'w+') as fr:
  json.dump(history,fr)
  print 'Final JSON file recorded: '+records_fin
#import filecmp
#import os
#if filecmp.cmp(records+'.0',records):
#  #os.remove(records+'.0')

#NYT = Image.new('RGB', (900,900), color=(255,255,255) )
#d = ImageDraw.Draw(NYT)
#d.text( (10,10), 'AAPL', fill=(0,0,0) )
#NYT.save('c.svg')
