/*
12/5/2016 Andrew Bloss, (14125471 row(s) affected)
    from [ClientDB_CPID72].[dbo].[PV80DailyDBMSummary]
    where ActiveFlag = 1
*/

with T as (
    select  distinct [date], ControlID
    from [ClientDB_CPID72].[dbo].[PV80DailyDBMSummary]
    where ActiveFlag = 1
),
T2 as (
    select [Date], ControlID, RowNum = Row_Number() over(partition by [date] order by ControlID desc)
    from T
) -- Test with select. RowNum should be one.
select * from t2 order by [Date] desc, ControlID desc

--update [ClientDB_CPID72].[dbo].[PV80DailyDBMSummary]
--set ActiveFlag = 0,
--    UpdateDateTime = GetDate()
--where cast([date] as varchar(50)) + cast(ControlID as varchar(20)) in (
--    select cast([date] as varchar(50)) + cast(ControlID as varchar(20))
--    from T2
--    where rownum > 1
--);
