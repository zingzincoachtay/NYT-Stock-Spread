-- -MYSQL
-- --PostgreSQL

--https://stackoverflow.com/questions/23165282/error-zero-length-delimited-identifier-at-or-near-line-1-delete-from-reg

-- -use publicly_held;
\c quote
DROP TABLE IF EXISTS selected4dividend;
CREATE TABLE IF NOT EXISTS selected4dividend ("Symbol" char(14));

--    where NOT Sector="Transportation"
-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Finance"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Finance'
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Basic Industries"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Basic Industries'
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -        select `Symbol` from onebucket
-- -        where Sector='Capital Goods'
INSERT INTO selected4dividend ("Symbol")
        select "Symbol" from onebucket
        where "Sector"='Capital Goods'
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -        select `Symbol` from onebucket
-- -        where Sector='Miscellaneous'
INSERT INTO selected4dividend ("Symbol")
        select "Symbol" from onebucket
        where "Sector"='Miscellaneous'
;

-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Energy"
-- -         and not (
-- -         industry regexp "gas|coal|refining|oilfield|oil companies"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Energy'
         and (
         "industry" !~* 'gas|coal|refining|oilfield|oil companies'
         )
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Health Care"
-- -         and not (
-- -         industry regexp "pharmaceutical|dental"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Health Care'
         and (
         "industry" !~* 'pharmaceutical|dental'
         )
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -        select `Symbol` from onebucket
-- -        where Sector="Consumer Durables"
-- -          and not (
-- -          industry regexp "chemicals|packaging"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Consumer Durables'
         and (
         "industry" !~* 'packaging'
         )
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -        select `Symbol` from onebucket
-- -        where Sector="Technology"
-- -          and not (
-- -          industry regexp "broadcasting and communications|professional services|industrial machinery|prepackaged software"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Technology'
         and (
         "industry" !~* 'prepackaged software'
          )
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Public Utilities"
-- -         and not (
-- -         industry regexp "gas|electric utilities"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Public Utilities'
         and (
         "industry" !~* 'gas|electric utilities'
         )
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Consumer Services"
-- -         and not (
-- -         industry regexp "transportation|broadcasting|food chain|movies|newspaper|telecommunication|television|video chains"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Consumer Services'
         and (
         "industry" !~* 'trusts'
         )
;
-- -INSERT INTO selected4dividend (`Symbol`)
-- -       select `Symbol` from onebucket
-- -       where Sector="Consumer Non-Durables"
-- -         and not (
-- -         industry regexp "tobacco|telecommunication|plastic|package goods|distributors"
INSERT INTO selected4dividend ("Symbol")
       select "Symbol" from onebucket
       where "Sector"='Consumer Non-Durables'
         and (
         "industry" !~* 'tobacco|plastic|distributors'
         )
;

