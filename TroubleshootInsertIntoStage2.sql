Use ExstoAdmin;

/*  If your TFS home directory is C:\TFS then this script is kept in:
    C:/TFS/Display/DatabaseDev/HQDMOSQL04/HQDMOSQL04_DatabaseDevelopement/HQDMOSQL04_DatabaseDevelopement/Scripts
    
    A not on casting.
    =================
    4.4 casts to int
       select try_cast(4.4 as int) 
       > 4

    '4' casts to int
       select try_cast('4' as int)
       > 4

    But '4.4' does not
       select try_cast('4.4' as int)
       > NULL

    So cast '4.4' to decimal and then int.
       select try_cast(try_cast('4.4' as decimal(18,6)) as int)
       > 4
       
*/
if object_id('tempdb..#i') is not null drop table #i;
go

    
select 
    ProcessorID = 2055,
    ControlID = 3461737,
    ClientParentName = 'Target',
    ClientParentID = 0,

    Stage1ID = 1,
    Stage2ID = 2,

    CompletedStatus = 'C',
    CMAID = 0,
    ActiveFlag = 0,
    Stage1DestinationMetaDataID = 0,
    Stage2DestinationMetaDataID = 0,
    
    Stage2ConnectionStringID = 0,
    Stage1FullTableName = cast('' as varchar(2000)),
    Stage2FullTableName = cast('' as varchar(2000))
into #i;

