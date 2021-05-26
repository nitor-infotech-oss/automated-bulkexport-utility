--To Enable BCP 

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO




--BCP Table data into CSV File

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SCHEMA].[BCP_SQL_Table]'))
DROP PROCEDURE [SCHEMA].[BCP_SQL_Table]  
GO

CREATE PROCEDURE [SCHEMA].[BCP_SQL_Table]  
@DBName VARCHAR(20),  
@HEADERFILEPath NVARCHAR(250),  
@DATAFILEPath NVARCHAR(250) 
  
  
AS  
BEGIN  
  
DECLARE @Table_name  NVARCHAR(50)  
  
SET @Table_name='SQL_TABLE_NAME'  
 
  
DECLARE @raw_sql NVARCHAR(MAX)  
  
DECLARE @columnHeader NVARCHAR(MAX)  
  

SELECT @columnHeader = COALESCE(@columnHeader+',' ,'')+ ''''+column_name +'''' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=@Table_name

--BCP only move data from table to CSV.
--first we have to get the header by using above query in @columnHeader move header name into one file @HEADERFILEPath
  
DECLARE @Query VARCHAR(8000)='bcp "SELECT '+@columnHeader+'" queryout '+@HEADERFILEPath+' -t"," -T -c -C RAW'  
  
exec master..xp_cmdshell @Query

--Now we move SCHEMA.SQL_TABLE_NAME data into file @DATAFILEPath  
  
SET @Query='bcp "select  * from '+@DBName+'.SCHEMA.SQL_TABLE_NAME" queryout '+@DATAFILEPath+' -t"," -T -c -C RAW'  
  
exec master..xp_cmdshell @Query  
 
--Copy Header + Data into one file @HEADERFILEPath.

SET @Query='COPY /b "'+@HEADERFILEPath+'" + "'+@DATAFILEPath+'" "'+@HEADERFILEPath+'"'  
  
Exec master..xp_cmdshell @Query  

  
END  
GO