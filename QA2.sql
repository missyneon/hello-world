Use ExstoAdmin;

/*  Andrew Bloss 11/5/2016.

    This script is in:
    $/Display/DatabaseDev/HQDMOSQL04/HQDMOSQL04_DatabaseDevelopement/HQDMOSQL04_DatabaseDevelopement/Scripts
    
    This script QAs Stage 2 of metal.

   
*/
if object_id('tempdb..#i') is not null drop table #i;
go

    
select 
    ProcessorID = 2030,
    ClientParentName = 'Comcast',
    ClientParentID = cast(null as int),
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

update #i
set Stage1FullTableName =	(
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

update #i set 
Stage2FullTableName = replace(replace((select Stage1FullTableName from #i), '_Staging', ''), 'Staging', '');

select Stage1FullTableName from #i;

select Stage2FullTableName from #i;

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


select * from #i;

-- View stage 2 column definitions.
select  * from [DBO].[destinationColumnDefinition] where destinationMetaDataID in (
    select ID from [DBO].[destinationmetadata] where destinationProcessorID = (select ProcessorID from #i) and DestinationStageID = 2
) 
order by ColumnOrder;

-- View data in stage 2 .
declare @Sql varchar(max) = '';

set @Sql = 'select * from ' + (select Stage2FullTableName from #i);

select @Sql;


/*  
    Copy and paste the sums into an Excel spreadsheet with the sums of the columns.
    Compare the Excel and database sums.
   
    QA by summing the columns in stage 2.
    Run the Stage 2 SSIS package first.

*/
declare @QA varchar(MAX);

set @QA =
'select ' + 
stuff((select ', ' + ColumnName + ' = sum(try_cast(' + ColumnName + ' as numeric(38,9)))'
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
        where DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i)
          and Coalesce(RemoveColInDestTable, 0) <> 1
        order by ColumnOrder
        for xml path('')),1,1,''
) + ', [Count] = count(*)' + 
' from ' + (select Stage2FullTableName from #i) + ' where controlid = 3464125'


select [Stage 2 QA] = @QA;

Exec(@QA);

