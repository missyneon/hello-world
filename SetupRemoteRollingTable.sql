/*

Rolling Feeds

RUN THIS SCRIPT ON HQDMOSQL04.

Some feeds contains a data for the last x days. If old data is not deleted then each day prior to today
has an increasing multiple rows for the day until x is reached.

Old data in rolling feeds should be deleted or inactivated. To do this we:
*/
if object_id('tempdb..#i') is not null drop table #i;
go

select 
      ProcessorID = 2022
    , ClientParentName = 'Target'
    , ClientParentID = cast(null as int)
    , ProviderID = cast(null as int)
    , ProviderName = cast(null as int)
    , Stage2Database = cast('' as varchar(2000))
    , Stage2TableName = cast('' as varchar(2000))
into #i;

update #i 
set ClientParentID = ( 
        select ClientParentID 
        from [HQDMOSQL02].[ExstoDisplay].[dbo].[clientparent] 
        where (select ClientParentName from #i) is not null 
          and clientParentName like '%' + (select ClientParentName from #i) + '%'
);

update #i
set ProviderID = (
    select ProviderID
    from  [HQIMPETL01].[ExstoAdmin].[dbo].[ClientMetalAssignment]
    where ProcessorID = (select ProcessorID from #i)
        and ClientParentID = (select ClientParentID from #i)
        and DestinationStageID = 1
);

update #i
set Stage2Database = (
    select replace(DestinationDatabase, '#', ClientParentID)
    from [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] cs
    cross apply #i 
    where   cs.Processor_ID = (select ProcessorID from #i)
        and cs.DestinationStageID = 2
);

update #i
set Stage2TableName = (
    select replace(DestinationTableName, '#', ProviderID)
    from [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] cs
    cross apply #i 
    where   cs.Processor_ID = (select ProcessorID from #i)
        and cs.DestinationStageID = 2
);


select [Cols 2] = 'Cols 2', * 
from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationColumnDefinition] 
where destinationMetaDataID in (
    select ID 
    from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
    where destinationProcessorID = (select ProcessorID from #i) 
      and DestinationStageID = 2
) 
order by ColumnOrder

-- Part 2.

---- 1. Set DestinationMetaData RefreshData and RefreshRateInDays for both stages.
--update [HQIMPETL01].[ExstoAdmin].dbo.DestinationMetaData 
--set RefreshData = 1,
--    RefreshRateInDays = 30
--where DestinationProcessorID = (select ProcessorID from #i);

---- Add ActiveFlag and UpdateDateTime to Stage 2.
--declare @MaxColumnOrder int = (
--    select max(ColumnOrder)
--    from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationColumnDefinition] 
--    where destinationMetaDataID in (
--        select ID 
--        from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
--        where destinationProcessorID = (select ProcessorID from #i) 
--          and DestinationStageID = 2
--    )
--);

---- Add ActiveFlag to DestinationColumnDefinition.
--insert into [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition](
--                 DestinationMetaDataID, ColumnName,     ColumnDataType, ColumnOrder,         ActiveFlag, CreateDate, UpdateDate, DestinationStageID, SpecialTransformCode)
--    select top 1 DestinationMetaDataID, '[ActiveFlag]', 'BIT',          @MaxColumnOrder + 1, 1,          GetDate(),  GetDate(),  DestinationStageID, 1
--    from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
--    where destinationMetaDataID in (
--        select ID 
--        from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
--        where destinationProcessorID = (select ProcessorID from #i) 
--            and DestinationStageID = 2
--    );

---- Add UpdateDateTime to DestinationColumnDefinition.
--insert into [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition](
--                 DestinationMetaDataID, ColumnName,         ColumnDataType, ColumnOrder,         ActiveFlag, CreateDate, UpdateDate, DestinationStageID)
--    select top 1 DestinationMetaDataID, '[UpdateDateTime]', 'DateTime',     @MaxColumnOrder + 2, 1,          GetDate(),  GetDate(),  DestinationStageID
--    from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
--    where destinationMetaDataID in (
--        select ID 
--        from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
--        where destinationProcessorID = (select ProcessorID from #i) 
--            and DestinationStageID = 2
--    );


---- 2. Add ActiveFlag and UpdateDateTime to Stage 2 table. 
--declare @sql varchar(max) = '';

--with T as (
--    select '[' + Stage2Database + '].[dbo].[' + Stage2TableName + ']' as DBTableName, Stage2TableName as TableName
--    from #i
--)  
--select @sql = 'alter table ' + DBTableName  + ' add ActiveFlag BIT not null constraint ' + TableName + 'ActiveFlag_default default 1, UpdateDateTime DateTime null;' 
--from T;

--select @sql;

--exec(@sql);

-- 3. Add a third stage.
delete [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings]
where Processor_ID = (select ProcessorID from #i)
  and DestinationStageID = 3;

insert into [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] 
      (Processor_ID, SourceConnectionType, SourceServer,      SourceDatabase,      SourceTableName,      DestinationStageID, DestinationServer, DestinationDatabase, DestinationTableName,  HelpTicketServer, HelpTicketServerDatabase, HelpTicketTableName, InsertDate, DestinationConnectionType, hasDataInCorrectFormat)
select Processor_ID, SourceConnectionType, DestinationServer, DestinationDatabase, DestinationTableName, 3,                  'HQDAGSAS01',      'Tableau',           'TargetAOLVideoProd',  HelpTicketServer, HelpTicketServerDatabase, HelpTicketTableName, GetDate(),  DestinationConnectionType, hasDataInCorrectFormat
from [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings]
where   Processor_ID = (select ProcessorID from #i)
    and DestinationStageID = 2;



/* 4. Create destination table using SSMS.

    Get a create table statement.
    Execute on the remote database.

*/

/* 5. Duplicate 

/*
 [ClientDB_CPID72].[dbo].[PV85WeeklyTargetAOLVideoSummary] 

ClientDB_CPID72.vwPV78WeeklyDCMDDMT30DayRollingSummary
usp_IU_InsertProc2024ToRemoteDB

Stage 2 Post Stage 2 Insert to Remote DB
    Exec dbo.usp_IU_InsertToRemoteDB @ProcessorID = ?, @ControlID = ?
-- =====================================================================================================*/
  
