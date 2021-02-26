#!/bin/bash

echo "Show the aggregate of company profiles by the Sector"
echo -p -e 'select Sector,avg(LastSale),count(Sector) from onebucket group by Sector;' publicly_held

echo "Show the aggregate of company profiles by the industry"
echo mysql -p -e 'select industry,avg(LastSale),count(industry) from onebucket group by industry;' publicly_held

psql quote < run02.sql > fidelity.csv

sed -i '1 d' fidelity.csv
sed -i '2 d' fidelity.csv
sed -i '$ d' fidelity.csv && sed -i '$ d' fidelity.csv

