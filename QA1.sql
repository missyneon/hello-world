Use ExstoAdmin;

/*  If your TFS home directory is C:\TFS then this script is kept in:
    C:/TFS/Display/DatabaseDev/HQDMOSQL04/HQDMOSQL04_DatabaseDevelopement/HQDMOSQL04_DatabaseDevelopement/Scripts
    
    This script sets up Stage 2 of the Stage 2 Metal SSIS package.
    
    Run the STAGE 1 Metal SSIS package.

    Run this script on HQIMPETL01 ExstoAdmin. 
    
    It takes a few minutes.

    THIS SCRIPT ERRORS IF THE STAGE 1 TABLE DO NOT EXIST.

    THIS SCRIPT RETURNS NULLS IF THERE IS NO DATA IN THE STAGE 1 TABLE.

    After running this script you can drop the stage 2 table and run then the stage 2 metal package to
    recreate the stage 2 table with the new column definitions.

Quality Assurance
=================
    If QA is 1 then last line in the results window sums every column in the stage 1 table.
    Copy it and into an excel spreadsheet based on the csv input file.
    Compare the file sums with the database sums. 


    Improvements
    ------------
    Take nvarchar or varchar from stage 1.
       
*/
if object_id('tempdb..#i') is not null drop table #i;
go

    
select 
    ProcessorID = 2064,

    -- THE CONTROLID FROM STAGE 1 TESTING.
    ControlID = 3463216,

    ClientParentName = 'HBO',
    ClientParentID = 0,

    QA = 1,

    Stage1ID = 1,
    Stage2ID = 2,

    CompletedStatus = 'C',
    CMAID = 0,
    ActiveFlag = 0,
    Stage1DestinationMetaDataID = cast(null as int),
    Stage2DestinationMetaDataID = cast(null as int),
    
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
        SELECT DestinationServer, DestinationDatabase, DestinationTableName, DestinationStageID
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


