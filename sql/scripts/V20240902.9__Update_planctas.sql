EXECUTE('
UPDATE
PLANCTAS 
SET PREVISIONA=100
where c6340 in (select c6271 from PRODUCTOS p where c6252=2 and TZ_LOCK=0) and C6310 not in (''02'') ;
')

EXECUTE('
UPDATE
PLANCTAS 
SET califica=''S''
where c6340 in (select c6271 from PRODUCTOS p where c6252=2 and TZ_LOCK=0);
')