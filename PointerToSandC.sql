BEGIN TRY

DECLARE @FullFileName VARCHAR(1000) = ?;
DECLARE @ValueBeforeHeader VARCHAR(100) = ?;
DECLARE @FooterStopValue VARCHAR(100) = ?;
DECLARE @NoDataProvidedValue varchar(500) = ?;
DECLARE @ColumnDelimiterOrig CHAR(1) = ?;
DECLARE @ColumnDelimiterReplacement CHAR(1) = ?;
DECLARE @FileControlID BIGINT = ?;
DECLARE @FileName VARCHAR(1000) = ?;
DECLARE @FileType VARCHAR(20) = ?;


DECLARE @ReturnCode INT;
DECLARE @Command VARCHAR(1000);
DECLARE @SSISPath VARCHAR(1000);
DECLARE @ErrorMessage NVARCHAR(3000) = '';
DECLARE @TotalWriteRows BIGINT = 0;

-- !!!! Please make sure to check if this path with a valid one !!!!
SET @SSISPath = 'J:\Landing\ExstoDisplay\SSIS_Production\ExstoDisplay_SQL03_VS2010\ExstoDisplay_SQL03_VS2010\HQDMOSQL03_Metal1_FileClean_All.dtsx';
--SET @SSISPath = 'C:\Users\smojekwucon\Desktop\SSIS_SQL03\SSIS\ExstoDisplay\ExstoDisplay\ExstoDisplay_SQL03_VS2010\ExstoDisplay_SQL03_VS2010\ExstoDisplay_SQL03_VS2010\HQDMOSQL03_Metal1_FileClean_All.dtsx';
SET @Command = '"E:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec"';
SET @Command = 'cd.. && ' + @Command + ' /F "' + @SSISPath + '"';

-- Set Remote Package Parameters
SET @Command = @Command + ' /SET \Package.Variables[User::varFullFileName].Properties[Value];"' + @FullFileName + '"';
IF LTRIM(RTRIM(@ValueBeforeHeader)) != ''
   SET @Command = @Command + ' /SET \Package.Variables[User::varValueBeforeHeader].Properties[Value];"' + @ValueBeforeHeader + '"';
IF LTRIM(RTRIM(@FooterStopValue)) != ''
   SET @Command = @Command + ' /SET \Package.Variables[User::varFooterStopValue].Properties[Value];"' + @FooterStopValue + '"';
IF LTRIM(RTRIM(@NoDataProvidedValue)) != ''
   SET @Command = @Command + ' /SET \Package.Variables[User::varNoDataProvidedValue].Properties[Value];"' + @NoDataProvidedValue + '"';
         
SET @Command = @Command + ' /SET \Package.Variables[User::varColumnDelimiterOrig].Properties[Value];"' + @ColumnDelimiterOrig + '"';
SET @Command = @Command + ' /SET \Package.Variables[User::varColumnDelimiterReplacement].Properties[Value];"' + @ColumnDelimiterReplacement + '"';
SET @Command = @Command + ' /SET \Package.Variables[User::varFileControlID].Properties[Value];"' + CAST(@FileControlID AS VARCHAR(25)) + '"';

CREATE TABLE #output (outputValue VARCHAR(3000) NULL);
INSERT #output EXEC @ReturnCode = master..xp_cmdshell @Command; --@ReturnCode=[0,1] (success, failure)

-- If we have an error assign @ErrorMessage variable
IF @ReturnCode <> 0 
BEGIN
    SELECT @ErrorMessage = @ErrorMessage + outputValue
    FROM #output
    WHERE outputValue IS NOT NULL;
    
    DROP TABLE #output;  
END

-- Get values from [Metal1FileControlAudit] and assign; overwrite @ErrorMessage with value from [Metal1FileControlAudit] if any recorded
SELECT TOP 1 @TotalWriteRows = TotalWriteRows, 
         @ErrorMessage = CAST(COALESCE(NULLIF(ErrorMsg,''), NULLIF(@ErrorMessage,'')) AS NVARCHAR(3000)),
         @FileName = CASE WHEN @FileType = 'xls'
                      THEN STUFF(@FileName, len(@FileName) - 3,4, '.csv')          
                      WHEN @FileType = 'xlsx'
                      THEN STUFF(@FileName, len(@FileName) - 4,5, '.csv')
                      ELSE @FileName
                    END ,
         @FileType = REPLACE(REPLACE(@FileType,'xlsx','csv'),'xls','csv')
  FROM [dbo].[Metal1FileControlAudit] (nolock)
WHERE FileControlID = @FileControlID
ORDER BY CreateDateTime DESC;

SELECT @TotalWriteRows TotalWriteRows, @ErrorMessage  ErrorMessage, @FileName FileName, @FileType FileType;

IF @ErrorMessage IS NOT NULL
BEGIN 
    SELECT 5/0; /* Fake the error */
END
END TRY

BEGIN CATCH
    THROW 50000, @ErrorMessage, 1;
END CATCH