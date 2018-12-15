
--First Sql code in the METAL 1 set up
SELECT DISTINCT  
			 filelocation
			,filename_data
			,control_id
			,filelocationprocessed
			,ClientParentID
			, providerID
			, fileType
			,sourceProcID
			,EmailTeam 
			,Site_ID
			,Production,RunProcessDay,PrioritySeq,BatchID,RowsToSkip,ModificationPath

FROM
(
	SELECT DISTINCT DATENAME(dw,GETDATE()) todayDayOfweek,
	convert(varchar(12), getdate(), 108) todaytime,
	CASE --WHEN cms.SundayRuntime IS null THEN 'NO'
		 WHEN DATENAME(dw,GETDATE()) = 'Sunday' AND  ISNULL(convert(varchar(8), cms.SundayRuntime, 108),'00:00:00') <> '00:00:00'
				AND  ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.SundayRuntime, 108),'00:00:00') THEN 'YES'
		  WHEN DATENAME(dw,GETDATE()) = 'Monday' AND  ISNULL(convert(varchar(8), cms.MondayRuntime, 108),'00:00:00') <> '00:00:00'  AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.MondayRuntime, 108),'00:00:00')  THEN 'YES'
		   WHEN DATENAME(dw,GETDATE()) = 'Tuesday' AND  ISNULL(convert(varchar(8), cms.TuesdayRuntime, 108),'00:00:00') <> '00:00:00'  AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.TuesdayRuntime, 108),'00:00:00') THEN 'YES'
		 WHEN DATENAME(dw,GETDATE()) = 'Wednesday' AND ISNULL(convert(varchar(8), cms.WednesdayRuntime, 108),'00:00:00') <> '00:00:00'  AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.WednesdayRuntime, 108),'00:00:00') THEN 'YES'
		  WHEN DATENAME(dw,GETDATE()) = 'Thursday' AND ISNULL(convert(varchar(8), cms.ThursdayRuntime, 108),'00:00:00') <> '00:00:00'  AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.ThursdayRuntime, 108),'00:00:00') THEN 'YES'
		   WHEN DATENAME(dw,GETDATE()) = 'Friday' AND  ISNULL(convert(varchar(8), cms.FridayRuntime, 108),'00:00:00') <> '00:00:00'   AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.FridayRuntime, 108),'00:00:00')  THEN 'YES'
		    WHEN DATENAME(dw,GETDATE()) = 'Saturday' AND ISNULL(convert(varchar(8), cms.SaturdayRuntime, 108),'00:00:00') <> '00:00:00'   AND ISNULL(convert(varchar(8), getdate(), 108),'00:00:00') > ISNULL(convert(varchar(8), cms.SaturdayRuntime, 108),'00:00:00')  THEN 'YES'
		 ELSE 'NO' END RunProcessDay,

	cma.CMAID AssignmentID,
	cms.cmaID scheduleID,cma.DestinationStageID,
			 filelocation
			,filename_data
			,control_id
			,filelocationprocessed
			,adv.ClientParentID
			,CASE 
				WHEN CHARINDEX('4C\Twitter',filelocation,1) > 0 
				THEN 16
				ELSE pv.providerID 
			 END providerID
			,LTRIM(RTRIM([SourceFileExtension])) fileType
			,adc.Processor_ID AS sourceProcID
			,cp.EmailTeam 
			,adc.Site_ID
			,Production
			,1 PrioritySeq
			,1 BatchID, rowstoskip,smd.ModificationPath
				
	FROM 	HQDMOSQL03.ExstoDisplay.dbo.adownload_Control adc (NOLOCK)
			LEFT OUTER JOIN HQDMOSQL02.ExstoDisplay.dbo.Advertisers adv 
				ON adc.Site_ID = adv.siteID  
			LEFT OUTER JOIN HQDMOSQL02.ExstoDisplay.dbo.ClientParent cp 
				ON adv.clientParentID = cp.clientParentID 
			INNER JOIN HQDMOSQL02.ExstoDisplay.dbo.Providers pv 
				ON adv.providerID = pv.providerID
			INNER JOIN HQIMPETL01.[ExstoAdmin].[dbo].[SourceMetaData] smd 
				ON adc.Processor_ID = smd.SourceProcessorID 
			Left Outer Join HQIMPETL01.[ExstoAdmin].[DBO].[SourceHeader] shd
				ON smd.SourceHeaderID = shd.id   
			INNER JOIN HQIMPETL01.[ExstoAdmin].[dbo].[DestinationMetaData] dmd 	 
	 			ON adc.Processor_ID = dmd.DestinationProcessorID    
	LEFT outer JOIN HQIMPETL01.[ExstoAdmin].[dbo].[ClientMetalAssignment] cma ON smd.SourceProcessorID = cma.ProcessorID
													AND 		dmd.DestinationProcessorID = cma.ProcessorID		
													AND 	adv.ClientParentID = cma.ClientParentID	
and adv.advertiserid = cma.advertiserid
	LEFT outer JOIN HQIMPETL01.[ExstoAdmin].[dbo].[ClientMetalSchedule] cms ON cma.CMAID = cms.CMAID
	
	WHERE
	smd.ActiveFlag = 1
	AND dmd.ActiveFlag = 1
	AND CMA.ActiveFlag = 1
	AND cms.ActiveFlag = 0
	AND 
    ISNULL(smd.Production,'N') in ('Y','T','M')
				--'Y' = Loads normally, creates tickets on failure
				--'M' = Loads normally, does not create tickets on failure
				--'T' = Loads normally but will not load to Stage 1 table or create tickets on failure
	--AND status IN ('P') 
	AND cma.DestinationStageID = 1
    AND ADC.CONTROL_ID = 3471336
	AND ISNULL(cp.EmailTeam,'') > '' 
	--AND cms.BatchID =?
	AND (
		CHARINDEX(pv.providerName,adc.filename_data, 1) > 0 
		OR  CHARINDEX(pv.providerName,adc.FileLocation, 1) > 0
	    ) 
		) a
		WHERE RunProcessDay = 'YES'  
	ORDER BY
			 a.Filename_Data ,
	a.PrioritySeq,					
			a.sourceProcID

