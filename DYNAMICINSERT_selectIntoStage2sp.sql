USE [ClientDB_Generic]
					INSERT INTO ClientDB_CPID66_Staging.dbo.PV80DailyDBMTrueviewSummaryStaging_DTN ([Date] , [LineItem] , [LineItemID] , [LineItemStatus] , [LineItemIntegrationCode] , [TrueViewAdGroupID] , [TrueViewAdGroup] , [TrueViewAdID] , [TrueViewAd] , [AdvertiserCurrency] , [Impressions] , [Clicks] , [RevenueAdvCurrency] , [FirstQuartileViewsVideo] , [MidpointViewsVideo] , [ThirdQuartileViewsVideo] , [CompleteViewsVideo] , [ControlID] , [LoadDateTime])   SELECT 
				CASE WHEN len([Date]) = 0 or ISDATE([Date]) = 0
				THEN '1900-01-01'
				ELSE CONVERT(DATETIME,[Date]) END AS [Date] , 

                ISNULL([Line Item],'') AS [LineItem] , 

				CASE WHEN len([Line Item ID]) = 0  or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Line Item ID]))) = 0
				THEN '0'
				ELSE CONVERT(bigint,[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Line Item ID]))) END  AS [LineItemID] , 

                ISNULL([Line Item Status],'') AS [LineItemStatus] ,
                 
				CASE WHEN len([Line Item Integration Code]) = 0  or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Line Item Integration Code]))) = 0
				THEN '0'
				ELSE CONVERT(bigint,[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Line Item Integration Code]))) END  AS [LineItemIntegrationCode] , 

				CASE WHEN len([TrueView Ad Group ID]) = 0  or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([TrueView Ad Group ID]))) = 0
				THEN '0'
				ELSE CONVERT(bigint,[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([TrueView Ad Group ID]))) END  AS [TrueViewAdGroupID] , 
                
                ISNULL([TrueView Ad Group],'') AS [TrueViewAdGroup] , 
                
                ISNULL([TrueView Ad ID],'') AS [TrueViewAdID] , 
                
                ISNULL([TrueView Ad],'') AS [TrueViewAd] , 
                
                ISNULL([Advertiser Currency],'') AS [AdvertiserCurrency] , 
                  
				CASE WHEN len([Impressions]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Impressions]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Impressions]))) END AS [Impressions] ,   

				CASE WHEN len([Clicks]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Clicks]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Clicks]))) END AS [Clicks] ,  
                 
				CASE WHEN len([Revenue (Adv Currency)]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Revenue (Adv Currency)]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Revenue (Adv Currency)]))) END AS [RevenueAdvCurrency] ,  
                 
				CASE WHEN len([First-Quartile Views (Video)]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([First-Quartile Views (Video)]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([First-Quartile Views (Video)]))) END AS [FirstQuartileViewsVideo] , 
                  
				CASE WHEN len([Midpoint Views (Video)]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Midpoint Views (Video)]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Midpoint Views (Video)]))) END AS [MidpointViewsVideo] , 
                  
				CASE WHEN len([Third-Quartile Views (Video)]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Third-Quartile Views (Video)]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Third-Quartile Views (Video)]))) END AS [ThirdQuartileViewsVideo] , 
                  
				CASE WHEN len([Complete Views (Video)]) = 0 or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Complete Views (Video)]))) = 0
				THEN '0.00'
				ELSE CONVERT(numeric(18,9),[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([Complete Views (Video)]))) END AS [CompleteViewsVideo] , 

                CASE WHEN len([ControlID]) = 0  or isnumeric([dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([ControlID]))) = 0
				THEN '0'
				ELSE CONVERT(bigint,[dbo].[fnRemoveSpecialChars]([dbo].[fnConvertScientificNotation]([ControlID]))) END  AS [ControlID] , 
                
                CASE WHEN len([LoadDateTime]) = 0 or ISDATE([LoadDateTime]) = 0
				THEN '1900-01-01'
				ELSE CONVERT(DATETIME,[LoadDateTime]) END AS [LoadDateTime]

                from ClientDB_CPID66_Staging.dbo.PV80DailyDBMTrueviewSummaryStaging