update #i set ClientParentID = ( 
        select ClientParentID 
        from [HQDMOSQL02].[ExstoDisplay].[dbo].[clientparent] 
        where (select ClientParentName from #i) is not null 
          and clientParentName like '%' + (select ClientParentName from #i) + '%'
);

select ClientParentID, ClientParentName from #i;

update #i set Stage1FullTableName =	(
    Select 
        '[' + DestinationServer + ']'
      + '.[' + replace(DestinationDatabase, '#', ClientParentID) + ']'
      + '.[dbo].' + replace(DestinationTableName, '#', ProviderID) 
    from
	(
        SELECT DestinationServer, DestinationDatabase, DestinationTableName
	    FROM [dbo].[GenericETLConnectionStrings] 
	    WHERE 	
		    Processor_ID = (select ProcessorID from #i) 
	    AND DestinationStageID = (select Stage1ID from #i)
    ) as T
    cross apply (
        select ClientParentID, ProviderID
        from [dbo].[ClientMetalAssignment]
        where ProcessorID = (select ProcessorID from #i)
          and ClientParentID = (select ClientParentID from #i)
          and DestinationStageID = 1
    ) as T1
);

update #i set Stage2FullTableName = replace(replace((select Stage1FullTableName from #i), '_Staging', ''), 'Staging', '');

select Stage1FullTableName, Stage2FullTableName from #i;


update #i set Stage1DestinationMetaDataID = (
    SELECT ID 
	FROM [dbo].[DestinationMetaData]
	WHERE 
		DestinationProcessorID = (select ProcessorID from #i)
	AND DestinationStageID = (select Stage1ID from #i)
);

update #i set Stage2DestinationMetaDataID = (
    SELECT ID 
	FROM [dbo].[DestinationMetaData]
	WHERE 
		DestinationProcessorID = (select ProcessorID from #i)
	AND DestinationStageID = (select Stage2ID from #i)
);


/*

select *
from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]  
where DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i) 
order by ColumnOrder;

*/

update #i
set Stage2ConnectionStringID =	(
	SELECT ConnectionStringID
	FROM [dbo].[GenericETLConnectionStrings] 
	WHERE 	
		Processor_ID = (select ProcessorID from #i) 
	AND DestinationStageID = (select Stage2ID from #i)
);

update #i set Stage2DestinationMetaDataID = (
    select ID
	FROM [ExstoAdmin].[dbo].[DestinationMetaData]
	WHERE 
		DestinationProcessorID = (select ProcessorID from #i)
	AND DestinationStageID = (select Stage2ID from #i)
);

/*

       select 'drop table ' + (select Stage1FullTableName from #i) + 'hdrck'
union select 'drop table ' + (select Stage1FullTableName from #i)
union select 'drop table ' + (select Stage2FullTableName from #i)

drop table [ClientDB_CPID69].[dbo].PV4DailyDCMDTCFloodlightSummary
drop table [ClientDB_CPID69_Staging].[dbo].PV4DailyDCMDTCFloodlightSummaryStaging
drop table [ClientDB_CPID69_Staging].[dbo].PV4DailyDCMDTCFloodlightSummaryStaginghdrck
*/


/*
select * from HQDMOSQL03.ExstoDisplay.dbo.adownload_Control 
where Processor_ID = (select ProcessorID from #i);

delete HQDMOSQL03.ExstoDisplay.dbo.aProcess_Control where FileControlID = (select ControlID from #i)

*/

						
/*
select * from HQIMPETL01.ExstoAdmin.dbo.DestinationMetaData where DestinationProcessorID = (select ProcessorID from #i)
select * from [HQIMPDW01].[Exsto].[dbo].[aDownload_Processors] where Processor_ID = (select ProcessorID from #i)

*/


/* QA Stage 1 by summing the columns in Stage 1.
*/
declare 
    @QA varchar(MAX),
    @ColumnDataType varchar(20) = 'BIGINT';

set @QA =
'select top 100 ' + 
stuff((select ', ' + s1.ColumnName 
       from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] s1
       join [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] s2
         on s1.ColumnOrder = s2.ColumnOrder
       where 
            s1.DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i)
        and s2.DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i)
        and s2.ColumnDataType = @ColumnDataType
       order by s1.ColumnOrder
       for xml path('')),1,1,''
) + 
' from ' + (select Stage1FullTableName from #i) + 
' where ' + 
stuff(
    (  select 'or (' + s1.ColumnName + ' is not null and try_cast(' + s1.ColumnName + ' as ' + @ColumnDataType + ') is null)' + char(10)
       from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] s1
       join [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] s2
         on s1.ColumnOrder = s2.ColumnOrder
        and s1.DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i)
        and s2.DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i)
       where 
            s2.ColumnDataType = @ColumnDataType
       order by s1.ColumnOrder
       for xml path, TYPE).value('.[1]', 'nvarchar(max)'),
    1,
    3,
    ''
);

select [QA] = @QA;

Exec(@QA);

/*  Copy and paste the sums into an Excel spreadsheet with the sums of the columns.
    Compare the Excel and database sums.
 
 select try_cast('hi' as bigint);

select  [CampaignID], [CreativeID], [AdImpressions], [Clicks], [TotalClicks], [25PctCompletedViews], [50PctCompletedViews], [75PctCompletedViews], [100PctCompletedViews], [CompanionAdImpressions], [CompanionAdClicks], [ProgressViews], [AdAttempts], [AdErrors], [AdSkips], [AdsPaused], [AdsResumed], [Conversions], [ViewConversions], [ClickConversions], [IABNonViewableAdImpressions], [IABViewabilityMeasurableAdImpressions], [IABViewabilityUndeterminedAdImpressions], [IABViewableAdImpressions], [ControlID] from [HQDMOSQL04].[ClientDB_CPID72].[dbo].PV85WeeklyTargetAOLVideoSummary where ([CampaignID] is not null and try_cast([CampaignID] as BIGINT) is null) or ([CreativeID] is not null and try_cast([CreativeID] as BIGINT) is null) or ([AdImpressions] is not null and try_cast([AdImpressions] as BIGINT) is null) or ([Clicks] is not null and try_cast([Clicks] as BIGINT) is null) or ([TotalClicks] is not null and try_cast([TotalClicks] as BIGINT) is null) or ([25PctCompletedViews] is not null and try_cast([25PctCompletedViews] as BIGINT) is null) or ([50PctCompletedViews] is not null and try_cast([50PctCompletedViews] as BIGINT) is null) or ([75PctCompletedViews] is not null and try_cast([75PctCompletedViews] as BIGINT) is null) or ([100PctCompletedViews] is not null and try_cast([100PctCompletedViews] as BIGINT) is null) or ([CompanionAdImpressions] is not null and try_cast([CompanionAdImpressions] as BIGINT) is null) or ([CompanionAdClicks] is not null and try_cast([CompanionAdClicks] as BIGINT) is null) or ([ProgressViews] is not null and try_cast([ProgressViews] as BIGINT) is null) or ([AdAttempts] is not null and try_cast([AdAttempts] as BIGINT) is null) or ([AdErrors] is not null and try_cast([AdErrors] as BIGINT) is null) or ([AdSkips] is not null and try_cast([AdSkips] as BIGINT) is null) or ([AdsPaused] is not null and try_cast([AdsPaused] as BIGINT) is null) or ([AdsResumed] is not null and try_cast([AdsResumed] as BIGINT) is null) or ([Conversions] is not null and try_cast([Conversions] as BIGINT) is null) or ([ViewConversions] is not null and try_cast([ViewConversions] as BIGINT) is null) or ([ClickConversions] is not null and try_cast([ClickConversions] as BIGINT) is null) or ([IABNonViewableAdImpressions] is not null and try_cast([IABNonViewableAdImpressions] as BIGINT) is null) or ([IABViewabilityMeasurableAdImpressions] is not null and try_cast([IABViewabilityMeasurableAdImpressions] as BIGINT) is null) or ([IABViewabilityUndeterminedAdImpressions] is not null and try_cast([IABViewabilityUndeterminedAdImpressions] as BIGINT) is null) or ([IABViewableAdImpressions] is not null and try_cast([IABViewableAdImpressions] as BIGINT) is null) or ([ControlID] is not null and try_cast([ControlID] as BIGINT) is null) */ 


