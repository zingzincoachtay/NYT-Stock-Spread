-- -MYSQL
-- --PostgreSQL

-- -USE publicly_held;
\c quote
DROP TABLE IF EXISTS temp_inonebucket;
-- -CREATE TABLE IF NOT EXISTS temp_inonebucket (`Sector` char(21),`LastSale` double(8,4),`Name` char(62),`industry` char(62),`Symbol` char(14));
CREATE TABLE IF NOT EXISTS temp_inonebucket ("Sector" varchar(21),"LastSale" numeric,"Name" varchar(62),"industry" varchar(62),"Symbol" varchar(14));

-- -INSERT INTO temp_inonebucket (`Sector`,`LastSale`,`Name`,`industry`,`Symbol`)
-- -    SELECT `Sector`,`LastSale`,`Name`,`industry`,`Symbol` FROM nasdaq
;
INSERT INTO temp_inonebucket ("Sector","LastSale","Name","industry","Symbol")
    SELECT "Sector","LastSale","Name","industry","Symbol" FROM nasdaq
;
-- -INSERT INTO temp_inonebucket (`Sector`,`LastSale`,`Name`,`industry`,`Symbol`)
-- -    SELECT `Sector`,`LastSale`,`Name`,`industry`,`Symbol` FROM nysq
;
INSERT INTO temp_inonebucket ("Sector","LastSale","Name","industry","Symbol")
    SELECT "Sector","LastSale","Name","industry","Symbol" FROM nysq
;
-- -INSERT INTO temp_inonebucket (`Sector`,`LastSale`,`Name`,`industry`,`Symbol`)
-- -    SELECT `Sector`,`LastSale`,`Name`,`industry`,`Symbol` FROM amex
;
INSERT INTO temp_inonebucket ("Sector","LastSale","Name","industry","Symbol")
    SELECT "Sector","LastSale","Name","industry","Symbol" FROM amex
;

DROP TABLE IF EXISTS onebucket;
-- -CREATE TABLE IF NOT EXISTS onebucket (`Sector` char(21),`LastSale` double(8,4),`Name` char(62),`industry` char(62),`Symbol` char(14));
CREATE TABLE IF NOT EXISTS onebucket ("Sector" varchar(21),"LastSale" double precision,"Name" varchar(62),"industry" varchar(62),"Symbol" varchar(14));

-- -INSERT INTO onebucket (`Sector`,`LastSale`,`Name`,`industry`,`Symbol`)
-- -    SELECT DISTINCT `Sector`,`LastSale`,`Name`,`industry`,`Symbol` from temp_inonebucket
INSERT INTO onebucket ("Sector","LastSale","Name","industry","Symbol")
    SELECT DISTINCT "Sector","LastSale","Name","industry","Symbol" from temp_inonebucket
	WHERE "LastSale"<=150.00 AND NOT "LastSale"<1.00
	  AND NOT ("Sector"='' AND "industry"='')
;
DROP TABLE IF EXISTS temp_inonebucket;