if not exists(
    select *
    FROM [dbo].[ClientMetalAssignment] 
    where processorID = (select ProcessorID from #i) 
      and DestinationStageID = (select Stage2ID from #i)
)
begin
    INSERT INTO [dbo].[ClientMetalAssignment](
          ProcessorID
        , DestinationStageID
        , DestinationName
        , ClientParentID
        , ClientParentName

        , AdvertiserID
        , ProviderID
        , ActiveFlag
    )
    SELECT 
          ProcessorID
        , DestinationStageID = (select Stage2ID from #i)
        , DestinationName = Replace(Replace(DestinationName, '_', ''), 'Staging', '')
        , ClientParentID
        , ClientParentName

        , AdvertiserID
        , ProviderID
        , ActiveFlag = (select ActiveFlag from #i)
    FROM [dbo].[ClientMetalAssignment] 
    where processorID = (select ProcessorID from #i) 
      and DestinationStageID = (select Stage1ID from #i);

    update #i set CMAID = (
        select CMAID
        FROM [dbo].[ClientMetalAssignment] 
        where processorID = (select ProcessorID from #i) 
          and DestinationStageID = (select Stage2ID from #i)
    );

    insert into [dbo].[ClientMetalSchedule] (
          CMAID

        , SundayRunTime
        , MondayRuntime
        , TuesdayRuntime
        , WednesdayRuntime
        , ThursdayRuntime
        , FridayRuntime
        , SaturdayRuntime

        , PrioritySeq
        , BatchID
        , ActiveFlag
    )
    select 
          (select CMAID from #i)

        , SundayRunTime
        , MondayRuntime
        , TuesdayRuntime
        , WednesdayRuntime
        , ThursdayRuntime
        , FridayRuntime
        , SaturdayRuntime

        , PrioritySeq
        , BatchID
        , ActiveFlag = 0
    from [dbo].[ClientMetalSchedule] 
    where CMAID = (
        select CMAID
        FROM [dbo].[ClientMetalAssignment] 
        where processorID = (select ProcessorID from #i) 
          and DestinationStageID = (select Stage1ID from #i)
    );
end;


if not exists(
    select *
    FROM [dbo].[GenericETLConnectionStrings] GECS
    WHERE
		GECS.Processor_ID = (select ProcessorID from #i)
    AND GECS.DestinationStageID = (select Stage2ID from #i)
)
begin

    INSERT INTO	[dbo].[GenericETLConnectionStrings]
    (
	     Processor_ID
	    ,SourceConnectionType
	    ,SourceServer
	    ,SourceDatabase
	    ,SourceTableName

	    ,DestinationStageID
	    ,DestinationServer
	    ,DestinationDatabase
	    ,DestinationTableName
	    ,HelpTicketServer

	    ,HelpTicketServerDatabase
	    ,HelpTicketTableName
	    ,InsertDate
	    ,DestinationConnectionType
	    ,hasDataInCorrectFormat

    )
    SELECT
	     Processor_ID
	    ,SourceConnectionType
	    ,SourceServer
	    ,SourceDatabase
	    ,LTRIM(RTRIM(REPLACE(SourceTableName,'hdrck','')))

	    ,(select Stage2ID from #i)
	    ,DestinationServer
	    ,LTRIM(RTRIM(REPLACE(DestinationDatabase,'_Staging','')))
	    ,LTRIM(RTRIM(REPLACE(DestinationTableName,'Staging','')))
	    ,HelpTicketServer

	    ,HelpTicketServerDatabase
	    ,HelpTicketTableName
	    ,GetDate()
	    ,DestinationConnectionType
	    ,hasDataInCorrectFormat
    FROM [dbo].[GenericETLConnectionStrings] GECS
    WHERE
		GECS.Processor_ID = (select ProcessorID from #i)
	AND GECS.DestinationStageID = (select Stage1ID from #i);		
end;

update #i
set Stage2ConnectionStringID =	(
	SELECT ConnectionStringID
	FROM [dbo].[GenericETLConnectionStrings] 
	WHERE 	
		Processor_ID = (select ProcessorID from #i) 
	AND DestinationStageID = (select Stage2ID from #i)
);


if not exists(
    select *
    FROM [dbo].[DestinationMetaData]
    WHERE
	    DestinationProcessorID = (select ProcessorID from #i)
    AND DestinationStageID = (select Stage2ID from #i)
)
begin

    INSERT INTO [dbo].[DestinationMetaData]
    (
	     DestinationStageID
	    ,DestinationName
	    ,DestinationHeaderID
	    ,DestinationProcessorID
	    ,ColumnDelimiter

	    ,RowDelimiter
	    ,ConnectionStringID
	    ,ActiveFlag
	    ,CreateDate
	    ,GenericStaging

	    ,ProviderID
	    ,RefreshData
	    ,RefreshRateInDays
	    ,SpecialCodeID
        ,DestinationType
    )
    SELECT
	     (select Stage2ID from #i)
	    ,LTRIM(RTRIM(REPLACE(DestinationName,'Staging','')))
	    ,DestinationHeaderID
	    ,DestinationProcessorID
	    ,ColumnDelimiter

	    ,RowDelimiter
	    ,(select Stage2ConnectionStringID from #i)
	    ,ActiveFlag = 1
	    ,CreatedDate = GetDate()
	    ,GenericStaging

	    ,ProviderID
	    ,RefreshData
	    ,RefreshRateInDays
	    ,SpecialCodeID
        ,'TABLE'
    FROM [dbo].[DestinationMetaData]
    WHERE
	    DestinationProcessorID = (select ProcessorID from #i)
    AND DestinationStageID = (select Stage1ID from #i);
end;

update #i set Stage2DestinationMetaDataID = (
    select ID
	FROM [ExstoAdmin].[dbo].[DestinationMetaData]
	WHERE 
		DestinationProcessorID = (select ProcessorID from #i)
	AND DestinationStageID = (select Stage2ID from #i)
);


select * from #i;

declare 
    @DataTypesSQL varchar(max) = '',
    @ColsSQL varchar(max) = '',
    @InsertIntoDestinationColumnDefinition varchar(max) = '';

/*  Try to cast each value in the stage 1 table to the most restrictive datatype. 
    If the cast is succesful return a code and max the results.

    0 for null or '' 
    100 for datetime values
    200 for bigint values
    300 for numeric(18,6) values
    1000+ for character values

*/
set @DataTypesSQL =
'select ' + 
stuff((select 
        ',' + ColumnName + 
        ' = max(' + char(10) +
            ' case' + char(10) +
                ' when ' + ColumnName + ' is null' + 
                    ' or [dbo].fnRemoveSpecialCharsAWB(' + ColumnName + ') = ''''' +
                    ' then 0' +
                ' when try_cast (' + ColumnName + ' as datetime) is not null then 100' + char(10) +
                ' when isnumeric (cast([dbo].fnRemoveSpecialCharsAWB(' + ColumnName + ') as varchar(38)) + ''.e0'') = 1' + char(10) +
                    ' and try_cast([dbo].fnRemoveSpecialCharsAWB(' + ColumnName + ') as bigint) is not null then 200' + char(10) +
                ' when try_cast ([dbo].fnRemoveSpecialCharsAWB(' + ColumnName + ') as numeric(18,6)) is not null then 300' + char(10) +
                ' else 1000 + len(' + ColumnName + ')' + char(10) +
            ' end' + char(10) +
        ')' + char(10) 
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
        where DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i)
        order by ColumnOrder
        for xml path('')),1,1,'') + 
' from (select top 1000 * from ' + (select Stage1FullTableName from #i) + ') T';

select DataTypesSQL = @DataTypesSQL;

exec(@DataTypesSQL);

/*  Get all the column names in stage 1.
*/
set @ColsSQL = 
    stuff((select 
        ',' + ColumnName 
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
        where DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i)
        order by ColumnOrder
        for xml path('')),1,1,'');

select ColsSQL = @ColsSQL;

/*  Insert Stage 2 column definitions.
*/


delete [dbo].[DestinationColumnDefinition] 
where DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i);

-- Insert stage 2 column definitions with standardized names. Rename their AdvertiserID if it exists.
set @InsertIntoDestinationColumnDefinition =  
'INSERT INTO [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
(
	  ColumnOrder
	, ColumnName
	, DestinationMetaDataID
	, ColumnDataType
	, DestinationStageID
)
select 
	  ColumnOrder = row_number() over(order by (select 1))
    , ColumnName = case when dbo.udf_ColumnNameReplaceAWB(ColumnName) = ''[AdvertiserID]'' then ''[ProviderAdvertiserID]'' else dbo.udf_ColumnNameReplaceAWB(ColumnName) end
    , DestinationMetaDataID = ' + (select cast(Stage2DestinationMetaDataID as varchar(20)) from #i) + '
    , DataType = Cast(DataTypeCode as varchar(20))
    , DestinationStageID = ' + (select cast(Stage2ID as varchar(20)) from #i) + '
from (' + @DataTypesSQL + ') T 
unpivot
(
    DataTypeCode     
    for ColumnName in (' + @ColsSQL + ')
) u';

select InsertIntoDestinationColumnDefinition = @InsertIntoDestinationColumnDefinition;

exec(@InsertIntoDestinationColumnDefinition);

/*  
Update stage 2 ColumnDataType and SpecialTransformCode.
ColumnDataType = 0 for empty columns. 

Use the data type in stage 1 in stage 2 if the column name suggests a string 
or the column has a non default data type
else numeric(18,6).
*/
update T set
    ColumnDataType = 
    case
        when T.ColumnDataType = '0' then
            case
                when   S.ColumnName like '%URL%' 
                    or S.ColumnName like '%Name' 
                    or S.ColumnDataType not like 'nvarchar%' 
                    then S.ColumnDataType
                else 'numeric(18,6)'
            end
        when T.ColumnDataType = '100' then 'datetime'             
        when T.ColumnDataType = '200' then 'bigint'
        when T.ColumnDataType = '300' then 'numeric(18,6)'
        else 'nvarchar(3000)' -- wip fix for data over 1000.
        --else 'nvarchar(' + cast( floor((2 * (cast(T.ColumnDataType as integer) - 1000) + 100) / 100) * 100 as varchar(20)) + ')'
    end                  
from (
    select * 
    from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
    where DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i) 
) as T
join (
    select * 
    from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
    where DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i) 
) as S on T.ColumnOrder = S.ColumnOrder;
/*
 Add ActiveFlag and UpdateDateTime columns to feeds that are updated.
 An example of an updating feed is a feed that includes data for several days but is sent daily.
 If the old data is not deleted then it accumulates multiples of each days data.
 */
if 1 = (
    select RefreshData 
    from [HQIMPETL01].[ExstoAdmin].dbo.DestinationMetaData 
    where DestinationProcessorID = (select ProcessorID from #i)
        and DestinationStageID = 1
)
begin
    
    -- Add ActiveFlag.
    if not exists(
        select *
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
        where destinationMetaDataID in (
            select ID 
            from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
            where destinationProcessorID = (select ProcessorID from #i) 
                and DestinationStageID = 2
        ) 
        and ColumnName = '[ActiveFlag]'
    )
    begin
        insert into [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition](
            DestinationMetaDataID, 
            ColumnName,     
            ColumnDataType, 
            ColumnOrder,         
            ActiveFlag, 

            CreateDate, 
            UpdateDate, 
            DestinationStageID, 
            SpecialTransformCode
        )
        select top 1 
            DestinationMetaDataID, 
            '[ActiveFlag]', 
            'BIT',    
            (      
                select max(ColumnOrder) + 1
                from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationColumnDefinition] 
                where destinationMetaDataID in (
                    select ID 
                    from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
                    where destinationProcessorID = (select ProcessorID from #i) 
                        and DestinationStageID = 2
                )
            ),
            1,    
                      
            GetDate(),  
            GetDate(),  
            DestinationStageID, 
            1
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
        where destinationMetaDataID in (
            select ID 
            from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
            where destinationProcessorID = (select ProcessorID from #i) 
                and DestinationStageID = 2
        );
    end;

    -- Add UpdateDateTime.
    if not exists(
        select *
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
        where destinationMetaDataID in (
            select ID 
            from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
            where destinationProcessorID = (select ProcessorID from #i) 
                and DestinationStageID = 2
        ) 
        and ColumnName = '[UpdateDateTime]'
    )
    begin
        insert into [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition](
            DestinationMetaDataID, 
            ColumnName,     
            ColumnDataType, 
            ColumnOrder,         
            ActiveFlag, 

            CreateDate, 
            UpdateDate, 
            DestinationStageID 
        )
        select top 1 
            DestinationMetaDataID, 
            '[UpdateDateTime]', 
            'DATETIME',    
            (      
                select max(ColumnOrder) + 1
                from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationColumnDefinition] 
                where destinationMetaDataID in (
                    select ID 
                    from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
                    where destinationProcessorID = (select ProcessorID from #i) 
                        and DestinationStageID = 2
                )
            ),
            1,   
                       
            GetDate(),  
            GetDate(),  
            DestinationStageID
        from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
        where destinationMetaDataID in (
            select ID 
            from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
            where destinationProcessorID = (select ProcessorID from #i) 
                and DestinationStageID = 2
        );
    end;

end;

-- Add AdvertiserID.
if not exists(
    select *
    from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
    where destinationMetaDataID in (
        select ID 
        from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
        where destinationProcessorID = (select ProcessorID from #i) 
            and DestinationStageID = 2
    ) 
    and ColumnName = '[AdvertiserID]'
)
begin
    insert into [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition](
        DestinationMetaDataID, 
        ColumnName,     
        ColumnDataType, 
        ColumnOrder,         
        ActiveFlag, 

        CreateDate, 
        UpdateDate, 
        DestinationStageID 
    )
    select top 1 
        DestinationMetaDataID, 
        '[AdvertiserID]', 
        'BIGINT',    
        (      
            select max(ColumnOrder) + 1
            from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationColumnDefinition] 
            where destinationMetaDataID in (
                select ID 
                from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
                where destinationProcessorID = (select ProcessorID from #i) 
                    and DestinationStageID = 2
            )
        ),
        1,   
                       
        GetDate(),  
        GetDate(),  
        DestinationStageID
    from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] 
    where destinationMetaDataID in (
        select ID 
        from  [HQIMPETL01].[ExstoAdmin].[dbo].[destinationmetadata] 
        where destinationProcessorID = (select ProcessorID from #i) 
            and DestinationStageID = 2
    );
end;

select *
from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]  
where DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i) 
order by ColumnOrder;

delete [dbo].[SourceToDestinationMap] 
where DestinationMetaID = (select Stage2DestinationMetaDataID from #i);

INSERT INTO [dbo].[SourceToDestinationMap]
(
	 SourceMetaID
	,SourceColumnID
	,DestinationMetaID
	,DestinationColumnID
	,TransformationCode

	,DestinationStageID
	,SpecialCode
	,ProcessorID
	,ColumnNo
)                                   
SELECT                                                             
	 SourceMetaID = cdc.DestinationMetaDataID
	,SourceColumnID = cdc.ID
	,DestinationMetaID = dcd.DestinationMetaDataID
	,DestinationColumnID = dcd.ID
	,TransformationCode = NULL -- This column is not currently used. Do not set it to dcd.SpecialTransformCode.

	,DestinationStageID = (select Stage2ID from #i)
	,SpecialCode = 'DTN'
	,ProcessorID = (select ProcessorID from #i)
	,ColumnNo = cdc.ColumnOrder  
--    ,cdc.ColumnName
--    ,dcd.ColumnName                                                       
FROM  [dbo].[DestinationColumnDefinition] cdc                                                            
JOIN [dbo].[DestinationColumnDefinition] dcd 
    ON dbo.udf_ColumnNameReplaceAWB(cdc.[ColumnName]) = dcd.ColumnName                              
WHERE 
    cdc.DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i)
AND dcd.DestinationMetaDataID = (select Stage2DestinationMetaDataID from #i)
ORDER BY 
    cdc.ColumnOrder;                                                      

/*
select * from HQDMOSQL03.ExstoDisplay.dbo.adownload_Control where Processor_ID = (select ProcessorID from #i) and Control_ID = (select ControlID from #i);
select * from HQDMOSQL03.ExstoDisplay.dbo.aProcess_Control where ProcessorID = (select ProcessorID from #i) and FileControlID = (select ControlID from #i);
*/


delete HQDMOSQL03.ExstoDisplay.dbo.aProcess_Control 
where FileControlID = (select ControlID from #i)
and ProcessorID = (select ProcessorID from #i)

INSERT INTO HQDMOSQL03.ExstoDisplay.dbo.aProcess_Control(
     ProcessorID
    ,ClientID
    ,AdvertiserID
    ,SiteID
    ,SqlServerJobName

    ,StagingServer
    ,StagingDatabase
    ,FinalServer
    ,FinalDatabase
    ,FinalTableName

    ,StartDate
    ,EndDate
    ,Mode
    ,Engine
    ,Status

    ,Stamp_Created
    ,Email_Subject
    ,Email_Sender
    ,Work_dt
    ,Email_To

    ,ClientParentID
    ,ProviderID
    ,DataPulledFrom
    ,dbo.FileControlID
    ,OtherControlID
)
SELECT  
	    smd.DestinationProcessorID
	,adv.ClientID
	,adp.AdvertiserID
	,adp.Site_ID
	,'Stage2' SqlServerJobName

	,gec.SourceServer
	,gec.SourceDatabase
	,gec.DestinationServer FinalServer
	,gec.DestinationDatabase FinalDatabase
	,gec.DestinationTablename FinalTablename

	,adc.work_dt StartDate
	,adc.work_dt EndDate
	,'Stage2' Mode 
	,Engine = coalesce(adc.Engine, '')
	,'P' Status

	,GETDATE() Stamp_Created
	,'SSIS PROC ID:' +CONVERT(VARCHAR(5),smd.DestinationProcessorID) + ' STAGE 2 LOAD - ' 
	,'SSISTeam@merkleinc.com'
	,adc.work_dt
	,ISNULL(cp.EmailTeam,'SSISTeam@merklinc.com')

	,cp.ClientParentID
	,smd.ProviderID
	,gec.SourceTableName DataPulledFrom
	,adc.Control_ID
	,0
    
from [HQIMPDW01].[Exsto].[dbo].[aDownload_Processors] adp 

JOIN HQDMOSQL02.ExstoDisplay.dbo.ClientParent cp 
    ON adp.clientParentID = cp.clientParentID 

join HQDMOSQL03.ExstoDisplay.dbo.adownload_Control adc (NOLOCK)
    on adp.Processor_id = adc.Processor_ID

JOIN HQDMOSQL02.ExstoDisplay.dbo.Advertisers adv 
    ON adp.AdvertiserID = adv.AdvertiserID

JOIN HQIMPETL01.ExstoAdmin.dbo.DestinationMetaData smd (NOLOCK) 
    ON adc.Processor_ID = smd.DestinationProcessorID

JOIN HQIMPETL01.ExstoAdmin.dbo.GenericETLConnectionStrings gec (NOLOCK) 
    ON smd.ConnectionStringID = gec.ConnectionStringID
    AND smd.DestinationStageID = gec.DestinationStageID 
WHERE 
        adc.Status = (select CompletedStatus from #i) 
    and adc.Processor_ID = (select ProcessorID from #i) 
    and smd.DestinationStageID = 2

select * from [HQIMPDW01].[Exsto].[dbo].[aDownload_Processors] where Processor_ID = (select ProcessorID from #i)

/*
select * from HQIMPETL01.ExstoAdmin.dbo.DestinationMetaData where DestinationProcessorID = (select ProcessorID from #i)

*/


/* 
QA Stage 1 by summing the columns in Stage 1.

Remove $ from money columns.

*/
declare @QA varchar(MAX);

set @QA =
'select ' + 
stuff((select ', ' + ColumnName + ' = sum(try_cast(replace(' + ColumnName + ',''$'', '''') as numeric(38,9)))'
       from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
       where DestinationMetaDataID = (select Stage1DestinationMetaDataID from #i)
       order by ColumnOrder
       for xml path('')),1,1,''
) + ', [Count] = count(*)' + 
' from ' + (select Stage1FullTableName from #i)

select [Stage 1 QA] = @QA;

if exists(select * from #i where QA = 1) Exec(@QA);


/*  Copy and paste the sums into an Excel spreadsheet with the sums of the columns.
    Compare the Excel and database sums.
    
*/ 


