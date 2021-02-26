#!/bin/bash
export TODAY=`date +%Y%m%d`
export DAILIES="./market-daily"
export IMPORTS="./market-importable"
export commonurl="https://www.nasdaq.com/screening/companies-by-name.aspx?render=download&exchange"

export cmdreq='dos2unix'
if ! [ $( command -v $cmdreq ) ]; then
  echo Needs $cmdreq. Install $cmdreq first.
  exit
fi

function curl_da_exchange {
  export teststr=$(echo $1 | tr [a-z] [A-Z])
  echo $teststr
  export Xd="$DAILIES/$1-$TODAY.csv"
  export Xi="$IMPORTS/$1"
  if [ -e $Xd ]; then
    echo "'$1' file already exists for today."
  else
    curl -LR  "$commonurl=$1" > $Xd
    dos2unix $Xd
    sed 's/"n\/\?a"/""/gi' $Xd > "$Xi.csv"
    python -c "import csv,json;print json.dumps(list(csv.DictReader(open('$Xi.csv'))))" > "$Xi.json"
  fi
  ./quote2sql.py "$Xi.json" > "$Xi.sql"
}

f[0]="nasdaq"
f[1]="nysq"
f[2]="amex"
# bash allows this syntax too
#f=("nasdaq","nysq","amex")

curl_da_exchange ${f[0]}
curl_da_exchange ${f[1]}
curl_da_exchange ${f[2]}

echo "... done"

export SYMBDIRd="$DAILIES/symdict-$TODAY.txt"
export SYMBDIRi="$IMPORTS/symdict"
if [ -e $SYMBDIRd ]; then
  echo File already exists. Update is only possible if the file is removed.
  echo "May still try: sed '\$ d' '$SYMBDIRd' > '$SYMBDIRi.csv' && diff --side-by-side '$SYMBDIRd' '$SYMBDIRi.csv' | grep '[<>]' && python -c \"import csv,json;print json.dumps(list(csv.DictReader(open('$SYMBDIRi.csv'),delimiter='|')))\" > '$SYMBDIRi.json' "
else
  curl -LR "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt" > $SYMBDIRd
  dos2unix $SYMBDIRd
  echo "Delete the 'File Creation Time' row (an irregular csv pattern, i.e.)"
  #sed '$ d' $SYMBDIRd > "$SYMBDIRi.csv"
  #echo "Suggested: diff --side-by-side '$SYMBDIRd' '$SYMBDIRi.csv' | grep '[<>]' "
  #python -c "import csv,json;print json.dumps(list(csv.DictReader(open('$SYMBDIRi.csv'),delimiter='|')))" > "$SYMBDIRi.json"
fi

echo "... ... done"

f[3]="highestdividendyield"

export DIVIDENDd="$DAILIES/${f[3]}-$TODAY.csv"
export DIVIDENDi="$IMPORTS/${f[3]}"
if [ -e $DIVIDENDd ]; then
  echo The file does not need a daily update.
  echo But the file may be erased to download the current data.
else
  curl -LR "https://www.nasdaq.com/dividend-stocks/?render=download" > $DIVIDENDd
  echo "Correct the 'Date' format: MM/DD/YYYY to YYYY/MM/DD"
  sed 's|\([[:digit:]]\{2\}\)/\([[:digit:]]\{2\}\)/\([[:digit:]]\{4\}\)|\3-\1-\2|g' $DIVIDENDd > "$DIVIDENDi.csv"
  python -c "import csv,json;print json.dumps(list(csv.DictReader(open('$DIVIDENDi.csv'))))" > "$DIVIDENDi.json"
  ./quote2sql.py "$DIVIDENDi.json" > "$DIVIDENDi.sql"
  psql quote < "$DIVIDENDi.sql"
fi

echo "... ... ... done"

export COMPANIES="$IMPORTS/traded_companies"
cat "$IMPORTS/${f[0]}.sql" "$IMPORTS/${f[1]}.sql" "$IMPORTS/${f[2]}.sql" "$IMPORTS/${f[3]}.sql" > "$COMPANIES.sql"
echo "NEW SQL file created: $COMPANIES.sql"
echo "Loading SQL file: $COMPANIES.sql"
psql quote < "$COMPANIES.sql"

echo "... ... ... ... done"


