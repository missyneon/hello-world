/**********************************************************************/
/***  HOW TO UPDATE Columns in Stage0-2 for the existing Processors ***/
/***                                                                ***/ 
/***!!!!!!! Please remember to REPLACE SourceMetaDataID and  !!!!!!!***/
/***!!!!!!! DestinationMetaDatID with the appropriate values !!!!!!!***/
/***!!!!!!! in SQL and Excel functions						 !!!!!!!***/
/**********************************************************************/

/* Step 1 - Run Metal1 up to "CSV to HeaderChk table" to get data in the HeaderChk table */

/* Step 2 - UPDATE [SourceHeader] table with concatenated values from the 1st row of the HeaderChk table */

/*select * from [ExstoAdmin].[dbo].[SourceHeader] WHERE ID = 112 
update ExstoAdmin.dbo.SourceHeader
set Header = 'Date,Campaign ID,Campaign Label,Strategy ID,Strategy Label,PMP ID,PMP Label,Site ID,Site Label,Size,OS / Browser,Impressions Analyzed (unfiltered),Impressions Analyzed (filtered for GIVT),Impressions Analyzed,Mobile Impressions Analyzed,In-View Measurable Impressions (unfiltered),In-View Measurable Impressions (filtered for GIVT),In-View Measurable Impressions,On-Screen Measurable Impressions,On-Screen Impressions,In-View Impressions (unfiltered),In-View Impressions (filtered for GIVT),In-View Impressions,80% On-Screen for 1 Sec Impressions,Fully On-Screen Measurable Impressions,Fully On-Screen Impressions (No Time Minimum),1 Sec Fully On-Screen Impressions,Clicks (unfiltered),Clicks (filtered for GIVT),Clicks,In-View Time GT 5 Sec Impressions,In-View Time GT 10 Sec Impressions,In-View Time GT 15 Sec Impressions,In-View Time GT 30 Sec Impressions,In-View Time GT 1 Min Impressions,Missed Opportunity (Area) Impressions,Missed Opportunity (Time) Impressions,Human Impressions,Human and In-View Measurable Impressions,Human and Viewable Impressions,Human and 80% On-Screen for 1 Sec Impressions,Human and Fully On-Screen Measurable Impressions,Human and Fully On-Screen Impressions,Human and Fully On-Screen or Large Ad Impressions,Human and 2 Sec Fully On-Screen Impressions,Grapeshot Measurable %,Grapeshot Safe %,Grapeshot Unsafe %,Grapeshot Sensitive %,Grapeshot Adult Content %,Grapeshot Arms %,Grapeshot Crime %,Grapeshot Death And Injury %,Grapeshot Illegal Downloads %,Grapeshot Drugs %,Grapeshot Hate Speech %,Grapeshot Military %,Grapeshot Obscenity %,Grapeshot Terrorism %,Grapeshot Tobacco %'
where ID = 107

*/
UPDATE [ExstoAdmin].[dbo].[SourceHeader]
   SET Header = ''+
			  REPLACE(
					   (SELECT TOP 1 
							[F1]
+','+[F2]
+','+[F3]
+','+[F4]
+','+[F5]
+','+[F6]
+','+[F7]
+','+[F8]
+','+[F9]
+','+[F10]
+','+[F11]
+','+[F12]
+','+[F13]
+','+[F14]
+','+[F15]
+','+[F16]
+','+[F17]
+','+[F18]
+','+[F19]
+','+[F20]
+','+[F21]
+','+[F22]
+','+[F23]
+','+[F24]
+','+[F25]
+','+[F26]
+','+[F27]
+','+[F28]
+','+[F29]
+','+[F30]
+','+[F31]
+','+[F32]
+','+[F33]
+','+[F34]
+','+[F35]
+','+[F36]
+','+[F37]
+','+[F38]
+','+[F39]
+','+[F40]
+','+[F41]
+','+[F42]
+','+[F43]
+','+[F44]
+','+[F45]
+','+[F46]
+','+[F47]
+','+[F48]
+','+[F49]
+','+[F50]
+','+[F51]
+','+[F52]
+','+[F53]


					  FROM [HQDMOSQL04].[ClientDB_CPID72_Staging].[dbo].[PV82DailyMOATDCMBCMSummaryStaginghdrck])
			  ,'&','')+'',
	   UserID = SESSION_USER,
	   UpdateDate = GETDATE() 
 WHERE ID = 112



