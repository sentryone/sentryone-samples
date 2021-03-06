/*
This is an Execute SQL action for the 'Procedures - Modified' advisory condition.
For more information, see the following:
	https://www.sentryone.com/blog/using-sentryone-to-alert-on-sql-server-database-object-changes
	https://docs.sentryone.com/help/actions
Melissa Connors
Copyright 2020 SQL Sentry, LLC
*/
DECLARE @DatabaseName as nvarchar(128)
DECLARE @TargetServer as nvarchar(128)
DECLARE @SubjectText as nvarchar(255)
DECLARE @ModifieddDate as datetime

CREATE TABLE #ModifiedProcedures (
    DatabaseSchemaProcedureName nvarchar(400),
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
	  DECLARE @sqlProcedures nvarchar(max) = 
	  'INSERT INTO #ModifiedProcedures SELECT CONCAT (''' + QUOTENAME(@DatabaseName) +''',
	   ''.['', [s].[name],
	   ''].['', [p].[name], '']'') AS DatabaseSchemaProcedureName,
		[p].[modify_date] FROM ' + QUOTENAME(@DatabaseName) + '.sys.procedures p WITH (NOLOCK) 
		JOIN ' + QUOTENAME(@DatabaseName) + '.sys.schemas s WITH (NOLOCK) ON [s].[schema_id] = [p].[schema_id]
		WHERE [p].[modify_date] > (SELECT DATEADD(HH, -1, GETDATE()))
		AND [p].[modify_date] != [p].[create_date]' --set the DATEADD to match your evalulation frequency
	  EXEC sp_executesql @sqlProcedures
      FETCH NEXT FROM All_Databases_Cursor INTO @DatabaseName;  
   END;  
CLOSE All_Databases_Cursor;  
DEALLOCATE All_Databases_Cursor;  

SET @TargetServer = @@SERVERNAME

DECLARE @HTMLTableRows nvarchar(max), @Body nvarchar(max);
SELECT @HTMLTableRows = CONVERT(nvarchar(max), 
(SELECT td = @TargetServer + N'  ' + DatabaseSchemaProcedureName, N'',
    td = ModifyDate
FROM #ModifiedProcedures
ORDER BY ModifyDate DESC
FOR XML PATH(N'tr'), ELEMENTS));
 
SET @Body = N'<html><head>
<style> * { font-family: Segoe UI, calibri } </style>
</head><body>
<H4>The following procedures have been modified:</H4>
<p><table border="1" cellpadding="10"> 
<tr><th>Server  [Database].[Schema].[Procedure]</th><th>ModifyDate</th></tr>'
  + @HTMLTableRows + N'</table></body></html>';

SET @SubjectText = @TargetServer + ':  Stored Procedures - Modified';

--See https://docs.sentryone.com/help/sp-sentry-dbmail-20 for a full list of available parameters
EXEC msdb.dbo.sp_sentry_dbmail_20	
     @body        = @Body,
     @body_format = N'HTML',
     @recipients  = N'YourEmail@GoesHere.com',--set your email address here
     @subject	  = @SubjectText

DROP TABLE #ModifiedProcedures;
