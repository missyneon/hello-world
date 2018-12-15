/*
User::varProcID
User::varProviderID
User::varClientParentID
User::varGenericStaging
*/

	DECLARE @RC INT
	DECLARE @ProcID INT
	DECLARE @CreationDefinition CHAR(1)
	DECLARE @Stage INT
	DECLARE @Type CHAR(10)
	DECLARE @GenericCreation BIT = 0 
	DECLARE @providerID INT
	DECLARE @executeFlag BIT
	DECLARE @clientParentID INT

	DECLARE @SourceServer VARCHAR(50)
	DECLARE @SourceDB  VARCHAR(50) 
	DECLARE @SourceTable  VARCHAR(100)
	DECLARE @fullSourceTable VARCHAR(200)
	DECLARE @destinationServer VARCHAR(50)
	DECLARE @destinationDB  VARCHAR(50) 
	DECLARE @destinationTable  VARCHAR(100)
	DECLARE @fullDestinationTable VARCHAR(200)
	DECLARE @SourceServer2 VARCHAR(50)
	DECLARE @SourceDB2  VARCHAR(50) 
	DECLARE @SourceTable2  VARCHAR(50)
	DECLARE @fullSourceTable2 VARCHAR(200)
	DECLARE @destinationServer2 VARCHAR(50)
	DECLARE @destinationDB2  VARCHAR(50) 
	DECLARE @destinationTable2  VARCHAR(50)
	DECLARE @fullDestinationTable2 VARCHAR(200)
	DECLARE @sqlhdrck VARCHAR(MAX) = ''
	DECLARE @sqlStaging VARCHAR(MAX) = ''
	DECLARE @sqlDTN VARCHAR(MAX) = ''
	DECLARE @sqlStage2 VARCHAR(MAX) = ''
	DECLARE @totalColumns INT = 0
	DECLARE @TotalStageColumns INT = 0
	DECLARE @TotalFlexColumn INT = 0
	DECLARE @columnCount INT = 1
	DECLARE @MetaID INT = 0
	DECLARE @FlexFile INT = 0
	DECLARE @StageNo INT = 0
	DECLARE @RemoveColumn BIT = 0


	-- TODO: Set parameter values here.

	SET @ProcID =  1665
	SET @CreationDefinition = 'D'
	SET @Stage =2
	SET @Type='TABLE'

	SET @providerID = 48
	SET @executeFlag = 1
	SET @clientParentID = 69
	SET @GenericCreation =0

	
	IF @Type = 'TABLE' AND @Stage = 2
	BEGIN
	-----DTN table
		SELECT @SourceServer = dm.SourceServer,@SourceDB = dm.SourceDatabase,
					 @SourceTable = dm.SourceTableName,@MetaID = smd.ID	,	
					 @destinationServer = dm.DestinationServer,
					 @destinationDB = dm.DestinationDatabase,
					 @destinationTable = dm.DestinationTableName
		  FROM HQIMPETL01.[ExstoAdmin].[dbo].GenericETLConnectionStrings dm
		 INNER JOIN HQIMPETL01.[ExstoAdmin].[dbo].[DestinationMetaData] smd on dm.ConnectionStringID = smd.ConnectionStringID
		 WHERE dm.Processor_ID = @ProcID 
		   AND smd.DestinationStageID = (@Stage)
		   AND ISNULL(smd.ActiveFlag,0) = 1
			
		SET @SourceTable = replace(@SourceTable,'#',CAST(@providerID as varchar))
		SET @SourceDB = replace(@SourceDB,'#',CAST(@clientParentID as varchar))
		SELECT @fullSourceTable = REPLACE (@SourceServer +'.'+ @SourceDB+ '.dbo.'+@SourceTable,'#',@clientParentID)
		
		SET @destinationTable = replace(@destinationTable,'#',CAST(@providerID as varchar))
		SET @destinationDB = replace(@destinationDB,'#',CAST(@clientParentID as varchar))
		SELECT @fullDestinationTable = REPLACE (@destinationServer +'.'+ @destinationDB+ '.dbo.'+@destinationTable,'#',@clientParentID)

			
	--	SELECT @SourceServer,@SourceDB,@SourceTable,@MetaID,@destinationServer,@destinationDB,@destinationTable
		SET @totalColumns = (SELECT max(scd.ColumnOrder)
							   --FROM HQIMPETL01.[ExstoAdmin].[dbo].[DestinationColumnDefinition] scd 
							   FROM HQIMPETL01.[ExstoAdmin].[dbo].vw_DestinationColumnDefinition_ordered scd
							  WHERE scd.DestinationMetaDataID = @MetaID
								AND scd.DestinationStageID = @Stage 
								AND ISNULL(scd.ActiveFlag,0) = 1)
		--SELECT @totalColumns
			
		SET @sqlDTN = ' USE [' + @SourceDB + ']

		IF OBJECT_ID('''+@SourceTable+'_DTN'', ''U'') IS NOT NULL
			DROP TABLE ' +  @SourceTable + '_DTN ; '
			
		IF @sqlDTN IS NULL SET @sqlDTN = 'N/A'
		IF @executeFlag = 1 and  @sqlDTN <> 'N/A' 
			EXEC(@sqlDTN)
		ELSE
			PRINT(@sqlDTN)	
			
	
		SET @columnCount = 1

		SET @sqlDTN = '
			USE [' + @SourceDB + '] 
			CREATE TABLE '+ @SourceTable +'_DTN (
			rowID bigint identity(1,1) not null, '
				
		--SELECT @columnCount,@totalColumns
		WHILE @columnCount <= @totalColumns
		BEGIN
			SET @sqlDTN = (SELECT @sqlDTN + scd.ColumnName + ' ' + ColumnDataType + ' NULL,' 	
							FROM HQIMPETL01.[ExstoAdmin].[dbo].vw_DestinationColumnDefinition_ordered scd
							-- FROM HQIMPETL01.[ExstoAdmin].[dbo].[DestinationColumnDefinition] scd 
							WHERE scd.DestinationMetaDataID = @MetaID
							  AND scd.DestinationStageID = @Stage
							  AND ISNULL(scd.ActiveFlag,0) = 1 
							  AND scd.ColumnOrder = @columnCount)
			SELECT @sqlDTN
			SET @columnCount = @columnCount+1
            print N'@columnCount line 113'
            print (@columnCount)
            print N'@sqlDTN line 113'
            print (@sqlDTN)

		END
		
		SET @sqlDTN = REPLACE((SUBSTRING(@sqlDTN,1,len(@sqlDTN)-5) + ' ) ON [PRIMARY] '),'IDENTITY(1,1) NULL,','IDENTITY(1,1) NOT NULL,')
		SELECT @sqlDTN
		
		IF @sqlDTN IS NULL SET @sqlDTN = 'N/A'
		IF @executeFlag = 1 and @sqlDTN <> 'N/A' 
			EXEC(@sqlDTN)
		ELSE
			PRINT(@sqlDTN)	

---REGONLONE

		SELECT @SourceServer2 = dm.SourceServer,@SourceDB2 = dm.SourceDatabase,
			   @SourceTable2 = dm.SourceTableName,@MetaID = smd.ID	,	
			   @destinationServer2 = dm.DestinationServer,
			   @destinationDB2 = dm.DestinationDatabase,
			   @destinationTable2 = dm.DestinationTableName
		  FROM HQIMPETL01.[ExstoAdmin].[dbo].GenericETLConnectionStrings dm
		 INNER JOIN	HQIMPETL01.[ExstoAdmin].[dbo].[DestinationMetaData] smd ON dm.ConnectionStringID = smd.ConnectionStringID
		 WHERE dm.Processor_ID = @ProcID 
		   AND smd.DestinationStageID = @Stage
		   AND ISNULL(smd.ActiveFlag,0) = 1
			
		SET @SourceTable2 = replace(@SourceTable2,'#',CAST(@providerID as varchar))
		SET @SourceDB2 = replace(@SourceDB2,'#',CAST(@clientParentID as varchar))
		--	SELECT @fullSourceTable2 = REPLACE (@SourceServer2 +'.'+ @SourceDB2+ '.dbo.'+@SourceTable2,'#',@clientParentID)
		
		SET @destinationTable2 = replace(@destinationTable2,'#',CAST(@providerID as varchar))
		SET @destinationDB2 = replace(@destinationDB2,'#',CAST(@clientParentID as varchar))
		SELECT @fullDestinationTable2 = REPLACE (@destinationServer2 +'.'+ @destinationDB2+ '.dbo.'+@destinationTable2,'#',@clientParentID)

			
		---SELECT @SourceServer2,@SourceDB2,@SourceTable2,@MetaID,@destinationServer2,@destinationDB2,@destinationTable2
		---Total columns to create are the ones that are in Stage 2 and [RemoveColInDestTable] = 0
		SET @totalColumns = ( SELECT max(scd.ColumnOrder)
								FROM HQIMPETL01.[ExstoAdmin].[dbo].[DestinationColumnDefinition] scd 
							   WHERE scd.DestinationMetaDataID = @MetaID
								 AND scd.DestinationStageID = @Stage 
								 AND ISNULL(scd.ActiveFlag,0) = 1
								 AND ISNULL(scd.[RemoveColInDestTable],0) = 0)
		--		SELECT @totalColumns
			
			
		IF @totalColumns IS NOT NULL
   		BEGIN
			SET @columnCount = 1	
			SET @sqlStage2 = 	' USE [' + @destinationDB2 + ']

				IF OBJECT_ID('''+@destinationTable2+''', ''U'') IS  NULL
				
					CREATE TABLE '+ @destinationTable2 +' (				
					rowid bigint identity(1,1) not null, ' 

			WHILE @columnCount <= @totalColumns
			BEGIN
				--check the flag for removing from final Stage 2 table 
				SET @RemoveColumn = ( SELECT ISNULL(RemoveColInDestTable,0)  
										FROM HQIMPETL01.[ExstoAdmin].[dbo].[DestinationColumnDefinition] scd 
									   WHERE scd.DestinationMetaDataID = @MetaID
										 AND scd.DestinationStageID = @Stage 
										 AND ISNULL(scd.ActiveFlag,0) = 1 
										 AND scd.ColumnOrder = @columnCount)
				IF @RemoveColumn = 0
				BEGIN
					SET @sqlStage2 = (SELECT @sqlStage2 + scd.ColumnName + ' ' + ColumnDataType + ' NULL,' 	
										FROM HQIMPETL01.[ExstoAdmin].[dbo].[DestinationColumnDefinition] scd 
									   WHERE scd.DestinationMetaDataID = @MetaID
										 AND scd.DestinationStageID = @Stage 
										 AND ISNULL(scd.ActiveFlag,0) = 1 
										 AND scd.ColumnOrder = @columnCount)
				END
				SET @columnCount = @columnCount+1
					
			END
			SET @sqlStage2 = REPLACE((SUBSTRING(@sqlStage2,1,len(@sqlStage2)-5) + ' ) ON [PRIMARY] '),'IDENTITY(1,1) NULL,','IDENTITY(1,1) NOT NULL,')

			IF @sqlStage2 IS NULL SET @sqlStage2 = 'N/A'	

			IF @executeFlag = 1 and  @sqlDTN <> 'N/A' 
				EXEC(@sqlStage2)
			ELSE
				PRINT @sqlStage2 
		END
		
	END
	


