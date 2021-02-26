#!/usr/bin/python
import sys,csv,json,re

# 
# Text-based Database Type
# 
db_types = { 0:["JSON","json"],1:["CSV","csv"] }
db_sel = 0
db_type = db_types[db_sel][0]
db_ext = db_types[db_sel][1]

if len(sys.argv)!=2:
  print "Specify only the "+db_type+" file to convert into SQL."
  sys.exit()
f = sys.argv[1]
re_dbname = '^.+\/([^\/]+?)\.'+db_ext+'$'
fidatsrc = re.search(re_dbname,f,re.IGNORECASE)
if( fidatsrc is None ):
  print "Errored"
  sys.exit()

try: db_sname = fidatsrc.group(1)
except:
  print "Does not seem to be the "+db_type+" file with a proper name."
db_name = db_sname
importable = f+'.sql'

# 
# Load the data
# 
fj = []
if db_type == "JSON" :
  with open(f,'r') as sf:
    fj = json.load(sf)
if db_type == "CSV"  :
  with open(f) as sf:
    fj = list( csv.DictReader(sf) )
# 
# Aggregate Column Names
# 
colnames = {};
# 
# Aggregate CREATE Queries in q1
# Aggregate INSERT Queries in q2
# 
q1 = []
q2 = []
# 
# Parse the CSV data
# Iterate by the keys of ROW
# 
for row in fj:
  q0 = ''
  q0_sep = ''
  for companyprofile in row:
    # empty column in the converted JSON file may be empty string or `null`
    if( companyprofile == "" or companyprofile == "null" ):
      continue
    # empty column in the unconverted CSV file may be `None`
    if( companyprofile is None ):
      continue
    LHS = '`{}`'.format(    companyprofile )
    RHS = '"{}"'.format(row[companyprofile])
    q0 += q0_sep+LHS+'='+RHS
    try:
      charlen = len( row[companyprofile] )
    except:
      print "Exception Errors in row: "+'/'.join(row)
      print json.dumps(row)
      continue
    if( companyprofile not in colnames or colnames[companyprofile] < charlen ):
      colnames[companyprofile] = charlen
    q0_sep = ','
  q2.append( 'INSERT INTO '+db_name+' SET '+q0+';' )
q0_sep = ''
for colname in colnames:
  LHS =     '`{}`'.format(          colname  )
  RHS = 'char({})'.format( colnames[colname] )
  if colname == "LastSale" or colname == "dividendyield" or colname == "annualdividend":
    RHS = "double(9,5)"
  if colname == "dividendpaymentdate" or colname == "exdividenddate":
    RHS = "date"
  q1.append( LHS+' '+RHS )
db_create = (
     'USE publicly_held;'
    ,'DROP TABLE IF EXISTS '+db_name+';'
    ,'CREATE TABLE IF NOT EXISTS '+db_name+' ('+','.join(q1)+');'
    ,"\n".join(q2)
)

with open(importable,'w') as db:
  db.write( "\n".join(db_create) )
print( "SQL file was created: "+importable )

