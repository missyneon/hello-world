SELECT [Event Time] FROM ClientDB_CPID69_Staging.[dbo].PV78DailyDCMActivityLogStaging where isnumeric([Event Time]) = 0

SELECT CAST([ORD Value] AS bigint)  
FROM myTable  
WHERE IsNumeric(myVarcharColumn) = 1 AND myVarcharColumn IS NOT NULL  
GROUP BY myVarcharColumn

SELECT sum(CAST([ORD Value] AS bigint))
FROM ClientDB_CPID69_Staging.[dbo].PV78DailyDCMActivityLogStaging 
WHERE [ORD Value] <>   'TINTERNT062816302405'
or [ORD Value] <>   '{{ actor.a }}'
or [ORD Value] <>   'TNETQUOT062816341728'
or [ORD Value] <>   '[Random Number]'

SELECT sum(CAST([ORD Value] AS bigint)) FROM ClientDB_CPID69_Staging.[dbo].PV78DailyDCMActivityLogStaging where isnumeric([ORD Value]) = 1
--***********************************************************************************************************

Use ClientDB_Generic;
if object_id('tempdb..#i') is not null drop table #i;
go


exec CAST('10' AS bigint) 

declare @one = 'TINTERNT062816302405'

exec CAST(one AS bigint




select cast('TINTERNT062816302405' as bigint) from ClientDB_CPID69_Staging.[dbo].PV78DailyDCMActivityLogStaging