/* Step 3 - Get the column list to Excel and create computed columns for running the updates */
select TOP 1 * FROM [HQDMOSQL04].[ClientDB_CPID72_Staging].[dbo].[PV82DailyMOATDCMBCMSummaryStaginghdrck]
--OR copy Header record from SOurceHeader table and paste in fn.SplitString and run it against 04 server
--copy column list result and paste Excel column A

-- 3.1 Copy the results and Paste them in Excel
-- 3.2 Delete A1 column ("rowid" - not needed)
-- 3.3 Copy entire Headers and Paste it into A Column in Transpose mode (vertically)
-- 3.4 Delete Row1 (Original Headers)
-- 3.5 Select column B1 and Apply function =CONCATENATE("[",A1,"]") 
-- 3.6 Select column C1 and Apply function =CONCATENATE("UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '",B1,"', UpdateDate = GETDATE() WHERE ColumnOrder = ",ROW(), " AND SourceMetaDataID = 135")
-- 3.7 Select column D1 and Apply function =CONCATENATE("UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '",B1,"', UpdateDate = GETDATE() WHERE ColumnOrder = ",ROW(), " AND DestinationMetaDataID = 183")
-- 3.8 Copy B1-D1 and paste to the rest of the rows
-- 3.9 Copy results from column C and paste it in SQL to run an UPDATE on SourceColumnDefinition table (Step 4 below)
-- 3.10 Copy results from column D and paste it in SQL to run an UPDATE on DestinationColumnDefinition table (Step 5 below)

/*
select * from [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] where SourceMetaDataID = 135

select * from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] where DestinationMetaDataID = 183

*/ 

/* Step 4 - UPDATE Stage0 Columns - [SourceColumnDefinition] table */
/* Example of the syntax generated in Excel - column C */

UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Date]' WHERE ColumnOrder = 1 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Account ID]' WHERE ColumnOrder = 2 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Account Label]' WHERE ColumnOrder = 3 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Campaign ID]' WHERE ColumnOrder = 4 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Campaign Label]' WHERE ColumnOrder = 5 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Site ID]' WHERE ColumnOrder = 6 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Site Label]' WHERE ColumnOrder = 7 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Placement ID]' WHERE ColumnOrder = 8 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Placement Label]' WHERE ColumnOrder = 9 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[OS / Browser]' WHERE ColumnOrder = 10 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Impressions Analyzed (unfiltered)]' WHERE ColumnOrder = 11 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Impressions Analyzed (filtered for GIVT)]' WHERE ColumnOrder = 12 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Impressions Analyzed]' WHERE ColumnOrder = 13 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[In-View Measurable Impressions]' WHERE ColumnOrder = 14 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[1 Sec In-View Impressions]' WHERE ColumnOrder = 15 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[2 Sec In-View Impressions]' WHERE ColumnOrder = 16 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[3 Sec In-View Impressions]' WHERE ColumnOrder = 17 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[5 Sec In-View Impressions]' WHERE ColumnOrder = 18 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[On-Screen Measurable Impressions]' WHERE ColumnOrder = 19 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[On-Screen Impressions]' WHERE ColumnOrder = 20 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[In-View Measurable Rate]' WHERE ColumnOrder = 21 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[1 Sec Video In-View Rate]' WHERE ColumnOrder = 22 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[2 Sec Video In-View Rate]' WHERE ColumnOrder = 23 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[3 Sec Video In-View Rate]' WHERE ColumnOrder = 24 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[5 Sec Video In-View Rate]' WHERE ColumnOrder = 25 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Fully On-Screen Measurable Impressions]' WHERE ColumnOrder = 26 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Fully On-Screen Impressions (No Time Minimum)]' WHERE ColumnOrder = 27 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[1 Sec Fully On-Screen Impressions]' WHERE ColumnOrder = 28 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[3 Sec Fully On-Screen Impressions]' WHERE ColumnOrder = 29 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[% of Video Played In-View]' WHERE ColumnOrder = 30 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Exposure Time (sec)]' WHERE ColumnOrder = 31 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Audible and Fully On-Screen for Half of Duration Impressions]' WHERE ColumnOrder = 32 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[2 Sec In-View and Reached Completion Impressions]' WHERE ColumnOrder = 33 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Audible and 80% On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 34 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Audible  Fully On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 35 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Audible  Fully On-Screen for Half of Duration (15 sec. cap) with Completion Impressions]' WHERE ColumnOrder = 36 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human and In-View Measurable Impressions]' WHERE ColumnOrder = 37 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human and Viewable Impressions]' WHERE ColumnOrder = 38 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human and 3 Sec In-View Impressions]' WHERE ColumnOrder = 39 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human and 3 Sec Fully On-Screen Impressions]' WHERE ColumnOrder = 40 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human and Fully On-Screen Measurable Impressions]' WHERE ColumnOrder = 41 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human 2 Sec In-View and Reached Completion Impressions]' WHERE ColumnOrder = 42 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human and Fully On-Screen for 75% of the Duration Impressions]' WHERE ColumnOrder = 43 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human Audible and 80% On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 44 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human Audible  Fully On-Screen for Half of Duration Impressions]' WHERE ColumnOrder = 45 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human Audible  Fully On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 46 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Human Audible  Fully On-Screen for Half of Duration (15 sec. cap) with Completion Impressions]' WHERE ColumnOrder = 47 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Measurable %]' WHERE ColumnOrder = 48 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Safe %]' WHERE ColumnOrder = 49 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Unsafe %]' WHERE ColumnOrder = 50 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Sensitive %]' WHERE ColumnOrder = 51 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Adult Content %]' WHERE ColumnOrder = 52 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Arms %]' WHERE ColumnOrder = 53 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Crime %]' WHERE ColumnOrder = 54 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Death  Injury %]' WHERE ColumnOrder = 55 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Illegal Downloads %]' WHERE ColumnOrder = 56 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Drugs %]' WHERE ColumnOrder = 57 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Hate Speech %]' WHERE ColumnOrder = 58 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Military %]' WHERE ColumnOrder = 59 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Obscenity %]' WHERE ColumnOrder = 60 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Terrorism %]' WHERE ColumnOrder = 61 AND SourceMetaDataID = 131
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[SourceColumnDefinition] SET ColumnName = '[Grapeshot Tobacco %]' WHERE ColumnOrder = 62 AND SourceMetaDataID = 131


