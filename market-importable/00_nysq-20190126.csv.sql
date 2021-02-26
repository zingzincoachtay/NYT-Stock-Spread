
CREATE DATABASE IF NOT EXISTS track_stock_prices;
USE track_stock_prices;
DROP TABLE IF EXISTS _nysq;
CREATE TABLE IF NOT EXISTS _nysq (Symbol char(14),Name char(62),LastSale char(8),MarketCap char(8),IPOyear char(4),Sector char(21),industry char(62),SummaryQuote char(39));

LOAD DATA LOCAL INFILE 'market-daily/nysq-20190126.csv' 
INTO TABLE _nysq
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
