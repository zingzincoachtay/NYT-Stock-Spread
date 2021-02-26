import sys,re,json,csv

db_sel = 0

def errmsg(x):
  print( "ERR: {}".format(x) )
def parseJS(f,t):
  # 
  # Text-based Database Type
  # 
  db_types = { 0:["JSON","json"],1:["CSV","csv"] }
  db_type,db_ext = db_types[t]
  re_dbname = '([^\/]+)\.'+db_ext+'$'
  try:
    datsrc = regex(re_dbname,f)
  except:
    errmsg('Could not match the filename')
    sys.exit()
  try:
    db_sname = datsrc.group(1)
  except:
    errmsg('Could not match the proper {} file'.format(db_type) )
    sys.exit()
  # 
  # Load the data
  # 
  J = []
  with open(f,'r') as sf:
    if db_type == "JSON" : J = json.load(sf)
    if db_type == "CSV"  : J = list( csv.DictReader(sf) )
  return [db_sname,J]

def init_t(db,tbl):
  ## MYSQL
  #sqls = ['use {};'.format(db)]
  ## PostgreSQL
  sqls = ['\c {};'.format(db)]
  for t in tbl:
    sqls.append( 'drop table if exists {};'.format(t) )
  return sqls

def trim(x):
  return str(x).strip()
def escW(w):
  return '"{}"'.format( trim(w) )
def insert_query(ins):
  t,kv = ins
  setcols,setvals = [],[]
  for k in kv:
    ## MYSQL
    #setcols.append( escW(   k ) )
    #setvals.append( escW(kv[k]) )
    ## PostgreSQL
    j = kv[k]
    # empty column in the converted JSON file may be empty string or `null`
    # empty column in the unconverted CSV file may be `None`
    if k == "" or k == "null" or k is None : continue
    if j == "" or j == "null" or j is None : continue
    try: j = re.match('^(\d+)\.0+$', trim(j) ).group(1)
    except: j = j
    try: j = re.sub('\'','\'\'',trim(j) )
    except: j = j
    setcols.append( '"{}"'.format(k) )
    setvals.append( "'{}'".format(j) )
  return "insert into {} ({}) values ({});".format(t, ','.join(setcols),','.join(setvals) )
def colsizing(N,kv):
  for k in kv:
    v = kv[k]
    situ = len( trim(v) )
    # First iteration of first call, N is empty
    # Create dict immediately to avoid exception errors
    try:
      u = N[k]
    except:
      N.update({ k:['i',0] })
      u = N[k]
    if u[1] < situ :
      u[1] = situ
    # If new char found, immediately turn on 'char' column
    # If column is already 'char', keep 'char'
    if is_char(v) or u[0] == 'c' :
      u[0] = 'c'
    else:
    # If char not found, 
    # If and only if new int found in 'int' column, keep 'int'
      if is_int(v) and u[0] == 'i' :
        u[0] = 'i'
      else:
        u[0] = 'd'
    ## 'integer' max is +/-2147483647 (10-digit)
    if u[0] == 'i' and u[1] > 9 :
      u[0] = 'c'
  return N
def regex(m,x):
  return re.search(m, trim(x) ,re.IGNORECASE)
def is_char(x):
  # char is alphabet and non-word characters (i.e., symbols)
  # Includes A-z, _, \s, \W, but not 0-9, ., 
  # Should include everything but int and double/float 
  pat = regex('[^\d\.]',x)
  pat1 = is_int(x)
  pat2 = regex('^\d*\.\d+$',x)
  if pat : return 1
  else : return 0
  #if not pat1 and not pat2 : return 1
  #else : return 0
def is_int(x):
  pat = regex('^\d+$|^\d*\.0+$',x)
  if pat :  return 1
  else : return 0
def create_query(cr8):
  t,N = cr8
  colq = []
  for k in N:
    v = N[k]
    if k == "" or k == "null" or k is None : continue
    if v[0] == 'i':
      ## MYSQL
      #colq.append( '`{}` integer'.format( trim(k) ) )
      ## PostgreSQL
      colq.append( '{} integer'.format( escW(k) ) )
    elif v[0] == 'd':
      ## MYSQL
      #colq.append( '`{}` decimal(8,4)'.format( trim(k) ) )
      ## PostgreSQL
      colq.append( '{} decimal(8,4)'.format( escW(k) ) )
    else:
      ## MYSQL
      #colq.append( '`{}` char({})'.format( trim(k),v[1] ) )
      ## PostgreSQL
      colq.append( '{} varchar({})'.format( escW(k),v[1] ) )
  return 'create table if not exists {} ({});'.format(t, ','.join(colq) )