/* Step 5 - UPDATE Stage1 Columns - [DestinationColumnDefinition] table */
/* Example of the syntax generated in Excel - column D */
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Date]' WHERE ColumnOrder = 1 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Account ID]' WHERE ColumnOrder = 2 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Account Label]' WHERE ColumnOrder = 3 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Campaign ID]' WHERE ColumnOrder = 4 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Campaign Label]' WHERE ColumnOrder = 5 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Site ID]' WHERE ColumnOrder = 6 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Site Label]' WHERE ColumnOrder = 7 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Placement ID]' WHERE ColumnOrder = 8 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Placement Label]' WHERE ColumnOrder = 9 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[OS / Browser]' WHERE ColumnOrder = 10 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Impressions Analyzed (unfiltered)]' WHERE ColumnOrder = 11 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Impressions Analyzed (filtered for GIVT)]' WHERE ColumnOrder = 12 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Impressions Analyzed]' WHERE ColumnOrder = 13 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[In-View Measurable Impressions]' WHERE ColumnOrder = 14 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[1 Sec In-View Impressions]' WHERE ColumnOrder = 15 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[2 Sec In-View Impressions]' WHERE ColumnOrder = 16 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[3 Sec In-View Impressions]' WHERE ColumnOrder = 17 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[5 Sec In-View Impressions]' WHERE ColumnOrder = 18 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[On-Screen Measurable Impressions]' WHERE ColumnOrder = 19 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[On-Screen Impressions]' WHERE ColumnOrder = 20 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[In-View Measurable Rate]' WHERE ColumnOrder = 21 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[1 Sec Video In-View Rate]' WHERE ColumnOrder = 22 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[2 Sec Video In-View Rate]' WHERE ColumnOrder = 23 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[3 Sec Video In-View Rate]' WHERE ColumnOrder = 24 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[5 Sec Video In-View Rate]' WHERE ColumnOrder = 25 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Fully On-Screen Measurable Impressions]' WHERE ColumnOrder = 26 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Fully On-Screen Impressions (No Time Minimum)]' WHERE ColumnOrder = 27 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[1 Sec Fully On-Screen Impressions]' WHERE ColumnOrder = 28 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[3 Sec Fully On-Screen Impressions]' WHERE ColumnOrder = 29 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[% of Video Played In-View]' WHERE ColumnOrder = 30 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Exposure Time (sec)]' WHERE ColumnOrder = 31 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Audible and Fully On-Screen for Half of Duration Impressions]' WHERE ColumnOrder = 32 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[2 Sec In-View and Reached Completion Impressions]' WHERE ColumnOrder = 33 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Audible and 80% On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 34 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Audible  Fully On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 35 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Audible  Fully On-Screen for Half of Duration (15 sec. cap) with Completion Impressions]' WHERE ColumnOrder = 36 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human and In-View Measurable Impressions]' WHERE ColumnOrder = 37 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human and Viewable Impressions]' WHERE ColumnOrder = 38 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human and 3 Sec In-View Impressions]' WHERE ColumnOrder = 39 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human and 3 Sec Fully On-Screen Impressions]' WHERE ColumnOrder = 40 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human and Fully On-Screen Measurable Impressions]' WHERE ColumnOrder = 41 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human 2 Sec In-View and Reached Completion Impressions]' WHERE ColumnOrder = 42 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human and Fully On-Screen for 75% of the Duration Impressions]' WHERE ColumnOrder = 43 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human Audible and 80% On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 44 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human Audible  Fully On-Screen for Half of Duration Impressions]' WHERE ColumnOrder = 45 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human Audible  Fully On-Screen for Half of Duration (15 sec. cap) Impressions]' WHERE ColumnOrder = 46 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Human Audible  Fully On-Screen for Half of Duration (15 sec. cap) with Completion Impressions]' WHERE ColumnOrder = 47 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Measurable %]' WHERE ColumnOrder = 48 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Safe %]' WHERE ColumnOrder = 49 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Unsafe %]' WHERE ColumnOrder = 50 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Sensitive %]' WHERE ColumnOrder = 51 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Adult Content %]' WHERE ColumnOrder = 52 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Arms %]' WHERE ColumnOrder = 53 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Crime %]' WHERE ColumnOrder = 54 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Death  Injury %]' WHERE ColumnOrder = 55 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Illegal Downloads %]' WHERE ColumnOrder = 56 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Drugs %]' WHERE ColumnOrder = 57 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Hate Speech %]' WHERE ColumnOrder = 58 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Military %]' WHERE ColumnOrder = 59 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Obscenity %]' WHERE ColumnOrder = 60 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Terrorism %]' WHERE ColumnOrder = 61 AND DestinationMetaDataID = 175
UPDATE [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] SET ColumnName = '[Grapeshot Tobacco %]' WHERE ColumnOrder = 62 AND DestinationMetaDataID = 175


