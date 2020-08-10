/*
This is an Execute SQL action for the 'Tables - Modified' advisory condition.
For more information, see the following:
	-blog post to follow
	https://docs.sentryone.com/help/actions
Melissa Connors
Copyright 2020 SQL Sentry, LLC
*/
DECLARE @DatabaseName as nvarchar(128)
DECLARE @TargetServer as nvarchar(128)
DECLARE @SubjectText as nvarchar(255)
DECLARE @ModifieddDate as datetime

CREATE TABLE #ModifiedTables (
    DatabaseSchemaTableName nvarchar(400),
	ModifyDate datetime
);

DECLARE All_Databases_Cursor CURSOR FOR  
SELECT [d].[name]   
FROM sys.databases d WITH (NOLOCK)
WHERE database_id > 4 --this excludes system databases
AND state = 0; --only online databases
OPEN All_Databases_Cursor;  
FETCH NEXT FROM All_Databases_Cursor INTO @DatabaseName;  
WHILE @@FETCH_STATUS = 0  
   BEGIN  
	  DECLARE @sqlTables nvarchar(max) = 
	  'INSERT INTO #ModifiedTables SELECT CONCAT (''' + QUOTENAME(@DatabaseName) +''',
	   ''.['', [s].[name],
	   ''].['', [t].[name], '']'') AS DatabaseSchemaTableName,
		[t].[modify_date] FROM ' + QUOTENAME(@DatabaseName) + '.sys.tables t WITH (NOLOCK) 
		JOIN ' + QUOTENAME(@DatabaseName) + '.sys.schemas s WITH (NOLOCK) ON [s].[schema_id] = [t].[schema_id]
		WHERE [t].[modify_date] > (SELECT DATEADD(HH, -1, GETDATE()))
		AND [t].[modify_date] != [t].[create_date]' --set the DATEADD to match your evalulation frequency
	  EXEC sp_executesql @sqlTables
      FETCH NEXT FROM All_Databases_Cursor INTO @DatabaseName;  
   END;  
CLOSE All_Databases_Cursor;  
DEALLOCATE All_Databases_Cursor;  

SET @TargetServer = @@SERVERNAME

DECLARE @HTMLTableRows nvarchar(max), @Body nvarchar(max);
SELECT @HTMLTableRows = CONVERT(nvarchar(max), 
(SELECT td = @TargetServer + N'  ' + DatabaseSchemaTableName, N'',
    td = ModifyDate
FROM #ModifiedTables
ORDER BY ModifyDate DESC
FOR XML PATH(N'tr'), ELEMENTS));
 
SET @Body = N'<html><head>
<style> * { font-family: Segoe UI, calibri } </style>
</head><body>
<H4>The following tables have been modified:</H4>
<p><table border="1" cellpadding="10"> 
<tr><th>Server  [Database].[Schema].[Table]</th><th>ModifyDate</th></tr>'
  + @HTMLTableRows + N'</table></body></html>';

SET @SubjectText = @TargetServer + ':  Tables - Modified';

--See https://docs.sentryone.com/help/sp-sentry-dbmail-20 for a full list of available parameters
EXEC msdb.dbo.sp_sentry_dbmail_20	
     @body        = @Body,
     @body_format = N'HTML',
     @recipients  = N'YourEmail@GoesHere.com',--set your email address here
     @subject	  = @SubjectText

DROP TABLE #ModifiedTables;
