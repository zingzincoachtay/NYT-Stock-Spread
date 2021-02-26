#!/bin/bash

echo Join company profiles of multiple EXs and reduce duplicates
psql quote <run01a.sql
echo "Created 'onebucket' table"

echo "Create a sub-table with the select Stocks by Sectors and the dividend"
psql quote <run01b.sql 
echo "Created 'selected4dividend' table"

