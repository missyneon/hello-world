/*
User::varStagingServer
User::varStagingDB
User::varStagingTable
User::varDestinationServer
User::varDestinationDB
User::varDestinationTable
User::varPreProcess
User::varDownloadControlID
User::varProviderID
User::varClientParentID
User::varProcID
*/

	
	DECLARE @sql VARCHAR(MAX)
		,@sprocName VARCHAR(200)
		,@Stage INT = 2
		,@executeFlag INT = 1
		,@AssignedAdvertiserID BIGINT = 0
		,@SourceServer  VARCHAR(200) = 'HQDMOSQL04'
		,@SourceDB VARCHAR(200) = 'ClientDB_CPID#_Staging'
		,@SourceTblName VARCHAR(200) = 'PV#DailyDBMTrueviewSummaryStaging'
		,@DestinationServer  VARCHAR(200) = 'HQDMOSQL04'
		,@DestinationDB VARCHAR(200) = 'ClientDB_CPID#'
		,@DestinationTblName VARCHAR(200) = 'PV#DailyDBMTrueviewSummary'
		,@preProcessSPID varchar(5)  = 11
        ,@ControlID  bigint = 3464713
		,@ProviderID int = 80
		,@Filename VARCHAR(100) = ''
		,@CPID INT = 66 
		,@ProcessorID bigint = 1991

  --      DECLARE @sql VARCHAR(MAX)
		--,@sprocName VARCHAR(200)
		--,@Stage INT = 2
		--,@executeFlag INT = 1
		--,@AssignedAdvertiserID BIGINT = 0
		--,@SourceServer  VARCHAR(200) = 'HQDMOSQL04'
		--,@SourceDB VARCHAR(200) = 'ClientDB_CPID#_Staging'
		--,@SourceTblName VARCHAR(200) = 'PV#DailyDBMTrueviewSummaryStaging'
		--,@DestinationServer  VARCHAR(200) = 'HQDMOSQL04'
		--,@DestinationDB VARCHAR(200) = 'ClientDB_CPID#'
		--,@DestinationTblName VARCHAR(200) = 'PV#DailyDBMTrueviewSummary'
		--,@preProcessSPID varchar(5)  = 11
  --      ,@ControlID  bigint = 3464713
		--,@ProviderID int = 80
		--,@Filename VARCHAR(100) = ''
		--,@CPID INT = 66 
		--,@ProcessorID bigint = 1991
	  
	
	DECLARE @specialFunction VARCHAR(50)
		,@spFunction VARCHAR(50)
		,@preProcessSP VARCHAR(500)

	SET @SourceDB = REPLACE(@SourceDB,'#',@CPID)
	SET @DestinationDB = REPLACE(@DestinationDB,'#',@CPID)

	SET @SourceTblName = REPLACE(@SourceTblName,'#',@ProviderID)+'_DTN'
	SET @DestinationTblName = REPLACE(@DestinationTblName,'#',@ProviderID)

				IF @executeFlag = 0
				insert into ClientDB_Generic_Staging.dbo.DynamicTrace  (string,ActionDate)
				select  @preProcessSPID + ' @preProcessSPID'  string  , getdate()

	SELECT @preProcessSP = SpecialCode 
	  FROM HQIMPETL01.ExstoAdmin.dbo.SpecialCode
	 WHERE SpecialCodeID = @preProcessSPID 
    

				IF @executeFlag = 0
				insert into ClientDB_Generic_Staging.dbo.DynamicTrace   (string,ActionDate)
				select @preProcessSP + ' @preProcessSP'  string, getdate()

              

		SET @preProcessSP =
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE(
			REPLACE( 
				REPLACE	(
					REPLACE(@preProcessSP,'=@SourceServer','='+@SourceServer),'=@SourceDB','='+@SourceDB),'=@SourceTblName','='+@SourceTblName),
						'=@DestinationServer','='+@DestinationServer),
						'=@DestinationDB','='+@DestinationDB),
						'=@DestinationTblName','='+@DestinationTblName),
						'=@CPID','='+CONVERT(VARCHAR(5),@CPID)),
						'= @ProcessorID','='+CONVERT(VARCHAR(5),@ProcessorID))

						
						
	

	--don't process if preProcessSP is NULL
	  IF @preProcessSP IS NULL RETURN 

	SELECT @Filename = Filename_Attachment 
	  FROM HQDMOSQL03.ExstoDisplay.dbo.aDownload_Control
	 WHERE Control_ID = @ControlID

				 IF @executeFlag = 0
	 				insert into ClientDB_Generic_Staging.dbo.DynamicTrace   (string,ActionDate)
				select @Filename + ' @Filename'  string, getdate()

	SET @specialFunction = (Select CHARINDEX('(',@preProcessSP,1))
    print N'specialFunction'
    print @specialFunction
				IF @executeFlag = 0
	 					insert into ClientDB_Generic_Staging.dbo.DynamicTrace  (string,ActionDate)
					select @specialFunction + ' @specialFunction'  string, getdate()

	IF @specialFunction > 0
	BEGIN 
		SET @spFunction = 
			(SELECT SUBSTRING(@preProcessSP,@specialFunction+1,ISNULL((LEN(@preProcessSP)-(@specialFunction+1)),LEN(@preProcessSP))))

		SET @preProcessSP = (SELECT SUBSTRING(@preProcessSP,1,CHARINDEX('(',@preProcessSP,1)-1))
	END   
	ELSE
	BEGIN
		SET @preProcessSP = @preProcessSP
	END

    

	IF @executeFlag = 0 
		 	insert into ClientDB_Generic_Staging.dbo.DynamicTrace  (string,ActionDate)
	select @spFunction + ' @spFunction'  string, getdate()
	
	IF @executeFlag = 0 
		 	insert into ClientDB_Generic_Staging.dbo.DynamicTrace  (string,ActionDate)
	select @preProcessSP + ' @preProcessSP before the SQL'  string, getdate()

	IF CHARINDEX('EXEC',@preProcessSP,1)>0
		SET @sql = @preProcessSP
	ELSE
    	SET @sql =  '
   DECLARE @RC int 
EXECUTE @RC = ' + @preProcessSP + 
case when @preProcessSP not like '%DECLARE%' then
 '
    @ProviderID = '+CAST(@ProviderID AS VARCHAR) +'
	,@DebugFlag = 0 
    ,@SourceServer  = ''' +@SourceServer + '''
    ,@SourceDB =''' + @SourceDB  + '''
    ,@SourceTblName = ''' +@SourceTblName + '''
    ,@DestinationServer  = ''' +@DestinationServer + '''
    ,@DestinationDB =''' + @DestinationDB + '''
    ,@DestinationTblName = ''' +@DestinationTblName + '''
    ,@FileName = ''' + @FileName +'''
    ,@Function = ''' + ISNULL(@spFunction,'''')+'''
	,@ControlID = '+CAST(@ControlID AS VARCHAR)
		END  +''  

IF @executeFlag = 0
insert into ClientDB_Generic_Staging.dbo.DynamicTrace   (string,ActionDate)
select @sql ,getdate()

	--IF @sql IS NULL --SET @sql = 'N/A'

    PRINT @sql	
	IF @executeFlag = 1    and @Sql is NOT NULL 
		EXEC(@sql)
	ELSE
		PRINT @sql	
IF @executeFlag = 0
		insert into ClientDB_Generic_Staging.dbo.DynamicTrace   (string,ActionDate)
select 'After Exec'  ,getdate()

