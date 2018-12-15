
SELECT  processControlID, ProcessorID, ClientParentID, AdvertiserID, StagingServer,StagingDatabase,
	   StagingTable, FinalServer, FinalDatabase, FinalTableName, Email_Subject, Engine, Email_To,
	   FileControlID, OtherControlID,ProviderID, work_dt, convert(varchar(5),SpecialCodeID) SpecialCodeID , 
	   GenericStaging, hasDataInCorrectFormat, ProcessStatus
FROM 
(
     SELECT DISTINCT 
			DATENAME(dw,GETDATE()) todayDayOfweek,
			CONVERT(varchar(12), getdate(), 108) todaytime,
			CASE --WHEN cms.SundayRuntime IS null THEN 'NO'
				 WHEN DATENAME(dw,GETDATE()) = 'Sunday'    AND ISNULL(convert(varchar(8), cms.SundayRuntime, 108),'00:00:00') <> '00:00:00'
						AND  ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.SundayRuntime, 108),'00:00:00') THEN 'YES'
				 WHEN DATENAME(dw,GETDATE()) = 'Monday'    AND ISNULL(convert(varchar(8), cms.MondayRuntime, 108),'00:00:00') <> '00:00:00'  
						AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.MondayRuntime, 108),'00:00:00')  THEN 'YES'
				 WHEN DATENAME(dw,GETDATE()) = 'Tuesday'   AND ISNULL(convert(varchar(8), cms.TuesdayRuntime, 108),'00:00:00') <> '00:00:00'  
						AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.TuesdayRuntime, 108),'00:00:00') THEN 'YES'
				 WHEN DATENAME(dw,GETDATE()) = 'Wednesday' AND ISNULL(convert(varchar(8), cms.WednesdayRuntime, 108),'00:00:00') <> '00:00:00' 
						AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.WednesdayRuntime, 108),'00:00:00') THEN 'YES'
				 WHEN DATENAME(dw,GETDATE()) = 'Thursday'  AND ISNULL(convert(varchar(8), cms.ThursdayRuntime, 108),'00:00:00') <> '00:00:00' 
						AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.ThursdayRuntime, 108),'00:00:00') THEN 'YES'
				 WHEN DATENAME(dw,GETDATE()) = 'Friday'    AND ISNULL(convert(varchar(8), cms.FridayRuntime, 108),'00:00:00') <> '00:00:00' 
						AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.FridayRuntime, 108),'00:00:00') THEN 'YES'
				 WHEN DATENAME(dw,GETDATE()) = 'Saturday'  AND ISNULL(convert(varchar(8), cms.SaturdayRuntime, 108),'00:00:00') <> '00:00:00' 
						AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.SaturdayRuntime, 108),'00:00:00') THEN 'YES'
				 ELSE 'NO' END RunProcessDay,
			cma.CMAID AssignmentID, cms.cmaID scheduleID, cma.DestinationStageID, 
			processControlID, adc.ProcessorID, adc.ClientParentID, adc.AdvertiserID, 
			StagingServer, StagingDatabase,	DataPulledFrom StagingTable, 
			FinalServer, FinalDatabase, FinalTableName, 
			Email_Subject, Engine, Email_To,
			FileControlID, OtherControlID, smd.ProviderID,
			CONVERT(VARCHAR(10),ISNULL(work_dt,'1900-01-01'),121) work_dt,
			smd.SpecialCodeID, smd.GenericStaging, 
			ISNULL(ges.hasDataInCorrectFormat,0) hasDataInCorrectFormat,
			PrioritySeq, adc.status ProcessStatus
	   FROM HQDMOSQL03.ExstoDisplay.dbo.aProcess_Control adc
	  INNER JOIN HQIMPETL01.[ExstoAdmin].[dbo].[DestinationMetaData] smd on adc.ProcessorID = smd.DestinationProcessorID
	  INNER JOIN HQIMPETL01.[ExstoAdmin].[dbo].GenericETLConnectionStrings ges on smd.DestinationProcessorID = ges.Processor_ID AND ges.DestinationStageID = 1 
	   LEFT OUTER JOIN HQDMOSQL02.ExstoDisplay.dbo.Advertisers adv ON adc.SiteID = adv.siteID  
	   LEFT OUTER JOIN HQDMOSQL02.ExstoDisplay.dbo.ClientParent cp ON adv.clientParentID = cp.clientParentID 
	  INNER JOIN HQDMOSQL02.ExstoDisplay.dbo.Providers pv ON adv.providerID = pv.providerID
	  left outer  JOIN HQIMPETL01.[ExstoAdmin].[dbo].[ClientMetalAssignment] cma ON smd.DestinationProcessorID = cma.ProcessorID AND adv.ClientParentID = cma.ClientParentID	
	  left outer join  HQIMPETL01.[ExstoAdmin].[dbo].[ClientMetalSchedule] cms ON cma.CMAID = cms.CMAID
	

	  WHERE  cms.ActiveFlag = 1	AND 
	--adc.status IN ('P') AND /* 'P' – Ready for processing; 'A' - Reviewed and Approved for processing */  
 --smd.DestinationStageID = 2
	--  AND cma.DestinationStageID = 2
	--    AND ISNULL(smd.ActiveFlag,0) = 1  
	--   AND ISNULL(cma.ActiveFlag,0) = 1	
	--	and cma.AdvertiserID=adc.AdvertiserID	
	--	and batchID =?
     FileControlID = 3463216
		
) a
WHERE RunProcessDay = 'YES'
ORDER BY processControlID,PrioritySeq, ProcessorID, work_dt, FileControlID


