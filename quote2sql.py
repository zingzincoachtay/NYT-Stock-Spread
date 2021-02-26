#!/usr/bin/python3
import sys,csv,json,re

import json2sql as j2q

if len(sys.argv)!=2:
  errmsg( 'Specify the file to turn into SQL.',[] )
  sys.exit()

db_name,fj = j2q.parseJS(sys.argv[1],j2q.db_sel)

#
# Aggregate Column Names
#
colnames = {};
#
# Aggregate CREATE Queries in q1
# Aggregate INSERT Queries in q2
#
q1 = j2q.init_t('quote',[db_name])
q2 = []
Ncols = {}
#
# Parse the CSV data
# Iterate by the keys of ROW
#
for j in fj:
  q2.append( j2q.insert_query([db_name,j]) )
  Ncols = j2q.colsizing(Ncols,j)

q1.append( j2q.create_query([db_name,Ncols]) )

print(        "\n".join(q1) )
print( "\n\n"+"\n".join(q2) )

