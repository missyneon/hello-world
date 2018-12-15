/*  If your TFS home directory is C:\TFS then this script is kept in:
    C:/TFS/Display/DatabaseDev/HQDMOSQL04/HQDMOSQL04_DatabaseDevelopement/HQDMOSQL04_DatabaseDevelopement/Scripts
    
    Run this in the database with the table to be changed.
*/
use ClientDB_CPID72_Staging

if object_id('tempdb..#i') is not null drop table #i;
go

    
select 
    ProcessorID = 2022,
    Stage1ID = 1,
    Stage2ID = 2,
    CompletedStatus = 'C',
    CMAID = 0,
    ActiveFlag = 0,
    Stage1DB = cast('' as varchar(2000)),
    Stage2DB = cast('' as varchar(2000)),
    Stage1DestinationMetaDataID = 0,
    Stage2DestinationMetaDataID = 0,
    Stage1FullTableName = cast('' as varchar(2000)),
    Stage2FullTableName = cast('' as varchar(2000)),
    Stage1DBTableName = cast('' as varchar(2000)),
    Stage2DBTableName = cast('' as varchar(2000)),
    Stage1TableName = cast('' as varchar(2000)),
    Stage2TableName = cast('' as varchar(2000))
into #i;

update #i
set Stage1TableName =	(
    Select 
      replace(DestinationTableName, '#', ProviderID)
    from
	(
        SELECT DestinationServer, DestinationDatabase, DestinationTableName
	    FROM [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] 
	    WHERE 	
		    Processor_ID = (select ProcessorID from #i) 
	    AND DestinationStageID = (select Stage1ID from #i)
    ) as T
    cross apply (
        select ClientParentID, ProviderID
        from [dbo].[ClientMetalAssignment]
        where ProcessorID = (select ProcessorID from #i)
          and DestinationStageID = 1
    ) as T1
);

update #i
set Stage2TableName =	(
    Select 
      replace(DestinationTableName, '#', ProviderID)
    from
	(
        SELECT DestinationServer, DestinationDatabase, DestinationTableName
	    FROM [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] 
	    WHERE 	
		    Processor_ID = (select ProcessorID from #i) 
	    AND DestinationStageID = (select Stage2ID from #i)
    ) as T
    cross apply (
        select ClientParentID, ProviderID
        from [dbo].[ClientMetalAssignment]
        where ProcessorID = (select ProcessorID from #i)
          and DestinationStageID = 1
    ) as T1
);

select Stage1TableName, Stage2TableName from #i;

update #i
set Stage1FullTableName =	(
    Select 
        '[' + DestinationServer + ']'
      + '.[' + replace(DestinationDatabase, '#', ClientParentID) + ']'
      + '.[dbo].' + replace(DestinationTableName, '#', ProviderID)
    from
	(
        SELECT DestinationServer, DestinationDatabase, DestinationTableName
	    FROM [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] 
	    WHERE 	
		    Processor_ID = (select ProcessorID from #i) 
	    AND DestinationStageID = (select Stage1ID from #i)
    ) as T
    cross apply (
        select ClientParentID, ProviderID
        from [dbo].[ClientMetalAssignment]
        where ProcessorID = (select ProcessorID from #i)
          and DestinationStageID = 1
    ) as T1
);

update #i
set Stage1DB =	(
    Select replace(DestinationDatabase, '#', ClientParentID)
    from
	(
        SELECT DestinationServer, DestinationDatabase, DestinationTableName
	    FROM [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] 
	    WHERE 	
		    Processor_ID = (select ProcessorID from #i) 
	    AND DestinationStageID = (select Stage1ID from #i)
    ) as T
    cross apply (
        select ClientParentID, ProviderID
        from [dbo].[ClientMetalAssignment]
        where ProcessorID = (select ProcessorID from #i)
          and DestinationStageID = 1
    ) as T1
);

update #i
set Stage2DB =	(
    Select replace(DestinationDatabase, '#', ClientParentID)
    from
	(
        SELECT DestinationServer, DestinationDatabase, DestinationTableName
	    FROM [HQIMPETL01].[ExstoAdmin].[dbo].[GenericETLConnectionStrings] 
	    WHERE 	
		    Processor_ID = (select ProcessorID from #i) 
	    AND DestinationStageID = (select Stage2ID from #i)
    ) as T
    cross apply (
        select ClientParentID, ProviderID
        from [dbo].[ClientMetalAssignment]
        where ProcessorID = (select ProcessorID from #i)
          and DestinationStageID = 1
    ) as T1
);

select Stage1DB, Stage2DB from #i;


update #i set 
Stage2FullTableName = replace(replace((select Stage1FullTableName from #i), '_Staging', ''), 'Staging', '');

select Stage1FullTableName, Stage2FullTableName from #i;

update #i set
    Stage1DBTableName = 
        (select right(Stage1FullTableName, len(Stage1FullTableName) - charindex('.', Stage1FullTableName)) from #i),
    Stage2DBTableName = 
        (select right(Stage2FullTableName, len(Stage2FullTableName) - charindex('.', Stage2FullTableName)) from #i)


select Stage1DBTableName, Stage2DBTableName from #i;

update #i set Stage1DestinationMetaDataID = (
    SELECT ID 
	FROM [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationMetaData]
	WHERE 
		DestinationProcessorID = (select ProcessorID from #i)
	AND DestinationStageID = (select Stage1ID from #i)
);

update #i set Stage2DestinationMetaDataID = isnull((
    SELECT ID 
	FROM [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationMetaData]
	WHERE 
		DestinationProcessorID = (select ProcessorID from #i)
	AND DestinationStageID = (select Stage2ID from #i)
), '');


select * from #i;






-- Part 2.

-- Update column definitions.
select * 
from  [HQIMPETL01].[ExstoAdmin].[DBO].[SourceColumnDefinition] 
where SourceMetaDataID in (select ID from [DBO].[sourcemetadata] where SourceProcessorID = (select ProcessorID from #i)) order by ColumnOrder

update [HQIMPETL01].[ExstoAdmin].[DBO].[SourceColumnDefinition] 
set ColumnWidth = case when ColumnName like '%URL%' then 4000 else 1000 end                   
where SourceMetaDataID in (select ID from [DBO].[sourcemetadata] where SourceProcessorID = (select ProcessorID from #i));


select [Cols 1] = 'Cols 1', * 
from [HQIMPETL01].[ExstoAdmin].[DBO].[destinationColumnDefinition] where destinationMetaDataID in (
    select ID 
    from [DBO].[destinationmetadata] 
    where destinationProcessorID = (select ProcessorID from #i) and DestinationStageID = 1) 
order by ColumnOrder;

select [Cols 2] = 'Cols 2', * 
from [HQIMPETL01].[ExstoAdmin].[DBO].[destinationColumnDefinition] where destinationMetaDataID in (
    select ID from [DBO].[destinationmetadata] where destinationProcessorID = (select ProcessorID from #i) and DestinationStageID = 2
) 
order by ColumnOrder;

update [HQIMPETL01].[ExstoAdmin].[DBO].[destinationColumnDefinition] 
set 
    ColumnDataType = case when ColumnName like '%URL%' then 'nvarchar(4000)' else 'nvarchar(1000)' end                   
where destinationMetaDataID in (
    select ID from [DBO].[destinationmetadata] where destinationProcessorID = (select ProcessorID from #i) 
)
and ColumnDataType like 'nvarchar%';




/*  DO NOT ALTER TABLES, IT WILL TAKE TO LONG. 
    CHOOSE DROP AND CREATE IN THE OBJECT EXPLORER.

select '[' + Column_Name + '], '
from INFORMATION_SCHEMA.COLUMNS
where Table_Name = (select Stage2TableName from #i)



select * 
drop table [ClientDB_CPID72].[dbo].PV80DailyTargetDBMSummary
from [ClientDB_CPID72].[dbo].PV80DailyTargetDBMSummary;



set identity_insert [ClientDB_CPID72].[dbo].PV80DailyTargetDBMSummary on;


insert into [ClientDB_CPID72].[dbo].PV80DailyTargetDBMSummary(
[rowid], 
[Date], 
[Advertiser], 
[ProviderAdvertiserID], 
[AdvertiserStatus], 
[AdvertiserIntegrationCode], 
[InsertionOrder], 
[InsertionOrderID], 
[InsertionOrderStatus], 
[InsertionOrderIntegrationCode], 
[LineItem], 
[LineItemID], 
[LineItemStatus], 
[LineItemIntegrationCode], 
[TargetedDataProviders], 
[Creative], 
[CreativeID], 
[DCMPlacementID], 
[CreativeStatus], 
[CreativeSource], 
[CreativeIntegrationCode], 
[LineItemType], 
[AppURL], 
[AppURLID], 
[AppURLExcluded], 
[CreativeWidth], 
[CreativeHeight], 
[CreativeType], 
[AdPosition], 
[Exchange], 
[ExchangeID], 
[DMACode], 
[DMAName], 
[Browser], 
[OperatingSystem], 
[ISPOrCarrier], 
[Environment], 
[PublicInventory], 
[InventorySource], 
[InventorySourceID], 
[InventorySourceType], 
[VideoPlayerSize], 
[MaxVideoDurationSeconds], 
[MobileMake], 
[MobileMakeAndModel], 
[DeviceType], 
[AdvertiserCurrency], 
[Impressions], 
[BillableImpressions], 
[ActiveViewEligibleImpressions], 
[ActiveViewMeasurableImpressions], 
[ActiveViewViewableImpressions], 
[Clicks], 
[TotalConversions], 
[PostClickConversions], 
[PostViewConversions], 
[RevenueAdvCurrency], 
[MediaCostAdvertiserCurrency], 
[TotalMediaCostAdvertiserCurrency], 
[ProfitAdvertiserCurrency], 
[DCMPostClickRevenue], 
[DCMPostViewRevenue], 
[StartsVideo], 
[FirstQuartileViewsVideo], 
[MidpointViewsVideo], 
[ThirdQuartileViewsVideo], 
[CompleteViewsVideo], 
[AudioMutesVideo], 
[PausesVideo], 
[FullscreensVideo], 
[SkipsVideo], 
[CompanionImpressionsVideo], 
[CompanionClicksVideo], 
[AdvertiserID], 
[ControlID], 
[LoadDateTime]
)
select 
[rowid], 
[Date], 
[Advertiser], 
[ProviderAdvertiserID], 
[AdvertiserStatus], 
[AdvertiserIntegrationCode], 
[InsertionOrder], 
[InsertionOrderID], 
[InsertionOrderStatus], 
[InsertionOrderIntegrationCode], 
[LineItem], 
[LineItemID], 
[LineItemStatus], 
[LineItemIntegrationCode], 
[TargetedDataProviders], 
[Creative], 
[CreativeID], 
[DCMPlacementID], 
[CreativeStatus], 
[CreativeSource], 
[CreativeIntegrationCode], 
[LineItemType], 
[AppURL], 
[AppURLID], 
[AppURLExcluded], 
[CreativeWidth], 
[CreativeHeight], 
[CreativeType], 
[AdPosition], 
[Exchange], 
[ExchangeID], 
[DMACode], 
[DMAName], 
[Browser], 
[OperatingSystem], 
[ISPOrCarrier], 
[Environment], 
[PublicInventory], 
[InventorySource], 
[InventorySourceID], 
[InventorySourceType], 
[VideoPlayerSize], 
[MaxVideoDurationSeconds], 
[MobileMake], 
[MobileMakeAndModel], 
[DeviceType], 
[AdvertiserCurrency], 
[Impressions], 
[BillableImpressions], 
[ActiveViewEligibleImpressions], 
[ActiveViewMeasurableImpressions], 
[ActiveViewViewableImpressions], 
[Clicks], 
[TotalConversions], 
[PostClickConversions], 
[PostViewConversions], 
[RevenueAdvCurrency], 
[MediaCostAdvertiserCurrency], 
[TotalMediaCostAdvertiserCurrency], 
[ProfitAdvertiserCurrency], 
[DCMPostClickRevenue], 
[DCMPostViewRevenue], 
[StartsVideo], 
[FirstQuartileViewsVideo], 
[MidpointViewsVideo], 
[ThirdQuartileViewsVideo], 
[CompleteViewsVideo], 
[AudioMutesVideo], 
[PausesVideo], 
[FullscreensVideo], 
[SkipsVideo], 
[CompanionImpressionsVideo], 
[CompanionClicksVideo], 
[AdvertiserID], 
[ControlID], 
[LoadDateTime]
from [ClientDB_CPID72].[dbo].PV80DailyTargetDBMSummary_temp;

set identity_insert [ClientDB_CPID72].[dbo].PV80DailyTargetDBMSummary off;