/* Step 6 - Check to see what Stage2 columns will be updated to from Stage1 columns */
/* Use udf_ColumnNameReplace function for Stage2 proper column naming convention

 */
SELECT columnOrder, columnName AS ColumnNameStage1, 
	   [ExstoAdmin].[dbo].udf_ColumnNameReplace
		(   CASE WHEN (ColumnName LIKE '%Advertiser ID%' AND ColumnDataType NOT LIKE '%INT%') 
				 THEN '[ProviderAdvertiserID]' 
				 ELSE ColumnName 
				 END, 1
		) AS ColumnNameStage2
FROM [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
WHERE DestinationMetaDataID = 186 --Stage2 DestinationMetaDataID


/* Step 7 - UPDATE Stage2 Columns - [DestinationColumnDefinition] table */
/* Use udf_ColumnNameReplace function for Stage2 proper column naming convention */
--select D175.columnOrder (Stage1), D175.ColumnNameReplaced (stage1), D176.ColumnName (stage2)
UPDATE D186 --Stage2
SET D186.ColumnName = D185.ColumnNameReplaced
FROM
(select columnOrder, [ExstoAdmin].[dbo].udf_ColumnNameReplace(
		(   CASE WHEN (ColumnName LIKE '%Advertiser ID%' AND ColumnDataType NOT LIKE '%INT%') 
				 THEN '[ProviderAdvertiserID]' 
				 ELSE ColumnName 
				 END
		), 1) ColumnNameReplaced
   from [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition]
  where DestinationMetaDataID = 185) D185 --Stage 1
INNER JOIN [HQIMPETL01].[ExstoAdmin].[dbo].[DestinationColumnDefinition] D186
  ON D185.columnOrder = D186.columnOrder AND D186.DestinationMetaDataID = 186

/* Step 8  - Backup Staging and Summary tables */
/* Step 9  - Move processed files back onto Landing dir */
/* Step 10 - Update aDownload_control with Status = 'P' for the appropriate Processor_ID */
select * from [hqdmosql03].[exstodisplay].[dbo].[adownload_Control] where Processor_ID = 1988

Update [hqdmosql03].[exstodisplay].[dbo].[adownload_Control]
Set Status = 'P'
Where Status = 'C'
and Processor_ID = 1988

/* Step 11 - Backup aProcess_Control for the appropriate Processor_ID */
select * from [hqdmosql03].[exstodisplay].[dbo].[aprocess_Control] where ProcessorID = 1988

select * into [dbo].[aprocess_Control1988] 
from [dbo].[aprocess_Control] 
where ProcessorID = 1988

/* Step 12 - Delete from aProcess_Control for the appropriate Processor_ID */
select * from [hqdmosql03].[exstodisplay].[dbo].[aprocess_Control] where ProcessorID = 1988
delete from [hqdmosql03].[exstodisplay].[dbo].[aprocess_Control] where ProcessorID = 1988

/* Step 13 - test Stage 1 using your test ControlID and do QA1 
/* Step 14 - test Stage 2 using your test ControlID and do QA2
/* Step 15 - Activate entries in Client Assignment and Schedule tables for the appropriate Processor_ID */
/* Step 16 - Confirm data was loaded into stage 1 - Staging table*/
/* Step 17 - Compare Staging new table with backup table using CotrolIDs as a key */
/* Step 18 - Confirm data was loaded into stage 2 - Summary table */
/* Step 19 - Compare Summary new table with backup table using CotrolIDs as a key */
/* Step 20 - Insert data from backup tables if the data is missing in stage1/stage2 tables */
/* Step 21 - Delete backup Staging and Summary tables */
/* Step 22 - Confirm that all outstanding files are loaded and Delete aProcess_Control backup table */




