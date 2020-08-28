/*
This is an Execute SQL action for the 'Triggers - Created' advisory condition.
For more information, see the following:
	https://www.sentryone.com/blog/using-sentryone-to-alert-on-sql-server-database-object-changes
	https://docs.sentryone.com/help/actions
Melissa Connors
Copyright 2020 SQL Sentry, LLC
*/
DECLARE @DatabaseName as nvarchar(128)
DECLARE @TargetServer as nvarchar(128)
DECLARE @SubjectText as nvarchar(255)
DECLARE @CreatedDate as datetime

CREATE TABLE #CreatedTriggers (
    DatabaseSchemaParentTriggerName nvarchar(500),
	ParentTypeDesc nvarchar(60),
	CreateDate datetime
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
	  DECLARE @sqlTriggers nvarchar(max) = 
	  'INSERT INTO #CreatedTriggers SELECT CONCAT (''' + QUOTENAME(@DatabaseName) +''',
	   ''.['', [s].[name],
	   ''].['', [o].[name],
	   ''].['', [t].[name], '']'') AS DatabaseSchemaParentTriggerName,
	    [o].[type_desc],
		[t].[create_date] FROM ' + QUOTENAME(@DatabaseName) + '.sys.triggers t WITH (NOLOCK) 
		JOIN ' + QUOTENAME(@DatabaseName) + '.sys.objects o WITH (NOLOCK) ON [t].[parent_id] = [o].[object_id]
		JOIN ' + QUOTENAME(@DatabaseName) + '.sys.schemas s WITH (NOLOCK) ON [o].[schema_id] = [s].[schema_id]
		WHERE [t].[create_date] >= (SELECT DATEADD(HH, -1, GETDATE()))' --set to match your evalulation frequency
	  EXEC sp_executesql @sqlTriggers
      FETCH NEXT FROM All_Databases_Cursor INTO @DatabaseName;  
   END;  
CLOSE All_Databases_Cursor;  
DEALLOCATE All_Databases_Cursor;  

SET @TargetServer = @@SERVERNAME

DECLARE @HTMLTableRows nvarchar(max), @Body nvarchar(max);
SELECT @HTMLTableRows = CONVERT(nvarchar(max), 
(SELECT td = @TargetServer + N'  ' + RTRIM(DatabaseSchemaParentTriggerName), N'',
    td = RTRIM(ParentTypeDesc), N'',
    td = CreateDate
FROM #CreatedTriggers
ORDER BY CreateDate DESC
FOR XML PATH(N'tr'), ELEMENTS));
 
SET @Body = N'<html><head>
<style> * { font-family: Segoe UI, calibri } </style>
</head><body>
<H4>The following triggers have been created:</H4>
<p><table border="1" cellpadding="10"> 
<tr><th>Server  [Database].[Schema].[Parent].[Trigger]</th><th>ParentType</th><th>CreateDate</th></tr>'
  + @HTMLTableRows + N'</table></body></html>';

SET @SubjectText = @TargetServer + ':  Triggers - Created';

--See https://docs.sentryone.com/help/sp-sentry-dbmail-20 for a full list of available parameters
EXEC msdb.dbo.sp_sentry_dbmail_20	
     @body        = @Body,
     @body_format = N'HTML',
     @recipients  = N'YourEmail@GoesHere.com',--set your email address here
     @subject	  = @SubjectText

DROP TABLE #CreatedTriggers;
