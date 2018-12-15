Use ExstoAdmin;

/*  
ChangeProcessorCadence.

Change the processor cadence.
    
REVIEW CAREFULLY BEFORE CHANGING.

*/
if object_id('tempdb..#i') is not null drop table #i;
go

    
select 
    ProcessorID = 2022,
    Stage1ID = 1,
    Stage2ID = 2,
    CompletedStatus = 'C',
    CMAID = 0,
    ActiveFlag = 1,

    OldCadence = cast('Weekly' as varchar(20)),
    NewCadence = cast('Daily' as varchar(20)),


    Stage1DestinationMetaDataID = 0,
    Stage2DestinationMetaDataID = 0,
    Stage2ConnectionStringID = 0,
    Stage1FullTableName = cast('' as varchar(2000)),
    Stage2FullTableName = cast('' as varchar(2000))
into #i;


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


select GenericETLConnectionStrings = 'GenericETLConnectionStrings', SourceTableName, DestinationTableName, * from [DBO].[GenericETLConnectionStrings] where Processor_ID = (select ProcessorID from #i) order by DestinationStageID

select DestinationMetadata = 'DestinationMetadata', DestinationName, * from [DBO].[destinationmetadata] where destinationProcessorID = (select ProcessorID from #i) order by DestinationStageID

select CMA = 'CMA', DestinationName, * from [DBO].[ClientMetalAssignment] 
where ProcessorID = (select ProcessorID from #i)
order by DestinationStageID

select CMS = 'CMS', * from [DBO].[ClientMetalSchedule] where cmaid in (select cmaid from [DBO].[ClientMetalAssignment] where ProcessorID = (select ProcessorID from #i))

select [Download Control] = 'Download Control', status, /* Control_ID, Processor_ID, Engine */ * 
from [hqdmosql03].[exstodisplay].[dbo].[aDownload_Control] 
where processor_ID = (select ProcessorID from #i)
order by Stamp_Created desc;

select [Process Control] = 'Process Control', ProcessControlID, FinalTableName, FileControlID, status, * from [hqdmosql03].[exstodisplay].[dbo].[aprocess_Control] where processorID = (select ProcessorID from #i)


-- Part 2
if 1 = 2
begin
    update [DBO].[GenericETLConnectionStrings] 
    set 
        SourceTableName = replace(SourceTableName, (Select OldCadence from #i), (Select NewCadence from #i)),
        DestinationTableName = replace(DestinationTableName, (Select OldCadence from #i), (Select NewCadence from #i))
    where Processor_ID = (select ProcessorID from #i);


    update [DBO].[destinationmetadata] 
    set 
        DestinationName = replace(DestinationName, (Select OldCadence from #i), (Select NewCadence from #i))
    where DestinationProcessorID = (select ProcessorID from #i);


    update [DBO].[ClientMetalAssignment] 
    set 
        DestinationName = replace(DestinationName, (Select OldCadence from #i), (Select NewCadence from #i))
    where ProcessorID = (select ProcessorID from #i);


    update [hqdmosql03].[exstodisplay].[dbo].[aprocess_Control] 
    set 
        FinalTableName = replace(FinalTableName, (Select OldCadence from #i), (Select NewCadence from #i))
    where ProcessorID = (select ProcessorID from #i);

end;
