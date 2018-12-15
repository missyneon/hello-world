SET @LoopCount = 1
 SET @Sql=' USE ['+@DestinationDB+'] 
 IF OBJECT_ID('''@HdrckFile''', ''U'') IS NOT NULL
 DROP TABLE dbo.'@HdrckFile'
 CREATE TABLE dbo.['+@HdrckFile+'](
 '
 WHILE @LoopCount <= @headerCount
 BEGIN
 SELECT @HeaderColumnName = QUOTENAME(ColumnAlias) FROM ##tempMap WHERE FileColumnOrder = @LoopCount
 SET @Sql=(SELECT @Sql ' '@HeaderColumnName+' nvarchar(3000) NULL, ' FROM ##tempMap WHERE FileColumnOrder = @LoopCount)
 SET @LoopCount =@LoopCount + 1
 END

SET @Sql = SUBSTRING(@Sql,1,LEN(@Sql)-1)
 SET @Sql = @Sql + ') ON PRIMARY'

select @sql
 print 470
 print @sql
 EXEC(@sql)
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------
 Result
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------
 (1 row(s) affected)
 470
 USE ClientDB_CPID87_Staging 
 IF OBJECT_ID('PV89DailyAvidtrakSummaryStaginghdrck', 'U') IS NOT NULL
 DROP TABLE dbo.PV89DailyAvidtrakSummaryStaginghdrck
 CREATE TABLE dbo.PV89DailyAvidtrakSummaryStaginghdrck(
Name : Search 1 nvarchar(3000) NULL) ON PRIMARY
