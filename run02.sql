-- -MYSQL
-- --PostgreSQL

-- -use publicly_held;
\c quote

-- -select T1.symbol as "----",T1.name,round(T1.LastSale,2) as "$$$$",round(annualdividend/T1.LastSale*100,2) as "Yield",exdividenddate as EX,dividendpaymentdate as PAY,sector,industry 
select distinct T1."Symbol" as "----",T1."Name",round(T1."LastSale"::numeric,3) as "$$$$",round("annualdividend"::numeric,3) as "ANdiv",round("dividendyield"::numeric,3) as "divY%","Sector","industry" 
    from 
      (select * from onebucket) T1
-- -     ,(select * from selected4dividend) as T2
-- -     ,(select * from highestdividendyield) as T3
    inner join (select * from selected4dividend) T2 on T2."Symbol"=T1."Symbol"
    inner join (select * from highestdividendyield) T3 on T3."Symbol"=T2."Symbol"
    where 
-- -          (T1.symbol=T2.symbol and T2.symbol=T3.symbol) and
          dividendyield>2
-- -order by dividendyield DESC
order by "divY%" DESC
;

