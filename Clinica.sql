USE [master]
GO
/****** Object:  Database [ClinicaDev]    Script Date: 2020-07-06 11:54:44 ******/
CREATE DATABASE [ClinicaDev]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Clinica', FILENAME = N'C:\ClinicaData\Clinica.mdf' , SIZE = 1426304KB , MAXSIZE = UNLIMITED, FILEGROWTH = 2048KB )
 LOG ON 
( NAME = N'Clinica_log', FILENAME = N'C:\ClinicaData\Clinica_log.LDF' , SIZE = 768KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
GO
ALTER DATABASE [ClinicaDev] SET COMPATIBILITY_LEVEL = 90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ClinicaDev].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ClinicaDev] SET ANSI_NULL_DEFAULT ON 
GO
ALTER DATABASE [ClinicaDev] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ClinicaDev] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ClinicaDev] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ClinicaDev] SET ARITHABORT OFF 
GO
ALTER DATABASE [ClinicaDev] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [ClinicaDev] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [ClinicaDev] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [ClinicaDev] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ClinicaDev] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ClinicaDev] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ClinicaDev] SET CONCAT_NULL_YIELDS_NULL ON 
GO
ALTER DATABASE [ClinicaDev] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ClinicaDev] SET QUOTED_IDENTIFIER ON 
GO
ALTER DATABASE [ClinicaDev] SET RECURSIVE_TRIGGERS ON 
GO
ALTER DATABASE [ClinicaDev] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ClinicaDev] SET AUTO_UPDATE_STATISTICS_ASYNC ON 
GO
ALTER DATABASE [ClinicaDev] SET DATE_CORRELATION_OPTIMIZATION ON 
GO
ALTER DATABASE [ClinicaDev] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ClinicaDev] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ClinicaDev] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ClinicaDev] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [ClinicaDev] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ClinicaDev] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [ClinicaDev] SET  MULTI_USER 
GO
ALTER DATABASE [ClinicaDev] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ClinicaDev] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ClinicaDev] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ClinicaDev] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [ClinicaDev]
GO
/****** Object:  StoredProcedure [dbo].[cleanAllTables]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[cleanAllTables] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tablesDel varchar(MAX)
	SET @tablesDel = ''

	select @tablesDel = @tablesDel + 'DELETE FROM ' + table_name + ';'
from INFORMATION_SCHEMA.tables
where 
TABLE_TYPE = 'BASE TABLE' AND table_name NOT IN (SELECT TableName FROM ClinicaTables WHERE IsBase=1) 

DECLARE @TotalCount int
DECLARE @MinCount int
SET @MinCount=0

SELECT @TotalCount = dbo.fn_getTablesCount2()
SELECT @MinCount=SUM(Counted) FROM dbo.fn_getTablesCount() WHERE TableName IN (SELECT TableName FROM ClinicaTables WHERE IsBase=1)

exec sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'

DECLARE @maxloop int
SET @maxloop = 10
	WHILE @TotalCount>@MinCount AND @maxloop >0
	BEGIN
		EXEC(@tablesDel)
		SELECT @TotalCount=dbo.fn_getTablesCount2()
		SELECT @maxloop = @maxloop - 1
	END

exec sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
exec sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'

exec sp_MSforeachtable 'IF OBJECTPROPERTY(OBJECT_ID(''?''), ''TableHasIdentity'') = 1 BEGIN DBCC CHECKIDENT (''?'',RESEED,0) END'
END







GO
/****** Object:  StoredProcedure [dbo].[createBaseData]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[createBaseData] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--General preferences & folders
	INSERT Preferences (NoUser,Preferences) VALUES(null,'')
	INSERT INTO ContactFolders(NoUser,ContactFolder) VALUES(null,'')
	INSERT INTO DBFolders(NoUser,DBFolder) VALUES(null,'')
	INSERT INTO MailFolders(NoUser,MailFolder) VALUES(null,'')

	--Write default entries of some tables
	INSERT INTO FileTypes ([FileType],[NoBaseFileType],[Extensions],[IsInterne],[IsReadOnly],[IsHidden],[SearchInContent],[Printable], DBSelectable) SELECT [FileType],[NoBaseFileType],[Extensions],[IsInterne],[IsReadOnly],[IsHidden],[SearchInContent],[Printable], DBSelectable FROM FileTypesBase
	INSERT INTO [SpecialDates] ([Nom],[MaxYear],[Method],[Mois1],[Mois2],[Mois3],[Jour1],[Jour3],[Journee2],[Journee3],[Relative3],[Position2],[CodeVBNet]) SELECT [Nom],[MaxYear],[Method],[Mois1],[Mois2],[Mois3],[Jour1],[Jour3],[Journee2],[Journee3],[Relative3],[Position2],[CodeVBNet] FROM SpecialDatesBase
	INSERT INTO ModelesCategories (Categorie) SELECT Categorie FROM ModelesCategoriesBase

	--Add System user
	ALTER TABLE Utilisateurs DISABLE TRIGGER ALL
	SET IDENTITY_INSERT Utilisateurs ON
	INSERT INTO [dbo].[Utilisateurs]
			   (NoUser, [Cle]
			   ,[MDP]
			   ,[Nom]
			   ,[Prenom]
			   ,[NoType]
			   ,[URL]
			   ,[Adresse]
			   ,[NoVille]
			   ,[CodePostal]
			   ,[Telephones]
			   ,[Courriel]
			   ,[NoTitre]
			   ,[NoPermis]
			   ,[DateDebut]
			   ,[DateFin]
			   ,[NoTypeEmploye]
			   ,[Services]
			   ,[IsTherapist]
			   ,[DroitAcces]
			   ,[NotConfirmRVOnPasteOfDTRP])
		 VALUES
			   (0, ''
			   ,''
			   ,'Système'
			   ,''
			   ,null
			   ,''
			   ,''
			   ,null
			   ,''
			   ,''
			   ,''
			   ,null
			   ,''
			   ,'1900/01/01'
			   ,'1900/01/01'
			   ,1
			   ,''
			   ,0
			   ,''
			   ,0)
	SET IDENTITY_INSERT Utilisateurs OFF
	ALTER TABLE Utilisateurs ENABLE TRIGGER ALL
END
GO
/****** Object:  StoredProcedure [dbo].[ensureFTDatesOnPresence]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2009-07-01
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ensureFTDatesOnPresence]
	-- Add the parameters for the stored procedure here
	@NoFolder int,
	@Update bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	    -- Insert statements for procedure here
	DECLARE @NoUserAlert int
	DECLARE @Alarm varchar(MAX)
	DECLARE @NoFolderTexte int
	DECLARE @NbPresencesX int
	DECLARE @NbDaysX int
	DECLARE @NbDaysMultiple int
	DECLARE @NbDaysDiff int
	DECLARE @IsNbDaysDiffBefore int
	DECLARE @NbPresencesMultiple int
	DECLARE @FTDateStarted datetime
	DECLARE @RVDateStarted datetime
	DECLARE @AlertAffDate datetime
	DECLARE @AlertExpDate datetime
	DECLARE @AlertOldExpDate datetime
	DECLARE @AlertNbDaysForExpiry int
	DECLARE @AlertData as varchar(MAX)
	DECLARE @AlertMessage as varchar(MAX)
	DECLARE @Multiple bit
	DECLARE @NoMultiple int
	DECLARE @TypeForMultiple int
	DECLARE @WhenToBeCreated int
	DECLARE @PosVisite int
	DECLARE @TexteTitle varchar(MAX)
	DECLARE @MaxPosVisite int
	SET @MaxPosVisite=0
	SET @PosVisite = 0
	DECLARE @Multiplier int

	DECLARE my_cursor CURSOR LOCAL FOR
	SELECT NoFolderTexte FROM FolderTextes AS FT INNER JOIN FolderTexteTypes AS FTT ON FT.NoFolderTexteType=FTT.NoFolderTexteType WHERE NoFolder = @NoFolder AND ((FTT.WhenToBeCreated=2 AND FTT.TypeForMultiple<=1) OR (FTT.WhenToBeCreated<2 AND FTT.TypeForMultiple=1 AND FT.NoMultiple>1))
	OPEN my_cursor
	FETCH NEXT FROM my_cursor INTO @NoFolderTexte

	WHILE @@FETCH_STATUS = 0
	BEGIN
	SELECT @AlertOldExpDate=ExpDate,@AlertMessage=[Message],@AlertData=AlertData,@AlertNbDaysForExpiry=AlertNbDaysForExpiry,@NbDaysDiff=NbDaysDiff,@IsNbDaysDiffBefore=IsNbDaysDiffBefore,@NoUserAlert=UA.NoUserAlert,@Alarm=AlarmData,@TexteTitle=FT.TexteTitle,@WhenToBeCreated=WhenToBeCreated,@NbPresencesMultiple=NbPresencesMultiple,@NbDaysMultiple=NbDaysMultiple,@NoMultiple=NoMultiple,@TypeForMultiple=TypeForMultiple,@Multiple=Multiple,@NbPresencesX=NbPresencesX,@FTDateStarted=DateStarted,@NbDaysX=NbDaysX FROM  FolderTextes AS FT INNER JOIN FolderTexteTypes AS FTT ON FT.NoFolderTexteType=FTT.NoFolderTexteType LEFT JOIN FolderTexteAlerts AS FTA ON FTA.NoFolderTexte=FT.NoFolderTexte LEFT JOIN UsersAlerts AS UA ON UA.NoUserAlert=FTA.NoUserAlert WHERE FT.NoFolderTexte=@NoFolderTexte
	PRINT CAST(@NoFolderTexte AS varchar(MAX)) + ' - ' + @TexteTitle
	--GET RV DATE
	SET @PosVisite = @NbPresencesX
	IF @NoMultiple > 1 AND @TypeForMultiple=1
		SET @PosVisite = @NbPresencesX + (@NoMultiple-1)*@NbPresencesMultiple
	PRINT 'PosVisite : ' + CAST(@PosVisite AS varchar(max));
	WITH T AS (SELECT ROW_NUMBER() OVER(ORDER BY DateHeure) AS PosVisite,InfoVisites.* FROM InfoVisites WHERE NoFolder=@NoFolder AND NoStatut=4) SELECT @MaxPosVisite=(SELECT MAX(PosVisite) FROM t),@RVDateStarted=DATEADD(mi,DATEPART(mi,DateHeure)*-1,DATEADD(hh,DATEPART(hh,DateHeure)*-1,DateHeure)) FROM T WHERE PosVisite=@PosVisite

	IF @MaxPosVisite < @PosVisite
		SET @RVDateStarted = null

PRINT 'RV:' + CAST(@RVDateStarted AS nvarchar(30))

	IF @NoMultiple = 1
		SET @RVDateStarted = DATEADD(d, @NbDaysX, @RVDateStarted)

	--Adjust date if multiple created by a period of time
	IF @NoMultiple > 1 AND @TypeForMultiple=0
	BEGIN
		SELECT @RVDateStarted = DATEADD(d, (@NoMultiple-1) * @NbDaysMultiple,  DATEADD(d, @NbDaysX, @RVDateStarted))
	END
	
	print '@MaxPosVisite:' + CAST(@MaxPosVisite AS varchar(max))
	PRINT 'CurFT:' + CAST(@FTDateStarted AS nvarchar(30))
	PRINT 'NewFT:' + CAST(@RVDateStarted AS nvarchar(30))
	
	--Adjust alert if there was one
	IF NOT @NoUserAlert IS NULL
	BEGIN
		PRINT 'Shall update alert'
		SET @Multiplier = 1
		IF @IsNbDaysDiffBefore = 1
			SET @Multiplier = -1
		SELECT @AlertAffDate = DATEADD(d, @NbDaysDiff * @Multiplier, @RVDateStarted)
		IF @AlertAffDate> @RVDateStarted
			SET @AlertExpDate = @AlertAffDate
		ELSE
			SET @AlertExpDate = @RVDateStarted

		SELECT @AlertExpDate = DATEADD(d, @AlertNbDaysForExpiry + 1, @AlertExpDate)
		SELECT @AlertMessage = REPLACE(@AlertMessage,CAST(dbo.AffTextDate(DATEADD(d,-1,@AlertOldExpDate)) AS VARCHAR(10)),CAST(dbo.AffTextDate(DATEADD(d,-1,@AlertExpDate)) AS VARCHAR(10)))

		IF @Alarm <> ''
		BEGIN
			IF SUBSTRING(@Alarm,LEN(@Alarm)-3,4) = 'True'
			BEGIN
				SELECT @Alarm = CAST(dbo.AffTextDate(@AlertAffDate) AS VARCHAR(10))  + ':00:00:' + @AlertData + ':' + CAST(@NoFolder AS VARCHAR(MAX)) + ':True'
				PRINT 'Shall update alarm ==>' + @Alarm
			END
		END

		IF @Update = 1
			UPDATE UsersAlerts SET AffDate=@AlertAffDate,AlarmData=@Alarm,[Message]=@AlertMessage,ExpDate=@AlertExpDate WHERE NoUserAlert=@NoUserAlert
	END
	
	IF @Update = 1
		UPDATE FolderTextes SET DateStarted=@RVDateStarted WHERE NoFolderTexte=@NoFolderTexte

	PRINT ''
	FETCH NEXT FROM my_cursor INTO @NoFolderTexte
	END

	CLOSE my_cursor
	DEALLOCATE my_cursor
END

GO
/****** Object:  StoredProcedure [dbo].[getSubNoFactures]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonathan Boivin
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[getSubNoFactures] 
	-- Add the parameters for the stored procedure here
	@NoFacture int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    --SET @NoFactureRef = REPLACE(@NoFactureRef,'§',',')
    -- Insert statements for procedure here
--SELECT * FROM
DECLARE @CurNoFacture int
	SELECT DISTINCT NoFacture FROM StatFactures WHERE NoFactureTransfere = @NoFacture
DECLARE my_cursor CURSOR LOCAL FOR
SELECT NoFacture FROM StatFactures WHERE NoFactureTransfere = @NoFacture AND NoFactureRef<>''

OPEN my_cursor

FETCH NEXT FROM my_cursor INTO @CurNoFacture

WHILE @@FETCH_STATUS = 0
BEGIN
PRINT @CurNoFacture
EXEC('dbo.getSubNoFactures '+@CurNoFacture)
FETCH NEXT FROM my_cursor INTO @CurNoFacture
END

CLOSE my_cursor
DEALLOCATE my_cursor
	--SELECT dbo.getSubNoFactures(NoFacture) FROM StatFactures WHERE NoFactureTransfere= @NoFacture

    --EXEC('SELECT NoFacture FROM OPENQUERY(SQLEXPRESS, ''EXEC dbo.getSubNoFactures(NoFactureRef)'') WHERE NoFacture IN (' + @NoFactureRef + ') AND NoFactureRef <> ''''');

END

GO
/****** Object:  StoredProcedure [dbo].[getTablesCount]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[getTablesCount] 
AS
BEGIN
SELECT    OBJECT_NAME(object_id) as TableName,SUM (row_count) as Counted

FROM      sys.dm_db_partition_stats 

WHERE     index_id  <  2 

AND       OBJECTPROPERTY(object_id, 'IsUserTable')  =  1 AND OBJECT_NAME(object_id) NOT IN (SELECT TableName FROM ClinicaTables WHERE IsBase=1)

GROUP BY  object_id 
ORDER BY TableName
END






GO
/****** Object:  UserDefinedFunction [dbo].[AffTextDate]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2009-07-01
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[AffTextDate] 
(
	-- Add the parameters for the function here
	@TDate datetime
)
RETURNS varchar(35)
AS
BEGIN
    DECLARE @Return varchar(35)
	SELECT @Return = dbo.AffTextDate2(@TDate,0)
	RETURN @Return

END
GO
/****** Object:  UserDefinedFunction [dbo].[AffTextDate2]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2009-07-01
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[AffTextDate2] 
(
	-- Add the parameters for the function here
	@TDate datetime,
    @Format int = 0
)
RETURNS varchar(35)
AS
BEGIN
	IF @TDate IS null
		RETURN ''

	-- Declare the return variable here
	DECLARE @RDate varchar(35)

	-- Add the T-SQL statements to compute the return value here
    IF @Format = 0
		SELECT @RDate = CAST(YEAR(@TDate) AS VARCHAR(4)) + '/' + CASE WHEN MONTH(@TDate)<10 THEN '0' ELSE '' END + CAST(MONTH(@TDate) AS VARCHAR(2)) + '/' + CASE WHEN DAY(@TDate)<10 THEN '0' ELSE '' END + CAST(DAY(@TDate) AS VARCHAR(2)) + ' ' + CASE WHEN DATEPART(hour,@TDate)<10 THEN '0' ELSE '' END + CAST(DATEPART(hour,@TDate) AS VARCHAR(2)) + ':' +  + CASE WHEN DATEPART(minute,@TDate)<10 THEN '0' ELSE '' END + CAST(DATEPART(minute,@TDate) AS VARCHAR(2)) + ':' +  + CASE WHEN DATEPART(second,@TDate)<10 THEN '0' ELSE '' END + CAST(DATEPART(second,@TDate) AS VARCHAR(2))
    IF @Format = 1
		SELECT @RDate = dbo.getWeekDayName(@TDate) + ' ' + CAST(YEAR(@TDate) AS VARCHAR(4)) + '/' + CASE WHEN MONTH(@TDate)<10 THEN '0' ELSE '' END + CAST(MONTH(@TDate) AS VARCHAR(2)) + '/' + CASE WHEN DAY(@TDate)<10 THEN '0' ELSE '' END + CAST(DAY(@TDate) AS VARCHAR(2)) + ' ' + CASE WHEN DATEPART(hour,@TDate)<10 THEN '0' ELSE '' END + CAST(DATEPART(hour,@TDate) AS VARCHAR(2)) + ':' +  + CASE WHEN DATEPART(minute,@TDate)<10 THEN '0' ELSE '' END + CAST(DATEPART(minute,@TDate) AS VARCHAR(2)) + ':' +  + CASE WHEN DATEPART(second,@TDate)<10 THEN '0' ELSE '' END + CAST(DATEPART(second,@TDate) AS VARCHAR(2))


	-- Return the result of the function
	RETURN @RDate

END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_getAllNoFactures]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fn_getAllNoFactures] 
( @NoFacture int
)
RETURNS @return_variable TABLE (NoFacture int,NoFactureLinked int)
    BEGIN 
      WITH Bills (NoFacture,NoFactureLinked)
AS
(
-- Anchor member definition
SELECT NoFacture,NoFactureLinked FROM fn_getSubNoFactures((SELECT TOP 1 NoFacture FROM fn_getTopNoFactures(@NoFacture)))
)
-- Statement that executes the CTE
INSERT @return_variable
SELECT DISTINCT NoFacture, NoFactureLinked
FROM Bills ORDER BY NoFacture DESC

RETURN
    END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_getSubNoFactures]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fn_getSubNoFactures] 
( @NoFacture int
)
RETURNS @return_variable TABLE (NoFacture int,NoFactureLinked int)
    BEGIN	
      WITH Bills (NoFacture,NoFactureLinked)
AS
(
SELECT @NoFacture,0
UNION ALL
-- Recursive member definition
SELECT FacturesLinked.NoFactureLinked,0 FROM FacturesLinked INNER JOIN Bills ON FacturesLinked.NoFacture= Bills.NoFacture  --AND Bills.NoFacture<>@NoFacture
)
-- Statement that executes the CTE
INSERT @return_variable
SELECT DISTINCT NoFacture, NoFactureLinked
FROM Bills WHERE NoFactureLinked=0 ORDER BY NoFacture DESC

RETURN
    END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_getTablesCount2]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInteranutes
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fn_getTablesCount2]()
RETURNS int
AS
BEGIN
DECLARE @Total int
SET @Total=0
SELECT    @Total = @Total + SUM (row_count)

FROM      sys.dm_db_partition_stats 

WHERE     index_id  <  2 

AND       OBJECTPROPERTY(object_id, 'IsUserTable')  =  1

GROUP BY  object_id 

RETURN @Total
END


GO
/****** Object:  UserDefinedFunction [dbo].[fn_getTopNoFactures]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fn_getTopNoFactures] 
( @NoFacture int
)
RETURNS @return_variable TABLE (NoFacture int,NoFactureLinked int)
    BEGIN 
      WITH Bills (NoFacture,NoFactureLinked)
AS
(
SELECT @NoFacture,0
UNION ALL
-- Anchor member definition
SELECT NoFactureLinked,0 FROM FacturesLinked WHERE NoFactureLinked = @NoFacture
UNION ALL
-- Recursive member definition
SELECT FacturesLinked.NoFacture,FacturesLinked.NoFactureLinked FROM FacturesLinked INNER JOIN Bills ON FacturesLinked.NoFactureLinked = Bills.NoFacture
)
-- Statement that executes the CTE
INSERT @return_variable
SELECT DISTINCT NoFacture, NoFactureLinked
FROM Bills ORDER BY NoFacture DESC

RETURN
    END
GO
/****** Object:  UserDefinedFunction [dbo].[fnConvertUtf8]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnConvertUtf8]
(
	@Source VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF @Source NOT LIKE '%[ÂÃ]%'
		RETURN	@Source

	IF @Source NOT LIKE 'ï»¿%'
		RETURN @Source

	SELECT @Source = SUBSTRING(@Source, 4, LEN(@Source) - 3)
	SELECT @Source = REPLACE(REPLACE(@Source, 'Ã©', 'é'), 'Ã¢', 'â')

	RETURN @Source

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnConvertUtf8Ansi]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2013-06-11
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnConvertUtf8Ansi]
(
	@Source VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE	@Value SMALLINT = 255,
		@Utf8 CHAR(2),
		@Ansi CHAR(1)

	IF @Source NOT LIKE '%[ÂÃ]%'
		RETURN	@Source

	IF @Source LIKE 'ï»¿%'
		SELECT @Source = SUBSTRING(@Source, 4, LEN(@Source) - 3)

	WHILE @Value >= 160
		BEGIN
			SELECT	@Utf8 =	CASE
						WHEN @Value BETWEEN 160 AND 191 THEN CHAR(194) + CHAR(@Value)
						WHEN @Value BETWEEN 192 AND 255 THEN CHAR(195) + CHAR(@Value - 64)
						ELSE NULL
					END,
				@Ansi = CHAR(@Value)

			WHILE CHARINDEX(@Utf8, @Source) > 0
				SELECT	@Source = REPLACE(@Source, @Utf8, @Ansi)

			SET	@Value -= 1
		END

	RETURN	@Source
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetDBItemContent]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2013-06-11
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetDBItemContent] 
(
	-- Add the parameters for the function here
	@NoDBItem int
)
RETURNS varchar(MAX)
AS
BEGIN
	DECLARE @itemFileName VARCHAR(MAX)
	DECLARE @searchInContent BIT
	SELECT @itemFileName = DBItemFile, @searchInContent = SearchInContent FROM DBItems INNER JOIN FileTypes ON FileTypes.NoFileType = DBItems.NoFileType WHERE NoDBItem = @NoDBItem

	IF @itemFileName = '' OR @searchInContent = 0
		RETURN ''

	DECLARE @path VARCHAR(MAX)
	select @path = SUBSTRING(filename, 0, LEN(filename) - CHARINDEX('\', REVERSE(filename)) + 2) + 'DB'   from sysfiles where fileid=1

	-- Declare the return variable here
	DECLARE @Content varchar(MAX)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Content = [dbo].[fnReadFile](@path, @itemFileName)

	-- Return the result of the function
	RETURN @Content

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetDBItemMotsCles]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetDBItemMotsCles] 
(
	-- Add the parameters for the function here
	@NoDBItem int
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @MCList varchar(MAX)
	SET @MCList = ''

	-- Add the T-SQL statements to compute the return value here
	SELECT @MCList = @MCList + ' ' + MotCle FROM DBItemsMotsCles INNER JOIN DBMotsCles ON DBMotsCles.NoMotCle = DBItemsMotsCles.NoMotCle WHERE NoDBItem = @NoDBItem
	-- Return the result of the function

	IF (@MCList = '')
		SET @MCList = 'Aucun'
	ELSE
		SELECT @MCList = SUBSTRING(@MCList,2,LEN(@MCList)-1)
	
	RETURN @MCList

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFolderClosingDate]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2009-08-17
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetFolderClosingDate]
(
	-- Add the parameters for the function here
	@NoFolder int
)
RETURNS datetime
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NoStatClosing int
	DECLARE @NoStatOpening int
	DECLARE @ClosingDate datetime
	SET @NoStatClosing = 0

	SELECT TOP 1 @NoStatClosing=NoStat,@ClosingDate=DateHeureCreation FROM StatFolders WHERE NoAction=15 AND NoFolder=@NoFolder ORDER BY NoStat DESC
	SELECT TOP 1 @NoStatOpening=NoStat FROM StatFolders WHERE (NoAction=13 OR NoAction=14) AND NoFolder=@NoFolder ORDER BY NoStat DESC

	IF @NoStatOpening > @NoStatClosing
		RETURN null

	-- Return the result of the function
	RETURN @ClosingDate
END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFolderCodeId]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2013-05-21
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetFolderCodeId] 
(
	-- Add the parameters for the function here
	@noUnique int,
	@noUser int,
	@effectiveDate datetime
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = NoCodification FROM CodificationsDossiers 
	WHERE NoUnique = @noUnique AND 
	(@noUser = CodificationsDossiers.NoUser OR (@noUser IS NULL AND CodificationsDossiers.NoUser IS NULL)) AND
	(@effectiveDate >= CodificationsDossiers.firstEffectiveTime AND (CodificationsDossiers.lastEffectiveTime IS NULL OR @effectiveDate <= CodificationsDossiers.lastEffectiveTime)) 

	IF @Result IS NULL
		SELECT @Result = NoCodification FROM CodificationsDossiers 
		WHERE NoUnique = @noUnique AND 
		(CodificationsDossiers.NoUser IS NULL) AND
		(@effectiveDate >= CodificationsDossiers.firstEffectiveTime AND (CodificationsDossiers.lastEffectiveTime IS NULL OR @effectiveDate <= CodificationsDossiers.lastEffectiveTime)) 

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFolderFTs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2009-07-02
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetFolderFTs] 
(
	-- Add the parameters for the function here
	@NoFolder int
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Texte varchar(MAX)
	SET @Texte = ''

	-- Add the T-SQL statements to compute the return value here
	SELECT @Texte = @Texte + '<h2>' + TexteTitle + '</h2>' + CAST(Texte AS VARCHAR(MAX)) + '<br><br>' FROM FolderTextes WHERE NoFolder = @NoFolder AND CAST(Texte AS VARCHAR(1)) <> ''

	-- Return the result of the function
	RETURN @Texte

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFolderNoFTTs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2009-07-19
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetFolderNoFTTs] 
(
	-- Add the parameters for the function here
	@NoFolder int
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Texte varchar(MAX)
	SET @Texte = ''

	-- Add the T-SQL statements to compute the return value here
	SELECT @Texte = @Texte + CASE WHEN @Texte='' THEN '' ELSE ',' END + CAST(NoFolderTexteType AS VARCHAR(MAX)) FROM FolderTextes WHERE NoFolder = @NoFolder GROUP BY NoFolderTexteType

	-- Return the result of the function
	RETURN @Texte

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetFolderTextCodeUser]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2013-06-19
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetFolderTextCodeUser] 
(
	@noUnique int,
	@noUser int
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = noUser FROM CodesDossiersFolderTexteTypes T WHERE T.NoUser = @noUser AND T.NoUnique = @noUnique 

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetHtmlInputChecked]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		CyberInternautes Inc.
-- Create date: 2013-04-17
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetHtmlInputChecked] 
(
	-- Add the parameters for the function here
	@html varchar(MAX),
	@name varchar(MAX),
	@value varchar(MAX)
)
RETURNS bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result bit
	DECLARE @tempHtml varchar(MAX)
	DECLARE @pos bigint
	DECLARE @tempPos bigint

	-- Add the T-SQL statements to compute the return value here
	SELECT @pos = PATINDEX('% name=' + @name + '%', @html)

	IF @pos = 0
		SELECT @pos = PATINDEX('% name="' + @name + '"%', @html)

	IF @pos = 0
		SELECT @Result = 0
	ELSE
	BEGIN
		SELECT @tempPos = @pos - PATINDEX('%<%', REVERSE(SUBSTRING(@html, 0, @pos)))
		SELECT @tempHtml = SUBSTRING(@html, @pos, LEN(@html) - @pos)
		SELECT @pos = PATINDEX('%>%', @tempHtml) + @pos
		SELECT @tempHtml = SUBSTRING(@html, @tempPos, @pos - @tempPos)
		SELECT @tempPos = @pos + 1
		SELECT @pos = PATINDEX('% value=' + @value + '%', @tempHtml)

		IF @pos = 0
			SELECT @Result = dbo.fnGetHtmlInputChecked(SUBSTRING(@html, @tempPos, LEN(@html) - @tempPos), @name, @value)
		ELSE
		BEGIN
			SELECT @pos = PATINDEX('%CHECKED%', @tempHtml)
			SELECT @Result = @pos
		END
	END

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetHtmlSelectedOption]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc.
-- Create date: 203-04-17
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetHtmlSelectedOption] 
(
	-- Add the parameters for the function here
	@html varchar(MAX),
	@name varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
	IF @html IS NULL OR @html = ''
		RETURN ''

	-- Declare the return variable here
	DECLARE @Result varchar(MAX)
	DECLARE @pos bigint
	DECLARE @tempPos bigint

	-- Add the T-SQL statements to compute the return value here
	SELECT @pos = PATINDEX('% name=' + @name + '%', @html)

	IF @pos = 0
		SELECT @pos = PATINDEX('% name="' + @name + '"%', @html)

	IF @pos = 0
		SELECT @Result = ''
	ELSE
	BEGIN
		SELECT @Result = SUBSTRING(@html, @pos, LEN(@html) - @pos)
		SELECT @pos = PATINDEX('%>%', @Result) + 1
		SELECT @tempPos = PATINDEX('%</select>%', @Result)
		--Only OPTION tags
		SELECT @Result = SUBSTRING(@Result, @pos, @tempPos - @pos)
		SELECT @pos = PATINDEX('% selected%', @Result)
		IF @pos = 0
			SELECT @Result = ''
		ELSE
		BEGIN
			SELECT @pos = @pos - PATINDEX('%<%',REVERSE(SUBSTRING(@Result, 0, @pos)))
			--Only OPTION with selected attribute
			SELECT @Result = SUBSTRING(@Result, @pos, PATINDEX('%>%', SUBSTRING(@Result, @pos, LEN(@Result) - @pos)))
			SELECT @pos = PATINDEX('% value=%', @Result) + 7
			IF @pos = 7
				SELECT @Result = ''
			ELSE
			BEGIN
				SELECT @tempPos = PATINDEX('% %', SUBSTRING(@Result, @pos, LEN(@Result) - @pos))
				IF @tempPos = 0
					SELECT @tempPos = LEN(@Result)
				ELSE
					SELECT @tempPos = @tempPos + @pos
				SELECT @Result = SUBSTRING(@Result, @pos, @tempPos - @pos)
			END
		END
	END

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetHtmlTextarea]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc.
-- Create date: 2013-04-17
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetHtmlTextarea] 
(
	-- Add the parameters for the function here
	@html varchar(MAX),
	@name varchar(MAX)
)
RETURNS varchar(MAX)
AS
BEGIN
	IF @html IS NULL OR @html = ''
		RETURN ''

	-- Declare the return variable here
	DECLARE @Result varchar(MAX)
	DECLARE @pos bigint

	-- Add the T-SQL statements to compute the return value here
	SELECT @pos = PATINDEX('% name=' + @name + '%', @html)

	IF @pos = 0
		SELECT @pos = PATINDEX('% name="' + @name + '"%', @html)

	IF @pos = 0
		SELECT @Result = ''
	ELSE
	BEGIN
		SELECT @Result = SUBSTRING(@html, @pos, LEN(@html) - @pos)
		SELECT @pos = PATINDEX('%>%', @Result) + 1
		SELECT @Result = SUBSTRING(@Result, @pos, LEN(@Result) - @pos)
		SELECT @pos = PATINDEX('%<%', @Result)
		SELECT @Result = SUBSTRING(@Result, 0, @pos)
	END

	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetMonthPresencesString]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		CyberInternautes Inc.
-- Create date: 2013-04-17
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetMonthPresencesString] 
(
	-- Add the parameters for the function here
	@noFolder int,
	@year int,
	@month int
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(MAX)
	DECLARE @monthDays int
	DECLARE @i int
	DECLARE @noStatus int
	DECLARE @monthDate datetime

	SET @i = 1
	SELECT @Result= '', @monthDate = CAST(@year AS VARCHAR(4)) + '/' + CAST(@month AS VARCHAR(2)) + '/01'
	SELECT @monthDays = DATEPART(d, DATEADD(d, -1, DATEADD(month, 1, @monthDate)))

	WHILE @i <= @monthDays
	BEGIN
		SET @noStatus = null
		SELECT @monthDate = CAST(@year AS VARCHAR(4)) + '/' + CAST(@month AS VARCHAR(2)) + '/'  + CAST(@i AS VARCHAR(2))
		SELECT @noStatus = NoStatut FROM InfoVisites WHERE NoFolder = @noFolder AND DateHeure > @monthDate AND DateHeure < DATEADD(d, 1, @monthDate)
		IF @noStatus IS NULL OR @noStatus = 3
			SELECT @Result = @Result + '&nbsp;'
		ELSE
			SELECT @Result = @Result + CASE WHEN @noStatus = 4 THEN 'P' ELSE 'A' END
		SELECT @i = @i + 1
	END
	-- Return the result of the function
	RETURN @Result

END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetRVList]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetRVList] 
(
	-- Add the parameters for the function here
	@NoFolder int
)
RETURNS varchar(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @RVList varchar(MAX)
	SET @RVList = ''

	-- Add the T-SQL statements to compute the return value here
	SELECT @RVList = @RVList + '<br>' + CONVERT(varchar,DATEPART(year, DateHeure)) + '/' + CASE WHEN DATEPART(month, DateHeure) <10 THEN '0' + CONVERT(varchar,DATEPART(month, DateHeure)) ELSE CONVERT(varchar,DATEPART(month, DateHeure)) END + '/' + CASE WHEN DATEPART(day, DateHeure) <10 THEN '0' + CONVERT(varchar,DATEPART(day, DateHeure)) ELSE CONVERT(varchar,DATEPART(day, DateHeure)) END + ' ' + CASE WHEN DATENAME(hour, DateHeure)<10 THEN '0' + CONVERT(varchar,DATENAME(hour, DateHeure)) ELSE CONVERT(varchar,DATENAME(hour, DateHeure)) END + ':' + CASE WHEN DATENAME(minute, DateHeure)<10 THEN '0' + CONVERT(varchar,DATENAME(minute, DateHeure)) ELSE CONVERT(varchar,DATENAME(minute, DateHeure)) END FROM InfoVisites as IV5 WHERE NoFolder = @NoFolder AND DateHeure >= GETDATE()
	-- Return the result of the function

	SELECT @RVList=CASE WHEN LEN(@RVList) <4 THEN '' ELSE RIGHT(@RVList,LEN(@RVList)-4) END

	IF (@RVList = '')
		SET @RVList = 'Aucun'
	
	RETURN @RVList

END


GO
/****** Object:  UserDefinedFunction [dbo].[fnReadFile]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2013-06-11
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnReadFile] 
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS VARCHAR(MAX)

AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@String VARCHAR(8000),
		@Content VARCHAR(MAX),
		@YesOrNo INT

		SET @Content = ''

select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@path+'\'+@filename+'"',@command=@path+'\'+@filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='reading from the output file "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
	--INSERT INTO @file(line) SELECT @String
	SELECT @Content = @Content + @String + N'\n'
	END

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	--insert into @File(line) select @strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	SELECT @Content = [dbo].[fnConvertUtf8Ansi](@Content)

	RETURN @Content 
END

GO
/****** Object:  UserDefinedFunction [dbo].[GetDossierCurrentDemande]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2011/12/11
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetDossierCurrentDemande]
(
	@NoDossier int = 0
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NoDemande int
	DECLARE @IsDAActivated bit

	-- Add the T-SQL statements to compute the return value here
	SELECT TOP 1 @NoDemande = NoDemande FROM DemandesAuthorisations WHERE NoFolder = @NoDossier ORDER BY NoDemande DESC

	IF (@NoDemande IS NULL)
	BEGIN
		SELECT @IsDAActivated = DemandeAuthorisation FROM CodificationsDossiers INNER JOIN InfoFolders ON CodificationsDossiers.NoCodification = dbo.fnGetFolderCodeId(InfoFolders.NoCodeUnique, InfoFolders.NoCodeUser, InfoFolders.NoCodeDate) WHERE NoFolder = @NoDossier
		IF (@IsDAActivated = 1)
			RETURN 0
		
		RETURN -1
	END

	-- Return the result of the function
	RETURN @NoDemande

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetDossierCurrentDemandeStatut]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes Inc
-- Create date: 2011/12/11
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetDossierCurrentDemandeStatut]
(
	@NoDossier int = 0
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @NoAction int
	DECLARE @IsDAActivated bit

	-- Add the T-SQL statements to compute the return value here
	SELECT TOP 1 @NoAction = NoAction FROM DemandesAuthorisations WHERE NoFolder = @NoDossier ORDER BY NoDemande DESC

	IF (@NoAction IS NULL)
	BEGIN
		SELECT @IsDAActivated = DemandeAuthorisation FROM CodificationsDossiers INNER JOIN InfoFolders ON CodificationsDossiers.NoCodification = dbo.fnGetFolderCodeId(InfoFolders.NoCodeUnique, InfoFolders.NoCodeUser, InfoFolders.NoCodeDate) WHERE NoFolder = @NoDossier
		IF (@IsDAActivated = 1)
			RETURN 22
		
		RETURN 0
	END

	-- Return the result of the function
	RETURN @NoAction

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetLinkedBillMF]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonathan Boivin
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetLinkedBillMF] 
(
	-- Add the parameters for the function here
	@NoFacture int,
    @CurAmount money =0
)
RETURNS money
AS
BEGIN
	DECLARE @CurNoFacture int
    DECLARE @CA money
	SELECT @CA = SUM(MontantFacture) FROM StatFactures WHERE NoFactureTransfere = @NoFacture

	IF (@CA IS NOT NULL)
		SET @CurAmount = @CurAmount + @CA;

	DECLARE my_cursor CURSOR LOCAL FOR
	SELECT DISTINCT NoFacture FROM StatFactures WHERE NoFactureTransfere = @NoFacture AND NoFactureRef<>''

	OPEN my_cursor

	FETCH NEXT FROM my_cursor INTO @CurNoFacture

	WHILE @@FETCH_STATUS = 0
	BEGIN
	SELECT @CurAmount = dbo.GetLinkedBillMF(@CurNoFacture,@CurAmount)
	FETCH NEXT FROM my_cursor INTO @CurNoFacture
	END
	CLOSE my_cursor
	DEALLOCATE my_cursor

	RETURN @CurAmount
END



GO
/****** Object:  UserDefinedFunction [dbo].[GetLinkedBillMP]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonathan Boivin
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetLinkedBillMP] 
(
	-- Add the parameters for the function here
	@NoFacture int,
    @CurAmount money =0
)
RETURNS money
AS
BEGIN
	DECLARE @CurNoFacture int
    DECLARE @CA money
	SELECT @CA = SUM(MontantPaiement) FROM StatPaiements WHERE NoFacture IN (SELECT DISTINCT NoFacture FROM StatFactures WHERE NoFactureTransfere = @NoFacture)

	IF (@CA IS NOT NULL)
		SET @CurAmount = @CurAmount + @CA;

	DECLARE my_cursor CURSOR LOCAL FOR
	SELECT DISTINCT NoFacture FROM StatFactures WHERE NoFactureTransfere = @NoFacture AND NoFactureRef<>''

	OPEN my_cursor

	FETCH NEXT FROM my_cursor INTO @CurNoFacture

	WHILE @@FETCH_STATUS = 0
	BEGIN
	SELECT @CurAmount = dbo.GetLinkedBillMP(@CurNoFacture,@CurAmount)
	FETCH NEXT FROM my_cursor INTO @CurNoFacture
	END
	CLOSE my_cursor
	DEALLOCATE my_cursor

	RETURN @CurAmount
END




GO
/****** Object:  UserDefinedFunction [dbo].[getWeekDayName]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInternautes
-- Create date: 2010-02-22
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[getWeekDayName] 
(
	-- Add the parameters for the function here
	@TDate datetime
)
RETURNS varchar(20)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(20)
    DECLARE @wd int
    SELECT @wd = DATEPART(weekday,@TDate)

	-- Add the T-SQL statements to compute the return value here
    IF @wd = 1
		SELECT @Result = 'Dimanche'
    IF @wd = 2
        SELECT @Result = 'Lundi'
    IF @wd = 3
        SELECT @Result = 'Mardi'
    IF @wd = 4
        SELECT @Result = 'Mercredi'
    IF @wd = 5
        SELECT @Result = 'Jeudi'
    IF @wd = 6
        SELECT @Result = 'Vendredi'
    IF @wd = 7
        SELECT @Result = 'Samedi'

	-- Return the result of the function
	RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[uftReadfileAsTable]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create FUNCTION [dbo].[uftReadfileAsTable]
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS 
@File TABLE
(
[LineNo] int identity(1,1), 
line varchar(8000)) 

AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@String VARCHAR(8000),
		@YesOrNo INT

select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@path+'\'+@filename+'"',@command=@path+'\'+@filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='reading from the output file "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
	INSERT INTO @file(line) SELECT @String
	END

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	insert into @File(line) select @strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	RETURN 
END
GO
/****** Object:  UserDefinedFunction [dbo].[uftReadfileAsTable2]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[uftReadfileAsTable2]
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS VARCHAR(MAX)

AS
BEGIN

DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@String VARCHAR(8000),
		@Content VARCHAR(MAX),
		@YesOrNo INT

		SET @Content = ''

select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT


if @HR=0 Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@path+'\'+@filename+'"',@command=@path+'\'+@filename

if @HR=0 execute @hr = sp_OAMethod   @objFileSystem  , 'OpenTextFile'
	, @objTextStream OUT, @command,1,false,0--for reading, FormatASCII

WHILE @hr=0
	BEGIN
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='finding out if there is more to read in "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT

	IF @YesOrNo<>0  break
	if @HR=0 Select @objErrorObject=@objTextStream, 
		@strErrorMessage='reading from the output file "'+@filename+'"'
	if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
	--INSERT INTO @file(line) SELECT @String
	SELECT @Content = @Content + @String + N'\n'
	END

if @HR=0 Select @objErrorObject=@objTextStream, 
	@strErrorMessage='closing the output file "'+@filename+'"'
if @HR=0 execute @hr = sp_OAMethod  @objTextStream, 'Close'


if @hr<>0
	begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, 
		@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '
			+coalesce(@strErrorMessage,'doing something')
			+', '+coalesce(@Description,'')
	--insert into @File(line) select @strErrorMessage
	end
EXECUTE  sp_OADestroy @objTextStream
	-- Fill the table variable with the rows for your result set
	
	SELECT @Content = [dbo].[fnConvertUtf8Ansi](@Content)

	RETURN @Content 
END

GO
/****** Object:  Table [dbo].[AbsencesRaisons]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AbsencesRaisons](
	[NoRaison] [int] IDENTITY(1,1) NOT NULL,
	[Raison] [varchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_AbsencesRaisons] PRIMARY KEY CLUSTERED 
(
	[NoRaison] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Agenda]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Agenda](
	[NoAgenda] [int] IDENTITY(1,1) NOT NULL,
	[DateHeure] [datetime] NULL,
	[Periode] [int] NULL,
	[NoTRP] [int] NOT NULL,
	[Reserve] [varchar](max) NULL,
	[NoStatut] [int] NOT NULL CONSTRAINT [DF_Agenda_NoStatut]  DEFAULT ((6)),
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_Agenda] PRIMARY KEY CLUSTERED 
(
	[NoAgenda] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BaseFileTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BaseFileTypes](
	[NoBaseFileType] [int] NOT NULL,
	[BaseFileType] [varchar](max) NOT NULL,
 CONSTRAINT [PK_BaseFileTypes] PRIMARY KEY CLUSTERED 
(
	[NoBaseFileType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BrowserUrls]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BrowserUrls](
	[NoBrowserUrl] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[BrowserUrl] [varchar](max) NULL,
 CONSTRAINT [PK_BrowserUrls] PRIMARY KEY CLUSTERED 
(
	[NoBrowserUrl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClientsAntecedents]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientsAntecedents](
	[NoClient] [int] NOT NULL,
	[Antecedents] [text] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ClinicaTables]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicaTables](
	[TableName] [varchar](1000) NOT NULL,
	[IsBase] [bit] NOT NULL CONSTRAINT [DF_ClinicaTables_IsBase]  DEFAULT ((0)),
	[PrimaryKey] [varchar](1000) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ClinicaTablesLinked]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClinicaTablesLinked](
	[TableName] [varchar](255) NOT NULL,
	[TableNameLinked] [varchar](255) NOT NULL,
	[TableNameLinkedColumn] [varchar](255) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CodesDossiersCodes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CodesDossiersCodes](
	[NoCodeUnique] [int] NOT NULL,
	[CodeName] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_CodesDossiersCodes] PRIMARY KEY CLUSTERED 
(
	[NoCodeUnique] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CodesDossiersFolderAlertTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CodesDossiersFolderAlertTypes](
	[NoUnique] [int] NOT NULL,
	[NoFolderAlertType] [int] NOT NULL,
	[NoUser] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CodesDossiersFolderTexteTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CodesDossiersFolderTexteTypes](
	[NoUnique] [int] NOT NULL,
	[NoFolderTexteType] [int] NOT NULL,
	[NoUser] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CodesDossiersPeriodes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CodesDossiersPeriodes](
	[NoCDPeriode] [int] IDENTITY(1,1) NOT NULL,
	[NoCodification] [int] NOT NULL,
	[IsEval] [bit] NOT NULL,
	[NoPeriode] [int] NOT NULL,
	[Montant] [money] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[PourcentAbsence] [float] NULL,
	[PourcentClient] [float] NULL,
	[NoKP] [int] NULL,
 CONSTRAINT [PK_CodesDossiersPeriodes] PRIMARY KEY CLUSTERED 
(
	[NoCDPeriode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CodificationsDossiers]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CodificationsDossiers](
	[NoCodification] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL,
	[NoUnique] [int] NULL,
	[FirstEffectiveTime] [datetime] NOT NULL,
	[LastEffectiveTime] [datetime] NULL,
	[Recu] [bit] NOT NULL,
	[Paiement] [bit] NOT NULL,
	[MsgNoRef] [bit] NOT NULL,
	[MsgDiagnostic] [bit] NOT NULL,
	[DateAccidentActif] [bit] NOT NULL,
	[DateRechuteActif] [bit] NOT NULL,
	[AutoOpenPaiement] [bit] NOT NULL,
	[AffPourcentAllTimes] [bit] NOT NULL,
	[Confirmation] [tinyint] NOT NULL,
	[PonderationEval] [float] NOT NULL CONSTRAINT [DF_CodificationsDossiers_PonderationEval]  DEFAULT ((2)),
	[PonderationPresence] [float] NOT NULL CONSTRAINT [DF_CodificationsDossiers_PonderationVisite]  DEFAULT ((1)),
	[MethodePaiementDefaut] [varchar](max) NOT NULL CONSTRAINT [DF_CodificationsDossiers_MethodePaiementDefaut]  DEFAULT (''),
	[DemandeAuthorisation] [bit] NOT NULL CONSTRAINT [DF_CodificationsDossiers_DemandeAuthorisation]  DEFAULT ((0)),
	[NotConfirmRVOnPasteOfDTRP] [bit] NOT NULL CONSTRAINT [DF__Codificat__NotCo__64ECEE3F]  DEFAULT ((0)),
	[StartingExternalStatus] [int] NULL,
 CONSTRAINT [PK_CodificationsDossiers] PRIMARY KEY CLUSTERED 
(
	[NoCodification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CodificationsPayes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CodificationsPayes](
	[NoCodification] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL,
	[NoCategorie] [int] NULL,
 CONSTRAINT [PK_CodificationsPayes] PRIMARY KEY CLUSTERED 
(
	[NoCodification] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CommCategories]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CommCategories](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NULL,
 CONSTRAINT [PK_CommCategorie] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CommDeA]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommDeA](
	[NoDeA] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoKP] [int] NOT NULL,
 CONSTRAINT [PK_CommDeA] PRIMARY KEY CLUSTERED 
(
	[NoDeA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CommDeAKP]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommDeAKP](
	[NoDeA] [int] IDENTITY(1,1) NOT NULL,
	[NoKP] [int] NOT NULL,
	[NoKPDeA] [int] NOT NULL,
 CONSTRAINT [PK_CommDeAKP] PRIMARY KEY CLUSTERED 
(
	[NoDeA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CommSubjects]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CommSubjects](
	[NoCommSubject] [int] IDENTITY(1,1) NOT NULL,
	[CommSubject] [varchar](max) NOT NULL,
 CONSTRAINT [PK_CommSubjects] PRIMARY KEY CLUSTERED 
(
	[NoCommSubject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Communications]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Communications](
	[NoCommunication] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoKP] [int] NULL,
	[IsEnvoie] [bit] NULL,
	[NoCommSubject] [int] NULL,
	[CommDate] [datetime] NULL,
	[NoUser] [int] NOT NULL,
	[Remarques] [varchar](max) NULL,
	[NameOfFile] [varchar](max) NOT NULL CONSTRAINT [DF_Communications_NameOfFile]  DEFAULT (''),
	[NoFolder] [int] NOT NULL CONSTRAINT [DF_Communications_NoFolder]  DEFAULT ((0)),
	[NoCategorie] [int] NULL,
 CONSTRAINT [PK_Communications] PRIMARY KEY CLUSTERED 
(
	[NoCommunication] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CommunicationsKP]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CommunicationsKP](
	[NoCommunication] [int] IDENTITY(1,1) NOT NULL,
	[NoKP] [int] NOT NULL,
	[NoKPFrom] [int] NULL,
	[IsEnvoie] [bit] NULL,
	[NoCommSubject] [int] NULL,
	[CommDate] [datetime] NULL,
	[NoUser] [int] NOT NULL,
	[Remarques] [varchar](max) NULL,
	[NameOfFile] [varchar](max) NULL,
	[NoCategorie] [int] NULL,
 CONSTRAINT [PK_CommunicationsKP] PRIMARY KEY CLUSTERED 
(
	[NoCommunication] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContactFolders]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ContactFolders](
	[NoContactFolder] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL,
	[ContactFolder] [varchar](max) NOT NULL,
	[FolderProperties] [varchar](max) NULL CONSTRAINT [DF_ContactFolders_FolderProperties]  DEFAULT (''),
 CONSTRAINT [PK_ContactFolders] PRIMARY KEY CLUSTERED 
(
	[NoContactFolder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Contacts]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Contacts](
	[NoContact] [int] IDENTITY(1,1) NOT NULL,
	[NoContactFolder] [int] NOT NULL,
	[Nom] [varchar](max) NULL,
	[Prenom] [varchar](max) NULL,
	[Surnom] [varchar](max) NULL,
	[Afficher] [varchar](max) NULL,
	[Courriel] [varchar](max) NULL,
	[Courriels] [varchar](max) NULL,
	[TextMsgOnly] [bit] NOT NULL CONSTRAINT [DF_Contacts_TextMsgOnly]  DEFAULT ((0)),
	[Adresse] [varchar](max) NULL,
	[NoVille] [int] NULL,
	[CodePostal] [varchar](6) NULL,
	[NoPays] [int] NULL,
	[Telephones] [varchar](max) NULL,
	[URL] [varchar](max) NULL,
	[NoClient] [int] NULL,
	[NoKP] [int] NULL,
 CONSTRAINT [PK_Contacts] PRIMARY KEY CLUSTERED 
(
	[NoContact] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBFolders]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBFolders](
	[NoDBFolder] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL,
	[DBFolder] [varchar](max) NOT NULL,
	[FolderProperties] [varchar](max) NULL CONSTRAINT [DF_DBFolders_FolderProperties]  DEFAULT (''),
 CONSTRAINT [PK_DBFolders] PRIMARY KEY CLUSTERED 
(
	[NoDBFolder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBItems]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBItems](
	[NoDBItem] [int] IDENTITY(1,1) NOT NULL,
	[NoDBFolder] [int] NOT NULL,
	[DBItem] [varchar](max) NOT NULL,
	[DBItemFile] [varchar](max) NOT NULL,
	[NoFileType] [int] NOT NULL,
	[Description] [varchar](max) NULL,
	[IsHidden] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[LastModifDate] [datetime] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[UniqueNo] [int] NOT NULL,
	[SearchableContent] [varchar](max) NULL,
 CONSTRAINT [PK_DBItems] PRIMARY KEY CLUSTERED 
(
	[NoDBItem] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBItemsDroitsAcces]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBItemsDroitsAcces](
	[NoDBItem] [int] NOT NULL,
	[NoUser] [int] NULL,
	[NoTypeUser] [int] NULL,
	[IsAllowed] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DBItemsMotsCles]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBItemsMotsCles](
	[NoDBItem] [int] NOT NULL,
	[NoMotCle] [int] NOT NULL,
 CONSTRAINT [PK_DBItemsMotsCles] PRIMARY KEY CLUSTERED 
(
	[NoDBItem] ASC,
	[NoMotCle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DBMotsCles]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBMotsCles](
	[NoMotCle] [int] IDENTITY(1,1) NOT NULL,
	[MotCle] [varchar](max) NOT NULL,
 CONSTRAINT [PK_MotsCles] PRIMARY KEY CLUSTERED 
(
	[NoMotCle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBSearchList]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBSearchList](
	[NoDBSearchList] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[DBSearchListItem] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DBSearchList] PRIMARY KEY CLUSTERED 
(
	[NoDBSearchList] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DemandesAuthorisations]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DemandesAuthorisations](
	[NoDemande] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[NoAction] [int] NOT NULL,
	[NoUser] [int] NOT NULL,
	[Commentaires] [varchar](max) NOT NULL CONSTRAINT [DF_DemandesAuthorisations_Commentaires]  DEFAULT (''),
	[DateHeure] [datetime] NULL CONSTRAINT [DF_DemandesAuthorisations_DateHeure]  DEFAULT (getdate()),
	[NomAgent] [varchar](max) NOT NULL CONSTRAINT [DF_DemandesAuthorisations_NomAgent]  DEFAULT (''),
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_DemandesAuthorisations] PRIMARY KEY CLUSTERED 
(
	[NoDemande] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ECategorie]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ECategorie](
	[NoECategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_ECategorie] PRIMARY KEY CLUSTERED 
(
	[NoECategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employeurs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employeurs](
	[NoEmployeur] [int] IDENTITY(1,1) NOT NULL,
	[Employeur] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_Employeurs] PRIMARY KEY CLUSTERED 
(
	[NoEmployeur] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EntitesPayeurs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EntitesPayeurs](
	[NoEntitePayeur] [int] NOT NULL,
	[EntitePayeur] [char](1) NOT NULL,
	[Payeur] [varchar](max) NOT NULL,
 CONSTRAINT [PK_EntitesPayeurs] PRIMARY KEY CLUSTERED 
(
	[NoEntitePayeur] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Equipements]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Equipements](
	[NoEquipement] [int] IDENTITY(1,1) NOT NULL,
	[NomItem] [nvarchar](max) NOT NULL,
	[TypeItem] [int] NOT NULL,
	[NoECategorie] [int] NULL,
	[NoDesItems] [varchar](max) NOT NULL,
	[ItemPrete] [varchar](max) NOT NULL,
	[Depot] [money] NOT NULL,
	[RefundDepot] [float] NOT NULL CONSTRAINT [DF_Equipements_RefundDepot]  DEFAULT ((100)),
	[Cout] [money] NOT NULL,
	[CoutBy] [int] NOT NULL,
	[RefundCout] [float] NOT NULL CONSTRAINT [DF_Equipements_RefundCout]  DEFAULT ((0)),
	[Vente] [money] NOT NULL,
	[Achat] [money] NOT NULL,
	[ApplyTax] [bit] NOT NULL CONSTRAINT [DF_Equipements_ApplyTax]  DEFAULT ((1)),
	[Description] [varchar](max) NOT NULL,
	[NbVendu] [int] NOT NULL,
 CONSTRAINT [PK_Equipements] PRIMARY KEY CLUSTERED 
(
	[NoEquipement] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExternalStatuses]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExternalStatuses](
	[NoExternalStatus] [int] IDENTITY(1,1) NOT NULL,
	[ExternalStatus] [nvarchar](max) NOT NULL,
	[ExternalKey] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ExternalStatuses] PRIMARY KEY CLUSTERED 
(
	[NoExternalStatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Factures]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Factures](
	[NoFacture] [int] NOT NULL,
	[NoUser] [int] NOT NULL,
	[DateFacture] [datetime] NOT NULL,
	[NoFolder] [int] NULL,
	[NoClient] [int] NULL,
	[MontantFacture] [money] NOT NULL,
	[TypeFacture] [varchar](max) NOT NULL,
	[MontantPaiement] [money] NOT NULL,
	[Description] [varchar](max) NULL,
	[NoVisite] [int] NULL,
	[NoPret] [int] NULL,
	[NoFactureRef] [varchar](max) NULL,
	[NoVente] [int] NULL,
	[Taxe1] [real] NOT NULL,
	[Taxe2] [real] NOT NULL,
	[NoKP] [int] NULL,
	[NoUserFacture] [int] NULL,
	[ParNoKP] [int] NULL,
	[ParNoClient] [int] NULL,
	[ParNoUser] [int] NULL,
	[MontantFactureKP] [money] NOT NULL CONSTRAINT [DF_Factures_MontantFactureKP]  DEFAULT ((0)),
	[MontantFactureUser] [money] NOT NULL CONSTRAINT [DF_Factures_MontantFactureUser]  DEFAULT ((0)),
	[MontantFactureClinique] [money] NOT NULL CONSTRAINT [DF_Factures_MontantFactureClinique]  DEFAULT ((0)),
	[NoFactureTransfere] [int] NULL,
	[MontantPaiementKP] [money] NOT NULL CONSTRAINT [DF_Factures_MontantPaiementKP]  DEFAULT ((0)),
	[MontantPaiementUser] [money] NOT NULL CONSTRAINT [DF_Factures_MontantPaiementUser]  DEFAULT ((0)),
	[MontantPaiementClinique] [money] NOT NULL CONSTRAINT [DF_Factures_MontantPaiementClinique]  DEFAULT ((0)),
	[ParNoClinique] [int] NULL,
	[IsSouffrance] [bit] NOT NULL CONSTRAINT [DF_Factures_IsSouffrance]  DEFAULT ((0)),
	[TaxesApplication] [int] NULL,
 CONSTRAINT [PK_Factures] PRIMARY KEY CLUSTERED 
(
	[NoFacture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FacturesLinked]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FacturesLinked](
	[NoFacture] [int] NOT NULL,
	[NoFactureLinked] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FacturesNumbers]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FacturesNumbers](
	[NoFacture] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
 CONSTRAINT [PK_FacturesNumbers] PRIMARY KEY CLUSTERED 
(
	[NoFacture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FacturesRecusLeft]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FacturesRecusLeft](
	[NoStat] [int] NOT NULL,
	[NoFacture] [int] NOT NULL,
	[NoEntitePayeur] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FileTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileTypes](
	[NoFileType] [int] IDENTITY(1,1) NOT NULL,
	[FileType] [varchar](max) NOT NULL,
	[NoBaseFileType] [int] NOT NULL,
	[Extensions] [varchar](max) NOT NULL,
	[IsInterne] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[IsHidden] [bit] NOT NULL,
	[SearchInContent] [bit] NOT NULL,
	[Printable] [bit] NOT NULL,
	[DBSelectable] [bit] NOT NULL,
 CONSTRAINT [PK_FileTypes] PRIMARY KEY CLUSTERED 
(
	[NoFileType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FileTypesBase]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileTypesBase](
	[NoFileType] [int] IDENTITY(1,1) NOT NULL,
	[FileType] [varchar](max) NOT NULL,
	[NoBaseFileType] [int] NOT NULL,
	[Extensions] [varchar](max) NOT NULL,
	[IsInterne] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[IsHidden] [bit] NOT NULL,
	[SearchInContent] [bit] NOT NULL,
	[Printable] [bit] NOT NULL,
	[DBSelectable] [bit] NOT NULL,
 CONSTRAINT [PK_FileTypesBase] PRIMARY KEY CLUSTERED 
(
	[NoFileType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FileTypesDroitsAcces]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileTypesDroitsAcces](
	[NoFileType] [int] NOT NULL,
	[NoTypeUser] [int] NULL,
	[IsAllowed] [int] NOT NULL,
	[NoUser] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FinMoisTypesRapports]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinMoisTypesRapports](
	[NoRapportType] [int] NOT NULL,
	[NoClinique] [int] NOT NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_FinMoisTypesRapports] PRIMARY KEY CLUSTERED 
(
	[NoRapportType] ASC,
	[NoClinique] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FolderAlerts]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FolderAlerts](
	[NoFolder] [int] NOT NULL,
	[NoFolderAlertType] [int] NOT NULL,
	[LastNoUserAlert] [int] NOT NULL,
	[IsAlertDone] [bit] NOT NULL,
 CONSTRAINT [PK_FolderAlerts] PRIMARY KEY CLUSTERED 
(
	[NoFolder] ASC,
	[NoFolderAlertType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FolderAlertTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FolderAlertTypes](
	[NoFolderAlertType] [int] IDENTITY(1,1) NOT NULL,
	[TypeDateDebut] [int] NOT NULL,
	[DateDebutNbPresencesX] [int] NOT NULL,
	[DateDebutNbDaysX] [int] NOT NULL,
	[NbPresencesX] [int] NOT NULL,
	[AlertMessage] [varchar](max) NOT NULL,
	[AlertTitle] [varchar](max) NOT NULL,
	[AlertNbDaysDiff] [int] NOT NULL,
	[AlertNbPresencesDiff] [int] NOT NULL,
	[AlertNbDaysForExpiry] [int] NOT NULL,
 CONSTRAINT [PK_FolderAlertTypes] PRIMARY KEY CLUSTERED 
(
	[NoFolderAlertType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FolderTexteAlerts]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FolderTexteAlerts](
	[NoFolderTexte] [int] NOT NULL,
	[NoUserAlert] [int] NOT NULL,
 CONSTRAINT [PK_FolderTexteAlerts] PRIMARY KEY CLUSTERED 
(
	[NoFolderTexte] ASC,
	[NoUserAlert] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[FolderTextes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FolderTextes](
	[NoFolderTexte] [int] IDENTITY(1,1) NOT NULL,
	[NoFolderTexteType] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[TexteTitle] [varchar](max) NOT NULL,
	[DateStarted] [datetime] NOT NULL,
	[DateFinished] [datetime] NULL,
	[Texte] [text] NOT NULL CONSTRAINT [DF_FolderTextes_Texte]  DEFAULT (''),
	[TextePos] [varchar](max) NOT NULL CONSTRAINT [DF_FolderTextes_TextePos]  DEFAULT ((-1)),
	[NoMultiple] [int] NULL,
	[IsTexte] [bit] NOT NULL CONSTRAINT [DF__FolderTex__IsTex__0856260D]  DEFAULT ((0)),
	[ExternalStatus] [int] NULL,
 CONSTRAINT [PK_FolderRapports] PRIMARY KEY CLUSTERED 
(
	[NoFolderTexte] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FolderTextesFuturs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FolderTextesFuturs](
	[NoFolderTexteFutur] [int] IDENTITY(1,1) NOT NULL,
	[NoFolderTexteType] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[TexteTitle] [varchar](max) NOT NULL,
	[DateStarted] [datetime] NOT NULL,
 CONSTRAINT [PK_FolderTextesFuturs] PRIMARY KEY CLUSTERED 
(
	[NoFolderTexteFutur] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FolderTexteTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FolderTexteTypes](
	[NoFolderTexteType] [int] IDENTITY(1,1) NOT NULL,
	[NoModeleCategorie] [int] NOT NULL,
	[Position] [int] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[ResetTextOnCopy] [bit] NOT NULL,
	[TexteTitle] [varchar](max) NOT NULL,
	[CopyTextToOtherText] [int] NOT NULL,
	[WhenToBeCreated] [tinyint] NOT NULL,
	[NbDaysX] [int] NOT NULL,
	[NbPresencesX] [int] NOT NULL,
	[Multiple] [bit] NOT NULL CONSTRAINT [DF_FolderRapportTypes_Multiple]  DEFAULT ((0)),
	[TypeForMultiple] [tinyint] NOT NULL,
	[NbDaysMultiple] [int] NOT NULL,
	[NbPresencesMultiple] [int] NOT NULL,
	[NbMultipleEnding] [int] NOT NULL,
	[WhenToBeStopped] [tinyint] NOT NULL,
	[IsNbDaysDiffBefore] [bit] NOT NULL,
	[NbDaysDiff] [int] NOT NULL,
	[ShowAlert] [bit] NOT NULL,
	[ShowAlarm] [bit] NOT NULL,
	[AlertNbDaysForExpiry] [int] NOT NULL,
	[AlertMessageArticle] [varchar](5) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[StartingExternalStatus] [int] NULL,
	[ModelAppliedOnCreation] [int] NULL,
	[TerminatedOnCreation] [bit] NULL,
 CONSTRAINT [PK_FolderRapportTypes] PRIMARY KEY CLUSTERED 
(
	[NoFolderTexteType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Horaires]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Horaires](
	[NoHoraire] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL,
	[DateHoraire] [datetime] NULL,
	[IntervalMinutes] [int] NOT NULL CONSTRAINT [DF_Horaires_IntervalMinutes]  DEFAULT ((15)),
	[OpenedMinutes] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Horaires] PRIMARY KEY CLUSTERED 
(
	[NoHoraire] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InfoClients]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InfoClients](
	[NoClient] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[Nom] [nvarchar](max) NULL,
	[Prenom] [nvarchar](max) NULL,
	[Adresse] [nvarchar](max) NULL,
	[NoVille] [int] NULL,
	[CodePostal] [nvarchar](6) NULL,
	[Telephones] [varchar](max) NULL,
	[AutreNom] [nvarchar](max) NULL,
	[DateNaissance] [datetime] NULL,
	[SexeHomme] [bit] NULL,
	[NoEmployeur] [int] NULL,
	[NoMetier] [int] NULL,
	[NAM] [nvarchar](12) NULL,
	[NomReferent] [nvarchar](max) NULL,
	[Courriel] [nvarchar](max) NULL,
	[URL] [varchar](max) NULL,
	[Photo] [image] NULL,
	[Description] [varchar](max) NULL,
	[DateHeureCreation] [datetime] NOT NULL,
	[Publipostage] [smallint] NULL,
 CONSTRAINT [PK_InfoClients] PRIMARY KEY CLUSTERED 
(
	[NoClient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InfoClinique]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InfoClinique](
	[NoClinique] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [nvarchar](max) NULL,
	[Adresse] [nvarchar](max) NULL,
	[NoVille] [int] NULL,
	[CodePostal] [nvarchar](6) NULL,
	[Telephone] [nvarchar](max) NULL,
	[Fax] [nvarchar](max) NULL,
	[NoEtablissement] [nvarchar](max) NULL,
	[NoTaxe1] [nvarchar](max) NULL,
	[NoTaxe2] [nvarchar](max) NULL,
	[Courriel] [varchar](max) NULL,
	[URL] [varchar](max) NULL,
	[NoDAS] [nvarchar](max) NULL,
	[NEQ] [nvarchar](max) NULL,
	[FinMoisDBPath] [varchar](max) NOT NULL CONSTRAINT [DF_InfoClinique_FinMoisDBPath]  DEFAULT (''),
	[NoDAS2] [varchar](50) NULL,
	[LogoURL] [varchar](max) NULL,
 CONSTRAINT [PK_InfoClinique] PRIMARY KEY CLUSTERED 
(
	[NoClinique] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InfoFolders]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InfoFolders](
	[NoFolder] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoCodeUnique] [int] NOT NULL,
	[NoCodeUser] [int] NULL,
	[NoCodeDate] [datetime] NOT NULL,
	[NoTRPTraitant] [int] NOT NULL,
	[NoTRPDemande] [int] NULL,
	[NoTRPToTransfer] [int] NULL,
	[StatutOuvert] [bit] NOT NULL,
	[Service] [nvarchar](max) NOT NULL,
	[Remarques] [varchar](max) NOT NULL,
	[Diagnostic] [nvarchar](max) NOT NULL,
	[NoSiteLesion] [int] NULL,
	[NoKP] [int] NULL,
	[NoRef] [varchar](max) NOT NULL,
	[DateRef] [datetime] NULL,
	[DateAccident] [datetime] NULL,
	[DateRechute] [datetime] NULL,
	[Duree] [int] NOT NULL CONSTRAINT [DF_InfoFolders_Duree]  DEFAULT ((0)),
	[Frequence] [int] NOT NULL,
	[NbVisiteHavingCAR] [int] NOT NULL CONSTRAINT [DF_InfoFolders_NbVisiteHavingCAR]  DEFAULT ((0)),
	[OldiestCAR] [datetime] NULL,
	[Flagged] [bit] NOT NULL CONSTRAINT [DF_InfoFolders_Flagged]  DEFAULT ((0)),
	[DateReceptionRef] [datetime] NULL,
	[ExternalStatus] [int] NULL,
 CONSTRAINT [PK_InfoFolders] PRIMARY KEY CLUSTERED 
(
	[NoFolder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InfoLogicielDivers]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InfoLogicielDivers](
	[DateFirstUsage] [datetime] NULL,
	[CheminTextBox1] [varchar](max) NULL,
	[CheminImporterDB] [varchar](max) NULL,
	[CheminImporterComm] [varchar](max) NULL,
	[LastUniqueNo] [int] NULL,
	[TriggerSoftPath] [varchar](max) NULL,
	[NoTrigger] [int] NULL,
	[CheminImporterPhoto] [varchar](max) NULL,
	[LastNoFacture] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[InfoVisites]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InfoVisites](
	[NoVisite] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[NoStatut] [int] NOT NULL,
	[NoFacture] [int] NULL,
	[NoTRP] [int] NOT NULL,
	[DateHeure] [datetime] NOT NULL,
	[Periode] [int] NOT NULL,
	[Service] [nvarchar](max) NOT NULL,
	[Confirmed] [bit] NOT NULL CONSTRAINT [DF_InfoVisites_Confirmed]  DEFAULT ((0)),
	[Evaluation] [bit] NOT NULL,
	[Flagged] [bit] NOT NULL CONSTRAINT [DF_InfoVisites_Flagged]  DEFAULT ((0)),
	[IsOnAgenda] [bit] NOT NULL CONSTRAINT [DF_InfoVisites_IsOnAgenda]  DEFAULT ((1)),
	[Remarques] [varchar](max) NULL,
	[IsAnnounced] [bit] NOT NULL CONSTRAINT [DF__InfoVisit__IsAnn__28A2FA0E]  DEFAULT ((0)),
	[ExternalStatus] [int] NULL,
 CONSTRAINT [PK_InfoVisites] PRIMARY KEY CLUSTERED 
(
	[NoVisite] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KeyPeople]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KeyPeople](
	[NoKP] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [nvarchar](max) NOT NULL,
	[NoCategorie] [int] NULL,
	[Adresse] [nvarchar](max) NULL,
	[NoVille] [int] NULL,
	[CodePostal] [nvarchar](6) NULL,
	[Telephones] [varchar](max) NULL,
	[NoRef] [nvarchar](max) NULL,
	[Courriel] [nvarchar](max) NULL,
	[URL] [varchar](max) NULL,
	[NoClient] [int] NULL,
	[AutreInfos] [varchar](max) NULL,
	[NoEmployeur] [int] NULL,
	[NoUser] [int] NOT NULL,
	[DateHeureCreation] [datetime] NOT NULL,
	[WorkPlace] [nvarchar](255) NULL,
	[Publipostage] [tinyint] NULL,
 CONSTRAINT [PK_KeyPeople] PRIMARY KEY CLUSTERED 
(
	[NoKP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KPCategorie]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KPCategorie](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_KPCategorie] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KPSearchList]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KPSearchList](
	[NoKPSearchList] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[KPSearchListItem] [varchar](max) NOT NULL,
 CONSTRAINT [PK_KPSearchList] PRIMARY KEY CLUSTERED 
(
	[NoKPSearchList] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ListeAction]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListeAction](
	[NoAction] [int] NOT NULL,
	[NomAction] [nvarchar](100) NULL,
 CONSTRAINT [PK_ListeAction] PRIMARY KEY CLUSTERED 
(
	[NoAction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ListeAttente]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListeAttente](
	[NoQL] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoFolder] [int] NULL,
	[NoVisite] [int] NULL,
	[NoTRP] [int] NOT NULL,
	[Remarques] [varchar](max) NOT NULL CONSTRAINT [DF_ListeAttente_Remarques]  DEFAULT (''),
	[DateAppel] [datetime] NOT NULL,
	[Disponibilites] [varchar](100) NULL,
	[Periode] [nvarchar](max) NOT NULL,
	[NoCodeUnique] [int] NOT NULL,
	[NoCodeUser] [int] NULL,
	[Service] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_ListeAttente] PRIMARY KEY CLUSTERED 
(
	[NoQL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ListeMontantRembourse]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListeMontantRembourse](
	[MontantRembourse] [nvarchar](1) NOT NULL,
	[NomMontantRembourse] [nvarchar](50) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_ListeMontantRembourse] PRIMARY KEY CLUSTERED 
(
	[MontantRembourse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ListeNoRecus]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListeNoRecus](
	[NoNoRecu] [int] IDENTITY(1,1) NOT NULL,
	[NoRecu] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ListeNoRecus] PRIMARY KEY CLUSTERED 
(
	[NoNoRecu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ListePeriode]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListePeriode](
	[NoPeriode] [int] IDENTITY(1,1) NOT NULL,
	[Periode] [varchar](50) NOT NULL,
	[TotalMinutes] [int] NULL,
 CONSTRAINT [PK_ListePeriode] PRIMARY KEY CLUSTERED 
(
	[NoPeriode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ListeRepetition]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListeRepetition](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ListeRepetition] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ListeStatut]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListeStatut](
	[NoStatut] [int] IDENTITY(1,1) NOT NULL,
	[NomStatut] [nvarchar](50) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_ListeStatut] PRIMARY KEY CLUSTERED 
(
	[NoStatut] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ListeTypeEmploye]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ListeTypeEmploye](
	[NoTypeEmploye] [int] IDENTITY(1,1) NOT NULL,
	[TypeEmploye] [nvarchar](50) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_ListeTypeEmploye] PRIMARY KEY CLUSTERED 
(
	[NoTypeEmploye] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ListeTypeItem]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListeTypeItem](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ListeTypeItem] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ListeTypesPayeurs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ListeTypesPayeurs](
	[TypePayeur] [char](1) NOT NULL,
	[Nom] [varchar](500) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailAccounts]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailAccounts](
	[NoMailAccount] [int] IDENTITY(1,1) NOT NULL,
	[AccountName] [varchar](max) NOT NULL,
	[SendingName] [varchar](max) NOT NULL,
	[Email] [varchar](max) NOT NULL,
	[POPServer] [varchar](max) NOT NULL,
	[POPPort] [int] NOT NULL,
	[POPSecured] [bit] NOT NULL,
	[SMTPServer] [varchar](max) NOT NULL,
	[SMTPPort] [int] NOT NULL,
	[SMTPSecured] [bit] NOT NULL,
	[SMTPNeedAuthen] [bit] NOT NULL,
	[SMTPSpecificCredential] [bit] NOT NULL,
	[SMTPAuthenUsername] [varchar](max) NOT NULL,
	[SMTPPassword] [varchar](max) NOT NULL,
	[SMTPPasswordKey] [varchar](max) NOT NULL,
	[SMTPSavePassword] [bit] NOT NULL,
	[Username] [varchar](max) NOT NULL,
	[PasswordKey] [varchar](max) NOT NULL,
	[Password] [varchar](max) NOT NULL,
	[SavePassword] [bit] NOT NULL,
	[KeepMSGOnServer] [bit] NOT NULL,
	[IncludeInGeneralReception] [bit] NOT NULL,
	[CommonAccount] [bit] NOT NULL,
	[InboxFolderName] [varchar](max) NOT NULL,
	[IncomingProtocol] [int] NOT NULL,
	[TimeoutInSeconds] [int] NOT NULL,
	[CanSendEmail] [bit] NULL CONSTRAINT [DF_MailAccounts_CanSendEmail]  DEFAULT ((1)),
 CONSTRAINT [PK_MailAccounts] PRIMARY KEY CLUSTERED 
(
	[NoMailAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MailFolders]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MailFolders](
	[NoMailFolder] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL CONSTRAINT [DF_MailFolders_NoUser]  DEFAULT ((0)),
	[MailFolder] [varchar](max) NOT NULL,
	[FolderProperties] [varchar](max) NULL CONSTRAINT [DF_MailFolders_FolderProperties]  DEFAULT (''),
 CONSTRAINT [PK_MailFolders] PRIMARY KEY CLUSTERED 
(
	[NoMailFolder] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Mails]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Mails](
	[NoMail] [int] IDENTITY(1,1) NOT NULL,
	[NoMailFolder] [int] NOT NULL,
	[From] [varchar](max) NULL,
	[To] [varchar](max) NULL,
	[CC] [varchar](max) NULL,
	[NoUserFrom] [int] NULL,
	[NoUserTo] [int] NULL,
	[AffDate] [datetime] NULL,
	[NoClient] [int] NULL CONSTRAINT [DF_Mails_NoClient]  DEFAULT ((0)),
	[Subject] [varchar](max) NOT NULL,
	[IsRead] [bit] NOT NULL CONSTRAINT [DF_Mails_IsRead]  DEFAULT ((0)),
	[Message] [ntext] NOT NULL CONSTRAINT [DF_Mails_Message]  DEFAULT (''),
	[FilesAttached] [text] NOT NULL CONSTRAINT [DF_Mails_FilesAttached]  DEFAULT (''),
	[HasSentFeedBack] [bit] NOT NULL CONSTRAINT [DF_Mails_HasSentFeedBack]  DEFAULT ((0)),
	[Source] [text] NULL,
	[POPServer] [varchar](max) NULL,
	[ServerIdent] [varchar](max) NULL,
	[POPUser] [varchar](max) NULL,
 CONSTRAINT [PK_Mails] PRIMARY KEY CLUSTERED 
(
	[NoMail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Metiers]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Metiers](
	[NoMetier] [int] IDENTITY(1,1) NOT NULL,
	[Metier] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_Metiers] PRIMARY KEY CLUSTERED 
(
	[NoMetier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Modeles]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Modeles](
	[NoModele] [int] IDENTITY(1,1) NOT NULL,
	[NoCategorie] [int] NOT NULL,
	[NoUser] [int] NULL CONSTRAINT [DF_Modeles_NoUser]  DEFAULT ((0)),
	[Nom] [varchar](max) NOT NULL,
	[Modele] [text] NOT NULL,
 CONSTRAINT [PK_Modeles] PRIMARY KEY CLUSTERED 
(
	[NoModele] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ModelesCategories]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelesCategories](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ModelesCategories] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ModelesCategoriesBase]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ModelesCategoriesBase](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [varchar](max) NOT NULL,
 CONSTRAINT [PK_ModelesCategoriesBase] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NotesTitles]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NotesTitles](
	[NoNotesTitles] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[Titles] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_NotesTitles] PRIMARY KEY CLUSTERED 
(
	[NoNotesTitles] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PayeCategorie]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayeCategorie](
	[NoCategorie] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_PayeCategorie] PRIMARY KEY CLUSTERED 
(
	[NoCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PayesUtilisateurs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayesUtilisateurs](
	[NoUser] [int] NOT NULL,
	[DatePaie] [datetime] NOT NULL,
	[Multiplicateur] [float] NULL,
	[DiNb] [money] NULL,
	[LuNb] [money] NULL,
	[MaNb] [money] NULL,
	[MeNb] [money] NULL,
	[JeNb] [money] NULL,
	[VeNb] [money] NULL,
	[SaNb] [money] NULL,
	[DiMontantFixe] [money] NULL,
	[LuMontantFixe] [money] NULL,
	[MaMontantFixe] [money] NULL,
	[MeMontantFixe] [money] NULL,
	[JeMontantFixe] [money] NULL,
	[VeMontantFixe] [money] NULL,
	[SaMontantFixe] [money] NULL,
	[Type] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_PayesUtilisateurs] PRIMARY KEY CLUSTERED 
(
	[NoUser] ASC,
	[DatePaie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Pays]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Pays](
	[NoPays] [int] IDENTITY(1,1) NOT NULL,
	[Pays] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Pays] PRIMARY KEY CLUSTERED 
(
	[NoPays] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Preferences]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Preferences](
	[NoPref] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NULL,
	[Preferences] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Preferences] PRIMARY KEY CLUSTERED 
(
	[NoPref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Prets]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Prets](
	[NoPret] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[NoEquipement] [int] NOT NULL,
	[NoTRP] [int] NOT NULL,
	[NoItem] [nvarchar](max) NOT NULL,
	[NoFacture] [int] NULL,
	[DateRetour] [datetime] NOT NULL,
	[Depot] [money] NOT NULL,
	[CoutPret] [money] NOT NULL,
	[VerifiedByTRP] [bit] NOT NULL,
	[Rembourse] [bit] NOT NULL,
	[Retourne] [bit] NOT NULL,
	[Remarques] [varchar](max) NOT NULL,
	[DateHeure] [datetime] NOT NULL,
	[MontantRembourse] [money] NOT NULL,
	[MontantProfit] [money] NOT NULL,
	[CostAmountBy] [money] NOT NULL,
	[CostRepetitionBy] [int] NOT NULL,
	[DepositRefundPercentage] [float] NOT NULL,
	[CostRefundPercentage] [float] NOT NULL,
 CONSTRAINT [PK_Prets_1] PRIMARY KEY CLUSTERED 
(
	[NoPret] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RapportCategories]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RapportCategories](
	[NoRapportCategorie] [int] IDENTITY(1,1) NOT NULL,
	[RapportCategorie] [varchar](max) NOT NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_RapportCategories] PRIMARY KEY CLUSTERED 
(
	[NoRapportCategorie] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RapportFiltrages]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RapportFiltrages](
	[NoRapportFiltrage] [int] NOT NULL,
	[FiltrageName] [nvarchar](255) NOT NULL,
	[TableDotField] [nvarchar](max) NOT NULL,
	[FiltrageProperties] [nvarchar](max) NULL,
	[NoRapportType] [int] NOT NULL,
	[IsRequired] [bit] NOT NULL CONSTRAINT [DF_RapportFiltrages_IsRequired]  DEFAULT ((0)),
 CONSTRAINT [PK_RapportFiltrages] PRIMARY KEY CLUSTERED 
(
	[NoRapportFiltrage] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RapportTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RapportTypes](
	[NoRapportType] [int] NOT NULL,
	[RapportTitle] [nvarchar](255) NOT NULL,
	[RapportHeaderName] [nvarchar](150) NOT NULL,
	[RapportHeaderProperties] [varchar](max) NULL,
	[RapportBodyName] [nvarchar](150) NOT NULL,
	[RapportBodyProperties] [varchar](max) NULL,
	[RapportFooterName] [nvarchar](150) NOT NULL,
	[RapportFooterProperties] [varchar](max) NULL,
	[NoRapportCategorie] [int] NULL,
	[RapportProperties] [varchar](max) NULL,
 CONSTRAINT [PK_RapportTypes] PRIMARY KEY CLUSTERED 
(
	[NoRapportType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SearchList]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchList](
	[NoSearchList] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[SearchListItem] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_SearchList] PRIMARY KEY CLUSTERED 
(
	[NoSearchList] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SiteLesion]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SiteLesion](
	[NoSiteLesion] [int] IDENTITY(1,1) NOT NULL,
	[SiteLesion] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_SiteLesion] PRIMARY KEY CLUSTERED 
(
	[NoSiteLesion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SoftwareNews]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SoftwareNews](
	[NoSoftwareNews] [int] IDENTITY(1,1) NOT NULL,
	[Viewed] [bit] NOT NULL CONSTRAINT [DF_SoftwareNews_Viewed]  DEFAULT ((0)),
	[SoftwareNews] [varchar](max) NOT NULL,
	[NewsDate] [datetime] NOT NULL,
	[NewsType] [varchar](max) NOT NULL CONSTRAINT [DF_SoftwareNews_NewsType]  DEFAULT ('Ajout'),
 CONSTRAINT [PK_SoftwareNews] PRIMARY KEY CLUSTERED 
(
	[NoSoftwareNews] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SoftwareNewsUsers]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SoftwareNewsUsers](
	[NoSoftwareNews] [int] NOT NULL,
	[NoUser] [int] NOT NULL,
	[Viewed] [bit] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SpecialDates]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpecialDates](
	[NoSpecialDate] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [varchar](max) NOT NULL,
	[MaxYear] [int] NOT NULL,
	[Method] [tinyint] NOT NULL,
	[Mois1] [tinyint] NOT NULL,
	[Mois2] [tinyint] NOT NULL,
	[Mois3] [tinyint] NOT NULL,
	[Jour1] [tinyint] NOT NULL,
	[Jour3] [tinyint] NOT NULL,
	[Journee2] [tinyint] NOT NULL,
	[Journee3] [tinyint] NOT NULL,
	[Relative3] [tinyint] NOT NULL,
	[Position2] [tinyint] NOT NULL,
	[CodeVBNet] [text] NOT NULL,
	[BaseDay4] [int] NULL,
	[Relative4] [tinyint] NULL,
	[NbDays4] [int] NULL,
 CONSTRAINT [PK_SpecialDates] PRIMARY KEY CLUSTERED 
(
	[NoSpecialDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SpecialDatesBase]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SpecialDatesBase](
	[NoSpecialDate] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [varchar](max) NOT NULL,
	[MaxYear] [int] NOT NULL,
	[Method] [tinyint] NOT NULL,
	[Mois1] [tinyint] NOT NULL,
	[Mois2] [tinyint] NOT NULL,
	[Mois3] [tinyint] NOT NULL,
	[Jour1] [tinyint] NOT NULL,
	[Jour3] [tinyint] NOT NULL,
	[Journee2] [tinyint] NOT NULL,
	[Journee3] [tinyint] NOT NULL,
	[Relative3] [tinyint] NOT NULL,
	[Position2] [tinyint] NOT NULL,
	[CodeVBNet] [text] NOT NULL,
	[BaseDay4] [int] NULL,
	[Relative4] [tinyint] NULL,
	[NbDays4] [int] NULL,
 CONSTRAINT [PK_SpecialDatesBase] PRIMARY KEY CLUSTERED 
(
	[NoSpecialDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatFactures]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatFactures](
	[NoStat] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[DateHeureCreation] [datetime] NOT NULL,
	[NoFacture] [int] NOT NULL,
	[NoFolder] [int] NULL,
	[NoClient] [int] NULL,
	[MontantFacture] [money] NOT NULL,
	[TypeFacture] [nvarchar](max) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[NoVisite] [int] NULL,
	[NoPret] [int] NULL,
	[NoFactureRef] [nvarchar](max) NULL,
	[NoVente] [int] NULL,
	[Taxe1] [real] NOT NULL,
	[Taxe2] [real] NOT NULL,
	[NoAction] [int] NOT NULL,
	[DateFacture] [datetime] NOT NULL,
	[ParNoKp] [int] NULL,
	[ParNoClient] [int] NULL,
	[ParNoUser] [int] NULL,
	[NoKp] [int] NULL,
	[NoUserFacture] [int] NULL,
	[NoFactureTransfere] [int] NULL,
	[Commentaires] [varchar](max) NULL CONSTRAINT [DF_StatFactures_Commentaires]  DEFAULT (''),
	[ParNoClinique] [int] NULL,
	[NoEntitePayeur] [int] NOT NULL DEFAULT ((1)),
	[TaxesApplication] [int] NULL,
 CONSTRAINT [PK_StatFactures] PRIMARY KEY CLUSTERED 
(
	[NoStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatFolders]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatFolders](
	[NoStat] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[DateHeureCreation] [datetime] NOT NULL,
	[NoAction] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[NoClient] [int] NOT NULL,
	[Comments] [varchar](max) NULL,
 CONSTRAINT [PK_StatFolders] PRIMARY KEY CLUSTERED 
(
	[NoStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[StatPaiements]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StatPaiements](
	[NoStat] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[DateHeureCreation] [datetime] NOT NULL,
	[NoFacture] [int] NOT NULL,
	[MontantPaiement] [money] NOT NULL,
	[DateTransaction] [datetime] NOT NULL,
	[TypePaiement] [nvarchar](max) NULL,
	[Commentaires] [nvarchar](max) NULL,
	[NoAction] [int] NOT NULL,
	[NoClient] [int] NULL,
	[NoFolder] [int] NULL,
	[ParNoClient] [int] NULL,
	[ParNoKP] [int] NULL,
	[ParNoUser] [int] NULL,
	[NoNoRecu] [int] NULL,
	[ParNoClinique] [int] NULL,
	[DateRecu] [datetime] NULL,
	[NoVisite] [int] NULL,
	[NoPret] [int] NULL,
	[NoVente] [int] NULL,
	[NoKP] [int] NULL,
	[NoUserFacture] [int] NULL,
	[NoEntitePayeur] [int] NOT NULL DEFAULT ((1)),
 CONSTRAINT [PK_StatPaiements] PRIMARY KEY CLUSTERED 
(
	[NoStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StatVisites]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[StatVisites](
	[NoStat] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[DateHeureCreation] [datetime] NOT NULL,
	[NoAction] [int] NOT NULL,
	[NoVisite] [int] NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[NoRaison] [int] NULL,
	[Comments] [varchar](max) NULL,
 CONSTRAINT [PK_StatVisites] PRIMARY KEY CLUSTERED 
(
	[NoStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[TelephoneTitles]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TelephoneTitles](
	[NoTelePhoneTitle] [int] IDENTITY(1,1) NOT NULL,
	[TelePhoneTitle] [varchar](max) NOT NULL,
 CONSTRAINT [PK_TelephoneTitles] PRIMARY KEY CLUSTERED 
(
	[NoTelePhoneTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Thresholds]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Thresholds](
	[NoThreshold] [int] IDENTITY(1,1) NOT NULL,
	[NoGroup] [int] NOT NULL,
	[ThresholdMin] [int] NULL,
	[ThresholdMax] [int] NULL,
	[Name] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Thresholds] PRIMARY KEY CLUSTERED 
(
	[NoThreshold] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Titres]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Titres](
	[NoTitre] [int] IDENTITY(1,1) NOT NULL,
	[Titre] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_Titres] PRIMARY KEY CLUSTERED 
(
	[NoTitre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TriggerReturns]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TriggerReturns](
	[NoTrigger] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
 CONSTRAINT [PK_TriggerReturns] PRIMARY KEY CLUSTERED 
(
	[NoTrigger] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TypeUtilisateur]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[TypeUtilisateur](
	[NoType] [int] IDENTITY(1,1) NOT NULL,
	[NomType] [nvarchar](max) NOT NULL,
	[DroitAcces] [varchar](max) NOT NULL,
	[IsTherapist] [bit] NOT NULL,
 CONSTRAINT [PK_TypeUtilisateur] PRIMARY KEY CLUSTERED 
(
	[NoType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UniqueNumber]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UniqueNumber](
	[NoUnique] [bigint] IDENTITY(1,1) NOT NULL,
	[Fake] [bit] NULL,
 CONSTRAINT [PK_UniqueNumber] PRIMARY KEY CLUSTERED 
(
	[NoUnique] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UsersAlerts]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UsersAlerts](
	[NoUserAlert] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[AlertType] [varchar](max) NOT NULL,
	[AlertData] [varchar](max) NOT NULL CONSTRAINT [DF_UsersAlerts_AlertOpening]  DEFAULT (''),
	[AffDate] [datetime] NULL,
	[ExpDate] [datetime] NULL,
	[AlarmData] [varchar](max) NULL,
	[IsHidden] [bit] NOT NULL CONSTRAINT [DF_UsersAlerts_IsHidden]  DEFAULT ((0)),
	[IsNew] [bit] NOT NULL CONSTRAINT [DF_UsersAlerts_IsNew]  DEFAULT ((1)),
	[Message] [varchar](max) NOT NULL,
	[NoUserAlertType] [int] NULL,
 CONSTRAINT [PK_UsersAlerts] PRIMARY KEY CLUSTERED 
(
	[NoUserAlert] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UsersAlertsTypes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UsersAlertsTypes](
	[NoUserAlertType] [int] IDENTITY(1,1) NOT NULL,
	[AlertType] [varchar](max) NOT NULL,
	[AlertTypeSpecific] [varchar](max) NOT NULL,
	[DefaultExpiryInMinutes] [int] NOT NULL,
	[NoFolderTexteType] [int] NULL,
	[TypeName] [varchar](max) NOT NULL,
 CONSTRAINT [PK_UsersAlertsTypes] PRIMARY KEY CLUSTERED 
(
	[NoUserAlertType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UsersAlertsTypesExpiry]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersAlertsTypesExpiry](
	[NoUserAlertType] [int] NOT NULL,
	[NoUser] [int] NOT NULL,
	[ExpiryInMinutes] [int] NOT NULL,
 CONSTRAINT [PK_UsersAlertsTypesExpiry] PRIMARY KEY CLUSTERED 
(
	[NoUserAlertType] ASC,
	[NoUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UsersConnected]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UsersConnected](
	[NoConnection] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[ComputerName] [varchar](255) NOT NULL,
	[StartTime] [datetime] NOT NULL,
 CONSTRAINT [PK_UsersConnected] PRIMARY KEY CLUSTERED 
(
	[NoConnection] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UsersSettings]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UsersSettings](
	[NoUserSetting] [int] IDENTITY(1,1) NOT NULL,
	[NoUser] [int] NOT NULL,
	[SectorName] [varchar](max) NOT NULL,
	[Settings] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED 
(
	[NoUserSetting] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Utilisateurs]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Utilisateurs](
	[NoUser] [int] IDENTITY(1,1) NOT NULL,
	[Cle] [nvarchar](max) NOT NULL,
	[MDP] [nvarchar](max) NOT NULL,
	[Nom] [nvarchar](max) NOT NULL,
	[Prenom] [nvarchar](max) NOT NULL,
	[NoType] [int] NULL,
	[URL] [varchar](max) NOT NULL,
	[Adresse] [nvarchar](max) NOT NULL,
	[NoVille] [int] NULL,
	[CodePostal] [nvarchar](6) NOT NULL,
	[Telephones] [varchar](max) NOT NULL,
	[Courriel] [nvarchar](max) NOT NULL,
	[NoTitre] [int] NULL,
	[NoPermis] [nvarchar](max) NOT NULL,
	[DateDebut] [datetime] NULL,
	[DateFin] [datetime] NULL,
	[NoTypeEmploye] [int] NOT NULL,
	[Services] [varchar](max) NOT NULL,
	[IsTherapist] [bit] NOT NULL,
	[DroitAcces] [varchar](max) NOT NULL,
	[NotConfirmRVOnPasteOfDTRP] [bit] NOT NULL CONSTRAINT [DF__Utilisate__NotCo__63F8CA06]  DEFAULT ((0)),
 CONSTRAINT [PK_Utilisateurs] PRIMARY KEY CLUSTERED 
(
	[NoUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Ventes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ventes](
	[NoVente] [int] IDENTITY(1,1) NOT NULL,
	[NoClient] [int] NOT NULL,
	[NoFolder] [int] NOT NULL,
	[NoEquipement] [int] NOT NULL,
	[NoTRP] [int] NOT NULL,
	[NoFacture] [int] NULL,
	[NoItem] [nvarchar](max) NOT NULL,
	[DateHeure] [datetime] NOT NULL,
	[MontantProfit] [money] NOT NULL,
 CONSTRAINT [PK_Ventes_1] PRIMARY KEY CLUSTERED 
(
	[NoVente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Villes]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Villes](
	[NoVille] [int] IDENTITY(1,1) NOT NULL,
	[NomVille] [nvarchar](max) NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_Villes] PRIMARY KEY CLUSTERED 
(
	[NoVille] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WorkHours]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkHours](
	[NoUser] [int] NOT NULL,
	[Week] [datetime] NOT NULL,
	[DiDe] [nvarchar](5) NULL,
	[DiA] [nvarchar](5) NULL,
	[LuDe] [nvarchar](5) NULL,
	[LuA] [nvarchar](5) NULL,
	[MaDe] [nvarchar](5) NULL,
	[MaA] [nvarchar](5) NULL,
	[MeDe] [nvarchar](5) NULL,
	[MeA] [nvarchar](5) NULL,
	[JeDe] [nvarchar](5) NULL,
	[JeA] [nvarchar](5) NULL,
	[VeDe] [nvarchar](5) NULL,
	[VeA] [nvarchar](5) NULL,
	[SaDe] [nvarchar](5) NULL,
	[SaA] [nvarchar](5) NULL,
	[Approuved] [bit] NULL,
	[NoTrigger] [int] NULL,
 CONSTRAINT [PK_WorkHours] PRIMARY KEY CLUSTERED 
(
	[NoUser] ASC,
	[Week] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[fn_getTablesCount]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		CyberInteranutes
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fn_getTablesCount]()
RETURNS TABLE 
AS
RETURN 
(
SELECT    OBJECT_NAME(object_id) as TableName,SUM (row_count) as Counted

FROM      sys.dm_db_partition_stats 

WHERE     index_id  <  2 

AND       OBJECTPROPERTY(object_id, 'IsUserTable')  =  1

GROUP BY  object_id 
)


GO
/****** Object:  View [dbo].[FolderDates]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FolderDates]
AS
SELECT     NoFolder,
                          (SELECT     TOP (1) DateHeure
                            FROM          dbo.InfoVisites AS InfoVisites_2
                            WHERE      (NoFolder = dbo.InfoFolders.NoFolder)
                            ORDER BY DateHeure) AS FirstDate,
                          (SELECT     TOP (1) DateHeure
                            FROM          dbo.InfoVisites AS InfoVisites_2
                            WHERE      (NoFolder = dbo.InfoFolders.NoFolder)
                            ORDER BY DateHeure DESC) AS LastDate,
							(SELECT     TOP (1) DateHeure
                            FROM          dbo.InfoVisites AS InfoVisites_2
                            WHERE      (NoFolder = dbo.InfoFolders.NoFolder) AND (Evaluation = 1) AND (NoStatut = 4)
                            ORDER BY DateHeure) AS FirstEval,
                          (SELECT     TOP (1) DateHeure
                            FROM          dbo.InfoVisites AS InfoVisites_2
                            WHERE      (NoFolder = dbo.InfoFolders.NoFolder) AND (Evaluation = 0) AND (NoStatut = 4)
                            ORDER BY DateHeure) AS FirstTraitement,
                          (SELECT     TOP (1) DateHeure
                            FROM          dbo.InfoVisites AS InfoVisites_2
                            WHERE      (NoFolder = dbo.InfoFolders.NoFolder) AND (Evaluation = 0) AND (NoStatut = 4)
                            ORDER BY DateHeure DESC) AS LastTraitement,
                          (SELECT     TOP (1) DateHeureCreation
                            FROM          dbo.StatFolders
                            WHERE      (NoFolder = dbo.InfoFolders.NoFolder)) AS CreationDate, dbo.fnGetFolderClosingDate(NoFolder) AS ClosingDate, NoClient, Diagnostic, 
                      NoSiteLesion, NoTRPTraitant, StatutOuvert, NoKP, NoRef, Service, DateRef, DateAccident, DateRechute, Duree, Frequence, NoTRPDemande, 
                      NbVisiteHavingCAR, OldiestCAR, Flagged, Remarques, NoTRPToTransfer, NoCodeUnique, NoCodeUser, NoCodeDate, DateReceptionRef,ExternalStatus
FROM         dbo.InfoFolders
GO
/****** Object:  View [dbo].[FolderTexteDates]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FolderTexteDates]
AS
SELECT     TOP (100) PERCENT FT.TexteTitle AS Title, CASE WHEN FTT.IsNbDaysDiffBefore = 0 THEN DATEADD(d, FTT.NbDaysDiff, FT.DateStarted) 
                      ELSE DATEADD(d, FTT.NbDaysDiff * - 1, FT.DateStarted) END AS StartRap, FT.DateStarted, FT.DateFinished, 
                      CASE WHEN FTT.IsNbDaysDiffBefore = 0 THEN DATEADD(d, FTT.NbDaysDiff + FTT.AlertNbDaysForExpiry, FT.DateStarted) ELSE DATEADD(d, 
                      FTT.AlertNbDaysForExpiry, FT.DateStarted) END AS EndRap, FT.NoFolder, CASE WHEN DateFinished IS NULL THEN 0 ELSE 1 END AS RapEnded, 
                      FT.NoFolderTexteType, FT.NoMultiple, FT.IsTexte
FROM         dbo.FolderTextes AS FT INNER JOIN
                      dbo.FolderTexteTypes AS FTT ON FT.NoFolderTexteType = FTT.NoFolderTexteType
WHERE     (FTT.ShowAlert = 1) AND (FTT.Multiple = 1 OR FTT.CopyTextToOtherText <> 0)
ORDER BY FT.NoFolder, StartRap, FT.NoFolderTexte


GO
/****** Object:  View [dbo].[UserAlertsExpiries]    Script Date: 2020-07-06 11:54:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserAlertsExpiries]
AS
SELECT     TOP (100) PERCENT dbo.UsersAlertsTypes.NoUserAlertType, dbo.UsersAlertsTypesExpiry.NoUser, 
                      CASE WHEN dbo.UsersAlertsTypes.TypeName = '' THEN
                          (SELECT     TexteTitle
                            FROM          FolderTexteTypes AS FTT
                            WHERE      FTT.NoFolderTexteType = UsersAlertsTypes.NoFolderTexteType) ELSE dbo.UsersAlertsTypes.TypeName END AS TypeName, 
                      CASE WHEN ExpiryInMinutes IS NULL THEN DefaultExpiryInMinutes ELSE ExpiryInMinutes END AS ExpiryInMinutes
FROM         dbo.UsersAlertsTypesExpiry RIGHT OUTER JOIN
                      dbo.UsersAlertsTypes ON dbo.UsersAlertsTypesExpiry.NoUserAlertType = dbo.UsersAlertsTypes.NoUserAlertType
ORDER BY TypeName
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_CodesDossiersCodes_CodeName]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_CodesDossiersCodes_CodeName] ON [dbo].[CodesDossiersCodes]
(
	[CodeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Factures_ClientCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_Factures_ClientCols] ON [dbo].[Factures]
(
	[ParNoClient] ASC,
	[NoClient] ASC,
	[NoFolder] ASC,
	[NoVisite] ASC,
	[NoPret] ASC,
	[NoVente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Factures_OtherCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_Factures_OtherCols] ON [dbo].[Factures]
(
	[ParNoKP] ASC,
	[ParNoClinique] ASC,
	[NoKP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Factures_UserCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_Factures_UserCols] ON [dbo].[Factures]
(
	[ParNoUser] ASC,
	[NoUserFacture] ASC,
	[NoUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_FacturesRecusLeft]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_FacturesRecusLeft] ON [dbo].[FacturesRecusLeft]
(
	[NoStat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_InfoVisites_Statut_Eval]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [idx_InfoVisites_Statut_Eval] ON [dbo].[InfoVisites]
(
	[NoFolder] ASC,
	[NoStatut] ASC,
	[Evaluation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatFactures_ClientCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatFactures_ClientCols] ON [dbo].[StatFactures]
(
	[ParNoClient] ASC,
	[NoFolder] ASC,
	[NoClient] ASC,
	[NoVisite] ASC,
	[NoPret] ASC,
	[NoVente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatFactures_DateFacture]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatFactures_DateFacture] ON [dbo].[StatFactures]
(
	[DateFacture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatFactures_NoFacture]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatFactures_NoFacture] ON [dbo].[StatFactures]
(
	[NoFacture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatFactures_Others]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatFactures_Others] ON [dbo].[StatFactures]
(
	[NoAction] ASC,
	[ParNoKp] ASC,
	[NoKp] ASC,
	[ParNoClinique] ASC,
	[NoEntitePayeur] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatFactures_UserCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatFactures_UserCols] ON [dbo].[StatFactures]
(
	[ParNoUser] ASC,
	[NoUserFacture] ASC,
	[NoUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ActionVSFolder]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [ActionVSFolder] ON [dbo].[StatFolders]
(
	[NoFolder] ASC,
	[NoAction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatPaiements_ClientCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatPaiements_ClientCols] ON [dbo].[StatPaiements]
(
	[ParNoClient] ASC,
	[NoClient] ASC,
	[NoFolder] ASC,
	[NoVisite] ASC,
	[NoPret] ASC,
	[NoVente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatPaiements_NoFacture]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatPaiements_NoFacture] ON [dbo].[StatPaiements]
(
	[NoFacture] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatPaiements_Others]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatPaiements_Others] ON [dbo].[StatPaiements]
(
	[NoAction] ASC,
	[ParNoKP] ASC,
	[ParNoClinique] ASC,
	[NoKP] ASC,
	[NoEntitePayeur] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_StatPaiements_UserCols]    Script Date: 2020-07-06 11:54:44 ******/
CREATE NONCLUSTERED INDEX [IX_StatPaiements_UserCols] ON [dbo].[StatPaiements]
(
	[ParNoUser] ASC,
	[NoUserFacture] ASC,
	[NoUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_UserConnected]    Script Date: 2020-07-06 11:54:44 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserConnected] ON [dbo].[UsersConnected]
(
	[NoUser] ASC,
	[ComputerName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Agenda]  WITH NOCHECK ADD  CONSTRAINT [FK_Agenda_ListeStatut] FOREIGN KEY([NoStatut])
REFERENCES [dbo].[ListeStatut] ([NoStatut])
GO
ALTER TABLE [dbo].[Agenda] CHECK CONSTRAINT [FK_Agenda_ListeStatut]
GO
ALTER TABLE [dbo].[Agenda]  WITH NOCHECK ADD  CONSTRAINT [FK_Agenda_Utilisateurs] FOREIGN KEY([NoTRP])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Agenda] CHECK CONSTRAINT [FK_Agenda_Utilisateurs]
GO
ALTER TABLE [dbo].[BrowserUrls]  WITH CHECK ADD  CONSTRAINT [FK_BrowserUrls_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BrowserUrls] CHECK CONSTRAINT [FK_BrowserUrls_Utilisateurs]
GO
ALTER TABLE [dbo].[ClientsAntecedents]  WITH CHECK ADD  CONSTRAINT [FK_ClientsAntecedents_InfoClients] FOREIGN KEY([NoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ClientsAntecedents] CHECK CONSTRAINT [FK_ClientsAntecedents_InfoClients]
GO
ALTER TABLE [dbo].[CodesDossiersFolderAlertTypes]  WITH CHECK ADD  CONSTRAINT [FK_CodesDossiersFolderAlertTypes_CodificationsDossiers] FOREIGN KEY([NoUnique])
REFERENCES [dbo].[CodesDossiersCodes] ([NoCodeUnique])
GO
ALTER TABLE [dbo].[CodesDossiersFolderAlertTypes] CHECK CONSTRAINT [FK_CodesDossiersFolderAlertTypes_CodificationsDossiers]
GO
ALTER TABLE [dbo].[CodesDossiersFolderAlertTypes]  WITH CHECK ADD  CONSTRAINT [FK_CodesDossiersFolderAlertTypes_FolderAlertTypes] FOREIGN KEY([NoFolderAlertType])
REFERENCES [dbo].[FolderAlertTypes] ([NoFolderAlertType])
GO
ALTER TABLE [dbo].[CodesDossiersFolderAlertTypes] CHECK CONSTRAINT [FK_CodesDossiersFolderAlertTypes_FolderAlertTypes]
GO
ALTER TABLE [dbo].[CodesDossiersFolderTexteTypes]  WITH CHECK ADD  CONSTRAINT [FK_CodesDossiersFolderTexteTypes_CodificationsDossiers] FOREIGN KEY([NoUnique])
REFERENCES [dbo].[CodesDossiersCodes] ([NoCodeUnique])
GO
ALTER TABLE [dbo].[CodesDossiersFolderTexteTypes] CHECK CONSTRAINT [FK_CodesDossiersFolderTexteTypes_CodificationsDossiers]
GO
ALTER TABLE [dbo].[CodesDossiersFolderTexteTypes]  WITH CHECK ADD  CONSTRAINT [FK_CodesDossiersFolderTexteTypes_FolderTexteTypes] FOREIGN KEY([NoFolderTexteType])
REFERENCES [dbo].[FolderTexteTypes] ([NoFolderTexteType])
GO
ALTER TABLE [dbo].[CodesDossiersFolderTexteTypes] CHECK CONSTRAINT [FK_CodesDossiersFolderTexteTypes_FolderTexteTypes]
GO
ALTER TABLE [dbo].[CodesDossiersPeriodes]  WITH CHECK ADD  CONSTRAINT [FK_CodesDossiersPeriodes_CodificationsDossiers] FOREIGN KEY([NoCodification])
REFERENCES [dbo].[CodificationsDossiers] ([NoCodification])
GO
ALTER TABLE [dbo].[CodesDossiersPeriodes] CHECK CONSTRAINT [FK_CodesDossiersPeriodes_CodificationsDossiers]
GO
ALTER TABLE [dbo].[CodesDossiersPeriodes]  WITH CHECK ADD  CONSTRAINT [FK_CodesDossiersPeriodes_ListePeriode] FOREIGN KEY([NoPeriode])
REFERENCES [dbo].[ListePeriode] ([NoPeriode])
GO
ALTER TABLE [dbo].[CodesDossiersPeriodes] CHECK CONSTRAINT [FK_CodesDossiersPeriodes_ListePeriode]
GO
ALTER TABLE [dbo].[CodificationsDossiers]  WITH NOCHECK ADD  CONSTRAINT [FK_CodificationsDossiers_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[CodificationsDossiers] NOCHECK CONSTRAINT [FK_CodificationsDossiers_Utilisateurs]
GO
ALTER TABLE [dbo].[CommDeA]  WITH NOCHECK ADD  CONSTRAINT [FK_CommDeA_InfoClients] FOREIGN KEY([NoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CommDeA] CHECK CONSTRAINT [FK_CommDeA_InfoClients]
GO
ALTER TABLE [dbo].[CommDeAKP]  WITH CHECK ADD  CONSTRAINT [FK_CommDeAKP_KeyPeople] FOREIGN KEY([NoKP])
REFERENCES [dbo].[KeyPeople] ([NoKP])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CommDeAKP] CHECK CONSTRAINT [FK_CommDeAKP_KeyPeople]
GO
ALTER TABLE [dbo].[Communications]  WITH CHECK ADD  CONSTRAINT [FK_Communications_CommCategories] FOREIGN KEY([NoCategorie])
REFERENCES [dbo].[CommCategories] ([NoCategorie])
GO
ALTER TABLE [dbo].[Communications] CHECK CONSTRAINT [FK_Communications_CommCategories]
GO
ALTER TABLE [dbo].[Communications]  WITH NOCHECK ADD  CONSTRAINT [FK_Communications_InfoClients] FOREIGN KEY([NoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Communications] CHECK CONSTRAINT [FK_Communications_InfoClients]
GO
ALTER TABLE [dbo].[Communications]  WITH CHECK ADD  CONSTRAINT [FK_Communications_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[Communications] CHECK CONSTRAINT [FK_Communications_Utilisateurs]
GO
ALTER TABLE [dbo].[CommunicationsKP]  WITH CHECK ADD  CONSTRAINT [FK_CommunicationsKP_CommCategories] FOREIGN KEY([NoCategorie])
REFERENCES [dbo].[CommCategories] ([NoCategorie])
GO
ALTER TABLE [dbo].[CommunicationsKP] CHECK CONSTRAINT [FK_CommunicationsKP_CommCategories]
GO
ALTER TABLE [dbo].[CommunicationsKP]  WITH NOCHECK ADD  CONSTRAINT [FK_CommunicationsKP_KeyPeople] FOREIGN KEY([NoKP])
REFERENCES [dbo].[KeyPeople] ([NoKP])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CommunicationsKP] CHECK CONSTRAINT [FK_CommunicationsKP_KeyPeople]
GO
ALTER TABLE [dbo].[CommunicationsKP]  WITH CHECK ADD  CONSTRAINT [FK_CommunicationsKP_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[CommunicationsKP] CHECK CONSTRAINT [FK_CommunicationsKP_Utilisateurs]
GO
ALTER TABLE [dbo].[ContactFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_ContactFolders_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[ContactFolders] NOCHECK CONSTRAINT [FK_ContactFolders_Utilisateurs]
GO
ALTER TABLE [dbo].[Contacts]  WITH CHECK ADD  CONSTRAINT [FK_Contacts_ContactFolders] FOREIGN KEY([NoContactFolder])
REFERENCES [dbo].[ContactFolders] ([NoContactFolder])
GO
ALTER TABLE [dbo].[Contacts] CHECK CONSTRAINT [FK_Contacts_ContactFolders]
GO
ALTER TABLE [dbo].[Contacts]  WITH CHECK ADD  CONSTRAINT [FK_Contacts_Pays] FOREIGN KEY([NoPays])
REFERENCES [dbo].[Pays] ([NoPays])
GO
ALTER TABLE [dbo].[Contacts] CHECK CONSTRAINT [FK_Contacts_Pays]
GO
ALTER TABLE [dbo].[DBFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_DBFolders_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[DBFolders] NOCHECK CONSTRAINT [FK_DBFolders_Utilisateurs]
GO
ALTER TABLE [dbo].[DBItems]  WITH CHECK ADD  CONSTRAINT [FK_DBItems_DBFolders] FOREIGN KEY([NoDBFolder])
REFERENCES [dbo].[DBFolders] ([NoDBFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DBItems] CHECK CONSTRAINT [FK_DBItems_DBFolders]
GO
ALTER TABLE [dbo].[DBItems]  WITH CHECK ADD  CONSTRAINT [FK_DBItems_FileTypes] FOREIGN KEY([NoFileType])
REFERENCES [dbo].[FileTypes] ([NoFileType])
GO
ALTER TABLE [dbo].[DBItems] CHECK CONSTRAINT [FK_DBItems_FileTypes]
GO
ALTER TABLE [dbo].[DBItemsDroitsAcces]  WITH CHECK ADD  CONSTRAINT [FK_DBItemsDroitsAcces_DBItems] FOREIGN KEY([NoDBItem])
REFERENCES [dbo].[DBItems] ([NoDBItem])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DBItemsDroitsAcces] CHECK CONSTRAINT [FK_DBItemsDroitsAcces_DBItems]
GO
ALTER TABLE [dbo].[DBItemsMotsCles]  WITH CHECK ADD  CONSTRAINT [FK_DBItemsMotsCles_DBItems] FOREIGN KEY([NoDBItem])
REFERENCES [dbo].[DBItems] ([NoDBItem])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DBItemsMotsCles] CHECK CONSTRAINT [FK_DBItemsMotsCles_DBItems]
GO
ALTER TABLE [dbo].[DBItemsMotsCles]  WITH CHECK ADD  CONSTRAINT [FK_DBItemsMotsCles_DBMotsCles] FOREIGN KEY([NoMotCle])
REFERENCES [dbo].[DBMotsCles] ([NoMotCle])
GO
ALTER TABLE [dbo].[DBItemsMotsCles] CHECK CONSTRAINT [FK_DBItemsMotsCles_DBMotsCles]
GO
ALTER TABLE [dbo].[DBSearchList]  WITH NOCHECK ADD  CONSTRAINT [FK_DBSearchList_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DBSearchList] CHECK CONSTRAINT [FK_DBSearchList_Utilisateurs]
GO
ALTER TABLE [dbo].[DemandesAuthorisations]  WITH NOCHECK ADD  CONSTRAINT [FK_DemandesAuthorisations_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DemandesAuthorisations] CHECK CONSTRAINT [FK_DemandesAuthorisations_InfoFolders]
GO
ALTER TABLE [dbo].[DemandesAuthorisations]  WITH CHECK ADD  CONSTRAINT [FK_DemandesAuthorisations_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[DemandesAuthorisations] CHECK CONSTRAINT [FK_DemandesAuthorisations_Utilisateurs]
GO
ALTER TABLE [dbo].[Equipements]  WITH NOCHECK ADD  CONSTRAINT [FK_Equipements_ECategorie] FOREIGN KEY([NoECategorie])
REFERENCES [dbo].[ECategorie] ([NoECategorie])
GO
ALTER TABLE [dbo].[Equipements] CHECK CONSTRAINT [FK_Equipements_ECategorie]
GO
ALTER TABLE [dbo].[Equipements]  WITH CHECK ADD  CONSTRAINT [FK_Equipements_ListeRepetition] FOREIGN KEY([CoutBy])
REFERENCES [dbo].[ListeRepetition] ([NoCategorie])
GO
ALTER TABLE [dbo].[Equipements] CHECK CONSTRAINT [FK_Equipements_ListeRepetition]
GO
ALTER TABLE [dbo].[Equipements]  WITH CHECK ADD  CONSTRAINT [FK_Equipements_ListeTypeItem] FOREIGN KEY([TypeItem])
REFERENCES [dbo].[ListeTypeItem] ([NoCategorie])
GO
ALTER TABLE [dbo].[Equipements] CHECK CONSTRAINT [FK_Equipements_ListeTypeItem]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_InfoClients] FOREIGN KEY([NoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_InfoClients]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_InfoClients1] FOREIGN KEY([ParNoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_InfoClients1]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_KeyPeople] FOREIGN KEY([ParNoKP])
REFERENCES [dbo].[KeyPeople] ([NoKP])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_KeyPeople]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_KeyPeople1] FOREIGN KEY([NoKP])
REFERENCES [dbo].[KeyPeople] ([NoKP])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_KeyPeople1]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_Utilisateurs]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_Utilisateurs1] FOREIGN KEY([ParNoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_Utilisateurs1]
GO
ALTER TABLE [dbo].[Factures]  WITH CHECK ADD  CONSTRAINT [FK_Factures_Utilisateurs2] FOREIGN KEY([NoUserFacture])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[Factures] CHECK CONSTRAINT [FK_Factures_Utilisateurs2]
GO
ALTER TABLE [dbo].[FacturesRecusLeft]  WITH CHECK ADD  CONSTRAINT [FK_FacturesRecusLeft_StatPaiements] FOREIGN KEY([NoStat])
REFERENCES [dbo].[StatPaiements] ([NoStat])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FacturesRecusLeft] CHECK CONSTRAINT [FK_FacturesRecusLeft_StatPaiements]
GO
ALTER TABLE [dbo].[FileTypes]  WITH CHECK ADD  CONSTRAINT [FK_FileTypes_BaseFileTypes] FOREIGN KEY([NoBaseFileType])
REFERENCES [dbo].[BaseFileTypes] ([NoBaseFileType])
GO
ALTER TABLE [dbo].[FileTypes] CHECK CONSTRAINT [FK_FileTypes_BaseFileTypes]
GO
ALTER TABLE [dbo].[FileTypesDroitsAcces]  WITH CHECK ADD  CONSTRAINT [FK_FileTypesDroitsAcces_FileTypes] FOREIGN KEY([NoFileType])
REFERENCES [dbo].[FileTypes] ([NoFileType])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FileTypesDroitsAcces] CHECK CONSTRAINT [FK_FileTypesDroitsAcces_FileTypes]
GO
ALTER TABLE [dbo].[FinMoisTypesRapports]  WITH CHECK ADD  CONSTRAINT [FK_FinMoisTypesRapports_InfoClinique] FOREIGN KEY([NoClinique])
REFERENCES [dbo].[InfoClinique] ([NoClinique])
GO
ALTER TABLE [dbo].[FinMoisTypesRapports] CHECK CONSTRAINT [FK_FinMoisTypesRapports_InfoClinique]
GO
ALTER TABLE [dbo].[FinMoisTypesRapports]  WITH CHECK ADD  CONSTRAINT [FK_FinMoisTypesRapports_RapportTypes] FOREIGN KEY([NoRapportType])
REFERENCES [dbo].[RapportTypes] ([NoRapportType])
GO
ALTER TABLE [dbo].[FinMoisTypesRapports] CHECK CONSTRAINT [FK_FinMoisTypesRapports_RapportTypes]
GO
ALTER TABLE [dbo].[FolderAlerts]  WITH CHECK ADD  CONSTRAINT [FK_FolderAlerts_FolderAlertTypes] FOREIGN KEY([NoFolderAlertType])
REFERENCES [dbo].[FolderAlertTypes] ([NoFolderAlertType])
GO
ALTER TABLE [dbo].[FolderAlerts] CHECK CONSTRAINT [FK_FolderAlerts_FolderAlertTypes]
GO
ALTER TABLE [dbo].[FolderAlerts]  WITH CHECK ADD  CONSTRAINT [FK_FolderAlerts_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FolderAlerts] CHECK CONSTRAINT [FK_FolderAlerts_InfoFolders]
GO
ALTER TABLE [dbo].[FolderTexteAlerts]  WITH CHECK ADD  CONSTRAINT [FK_FolderTextes_FolderTexteAlerts] FOREIGN KEY([NoFolderTexte])
REFERENCES [dbo].[FolderTextes] ([NoFolderTexte])
GO
ALTER TABLE [dbo].[FolderTexteAlerts] CHECK CONSTRAINT [FK_FolderTextes_FolderTexteAlerts]
GO
ALTER TABLE [dbo].[FolderTexteAlerts]  WITH CHECK ADD  CONSTRAINT [FK_UsersAlerts_FolderTexteAlerts] FOREIGN KEY([NoUserAlert])
REFERENCES [dbo].[UsersAlerts] ([NoUserAlert])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FolderTexteAlerts] CHECK CONSTRAINT [FK_UsersAlerts_FolderTexteAlerts]
GO
ALTER TABLE [dbo].[FolderTextes]  WITH CHECK ADD  CONSTRAINT [FK_FolderTextes_FolderTexteTypes] FOREIGN KEY([NoFolderTexteType])
REFERENCES [dbo].[FolderTexteTypes] ([NoFolderTexteType])
GO
ALTER TABLE [dbo].[FolderTextes] CHECK CONSTRAINT [FK_FolderTextes_FolderTexteTypes]
GO
ALTER TABLE [dbo].[FolderTextes]  WITH CHECK ADD  CONSTRAINT [FK_FolderTextes_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FolderTextes] CHECK CONSTRAINT [FK_FolderTextes_InfoFolders]
GO
ALTER TABLE [dbo].[Horaires]  WITH NOCHECK ADD  CONSTRAINT [FK_Horaires_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Horaires] NOCHECK CONSTRAINT [FK_Horaires_Utilisateurs]
GO
ALTER TABLE [dbo].[InfoClients]  WITH CHECK ADD  CONSTRAINT [FK_InfoClients_Employeurs] FOREIGN KEY([NoEmployeur])
REFERENCES [dbo].[Employeurs] ([NoEmployeur])
GO
ALTER TABLE [dbo].[InfoClients] CHECK CONSTRAINT [FK_InfoClients_Employeurs]
GO
ALTER TABLE [dbo].[InfoClients]  WITH CHECK ADD  CONSTRAINT [FK_InfoClients_Metiers] FOREIGN KEY([NoMetier])
REFERENCES [dbo].[Metiers] ([NoMetier])
GO
ALTER TABLE [dbo].[InfoClients] CHECK CONSTRAINT [FK_InfoClients_Metiers]
GO
ALTER TABLE [dbo].[InfoClinique]  WITH NOCHECK ADD  CONSTRAINT [FK_InfoClinique_Villes] FOREIGN KEY([NoVille])
REFERENCES [dbo].[Villes] ([NoVille])
GO
ALTER TABLE [dbo].[InfoClinique] CHECK CONSTRAINT [FK_InfoClinique_Villes]
GO
ALTER TABLE [dbo].[InfoFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_InfoFolders_InfoClients] FOREIGN KEY([NoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
GO
ALTER TABLE [dbo].[InfoFolders] CHECK CONSTRAINT [FK_InfoFolders_InfoClients]
GO
ALTER TABLE [dbo].[InfoFolders]  WITH CHECK ADD  CONSTRAINT [FK_InfoFolders_KeyPeople] FOREIGN KEY([NoKP])
REFERENCES [dbo].[KeyPeople] ([NoKP])
GO
ALTER TABLE [dbo].[InfoFolders] CHECK CONSTRAINT [FK_InfoFolders_KeyPeople]
GO
ALTER TABLE [dbo].[InfoFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_InfoFolders_SiteLesion] FOREIGN KEY([NoSiteLesion])
REFERENCES [dbo].[SiteLesion] ([NoSiteLesion])
GO
ALTER TABLE [dbo].[InfoFolders] CHECK CONSTRAINT [FK_InfoFolders_SiteLesion]
GO
ALTER TABLE [dbo].[InfoFolders]  WITH CHECK ADD  CONSTRAINT [FK_InfoFolders_Utilisateurs] FOREIGN KEY([NoTRPTraitant])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[InfoFolders] CHECK CONSTRAINT [FK_InfoFolders_Utilisateurs]
GO
ALTER TABLE [dbo].[InfoVisites]  WITH CHECK ADD  CONSTRAINT [FK_InfoVisites_ExternalStatuses] FOREIGN KEY([ExternalStatus])
REFERENCES [dbo].[ExternalStatuses] ([NoExternalStatus])
GO
ALTER TABLE [dbo].[InfoVisites] CHECK CONSTRAINT [FK_InfoVisites_ExternalStatuses]
GO
ALTER TABLE [dbo].[InfoVisites]  WITH NOCHECK ADD  CONSTRAINT [FK_InfoVisites_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[InfoVisites] CHECK CONSTRAINT [FK_InfoVisites_InfoFolders]
GO
ALTER TABLE [dbo].[InfoVisites]  WITH NOCHECK ADD  CONSTRAINT [FK_InfoVisites_ListeStatut] FOREIGN KEY([NoStatut])
REFERENCES [dbo].[ListeStatut] ([NoStatut])
GO
ALTER TABLE [dbo].[InfoVisites] CHECK CONSTRAINT [FK_InfoVisites_ListeStatut]
GO
ALTER TABLE [dbo].[InfoVisites]  WITH CHECK ADD  CONSTRAINT [FK_InfoVisites_Utilisateurs] FOREIGN KEY([NoTRP])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[InfoVisites] CHECK CONSTRAINT [FK_InfoVisites_Utilisateurs]
GO
ALTER TABLE [dbo].[KeyPeople]  WITH NOCHECK ADD  CONSTRAINT [FK_KeyPeople_Employeurs] FOREIGN KEY([NoEmployeur])
REFERENCES [dbo].[Employeurs] ([NoEmployeur])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[KeyPeople] NOCHECK CONSTRAINT [FK_KeyPeople_Employeurs]
GO
ALTER TABLE [dbo].[KeyPeople]  WITH NOCHECK ADD  CONSTRAINT [FK_KeyPeople_KPCategorie] FOREIGN KEY([NoCategorie])
REFERENCES [dbo].[KPCategorie] ([NoCategorie])
GO
ALTER TABLE [dbo].[KeyPeople] CHECK CONSTRAINT [FK_KeyPeople_KPCategorie]
GO
ALTER TABLE [dbo].[KeyPeople]  WITH CHECK ADD  CONSTRAINT [FK_KeyPeople_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[KeyPeople] CHECK CONSTRAINT [FK_KeyPeople_Utilisateurs]
GO
ALTER TABLE [dbo].[KeyPeople]  WITH NOCHECK ADD  CONSTRAINT [FK_KeyPeople_Villes] FOREIGN KEY([NoVille])
REFERENCES [dbo].[Villes] ([NoVille])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[KeyPeople] NOCHECK CONSTRAINT [FK_KeyPeople_Villes]
GO
ALTER TABLE [dbo].[KPSearchList]  WITH NOCHECK ADD  CONSTRAINT [FK_KPSearchList_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[KPSearchList] CHECK CONSTRAINT [FK_KPSearchList_Utilisateurs]
GO
ALTER TABLE [dbo].[ListeAttente]  WITH NOCHECK ADD  CONSTRAINT [FK_ListeAttente_InfoClients] FOREIGN KEY([NoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ListeAttente] CHECK CONSTRAINT [FK_ListeAttente_InfoClients]
GO
ALTER TABLE [dbo].[ListeAttente]  WITH NOCHECK ADD  CONSTRAINT [FK_ListeAttente_InfoVisites] FOREIGN KEY([NoVisite])
REFERENCES [dbo].[InfoVisites] ([NoVisite])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ListeAttente] CHECK CONSTRAINT [FK_ListeAttente_InfoVisites]
GO
ALTER TABLE [dbo].[MailFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_MailFolders_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[MailFolders] NOCHECK CONSTRAINT [FK_MailFolders_Utilisateurs]
GO
ALTER TABLE [dbo].[Mails]  WITH CHECK ADD  CONSTRAINT [FK_Mails_MailFolders] FOREIGN KEY([NoMailFolder])
REFERENCES [dbo].[MailFolders] ([NoMailFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Mails] CHECK CONSTRAINT [FK_Mails_MailFolders]
GO
ALTER TABLE [dbo].[Modeles]  WITH CHECK ADD  CONSTRAINT [FK_Modeles_ModelesCategories] FOREIGN KEY([NoCategorie])
REFERENCES [dbo].[ModelesCategories] ([NoCategorie])
GO
ALTER TABLE [dbo].[Modeles] CHECK CONSTRAINT [FK_Modeles_ModelesCategories]
GO
ALTER TABLE [dbo].[Modeles]  WITH NOCHECK ADD  CONSTRAINT [FK_Modeles_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Modeles] NOCHECK CONSTRAINT [FK_Modeles_Utilisateurs]
GO
ALTER TABLE [dbo].[NotesTitles]  WITH NOCHECK ADD  CONSTRAINT [FK_NotesTitles_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[NotesTitles] CHECK CONSTRAINT [FK_NotesTitles_Utilisateurs]
GO
ALTER TABLE [dbo].[PayesUtilisateurs]  WITH CHECK ADD  CONSTRAINT [FK_PayesUtilisateurs_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PayesUtilisateurs] CHECK CONSTRAINT [FK_PayesUtilisateurs_Utilisateurs]
GO
ALTER TABLE [dbo].[Prets]  WITH NOCHECK ADD  CONSTRAINT [FK_Prets_Equipements] FOREIGN KEY([NoEquipement])
REFERENCES [dbo].[Equipements] ([NoEquipement])
GO
ALTER TABLE [dbo].[Prets] CHECK CONSTRAINT [FK_Prets_Equipements]
GO
ALTER TABLE [dbo].[Prets]  WITH NOCHECK ADD  CONSTRAINT [FK_Prets_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Prets] CHECK CONSTRAINT [FK_Prets_InfoFolders]
GO
ALTER TABLE [dbo].[Prets]  WITH CHECK ADD  CONSTRAINT [FK_Prets_Utilisateurs] FOREIGN KEY([NoTRP])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[Prets] CHECK CONSTRAINT [FK_Prets_Utilisateurs]
GO
ALTER TABLE [dbo].[RapportFiltrages]  WITH CHECK ADD  CONSTRAINT [FK_RapportFiltrages_RapportTypes] FOREIGN KEY([NoRapportType])
REFERENCES [dbo].[RapportTypes] ([NoRapportType])
GO
ALTER TABLE [dbo].[RapportFiltrages] CHECK CONSTRAINT [FK_RapportFiltrages_RapportTypes]
GO
ALTER TABLE [dbo].[RapportTypes]  WITH NOCHECK ADD  CONSTRAINT [FK_RapportTypes_RapportCategories] FOREIGN KEY([NoRapportCategorie])
REFERENCES [dbo].[RapportCategories] ([NoRapportCategorie])
GO
ALTER TABLE [dbo].[RapportTypes] CHECK CONSTRAINT [FK_RapportTypes_RapportCategories]
GO
ALTER TABLE [dbo].[SearchList]  WITH NOCHECK ADD  CONSTRAINT [FK_SearchList_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SearchList] CHECK CONSTRAINT [FK_SearchList_Utilisateurs]
GO
ALTER TABLE [dbo].[SoftwareNewsUsers]  WITH CHECK ADD  CONSTRAINT [FK_SoftwareNewsUsers_SoftwareNews] FOREIGN KEY([NoSoftwareNews])
REFERENCES [dbo].[SoftwareNews] ([NoSoftwareNews])
GO
ALTER TABLE [dbo].[SoftwareNewsUsers] CHECK CONSTRAINT [FK_SoftwareNewsUsers_SoftwareNews]
GO
ALTER TABLE [dbo].[SoftwareNewsUsers]  WITH CHECK ADD  CONSTRAINT [FK_SoftwareNewsUsers_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SoftwareNewsUsers] CHECK CONSTRAINT [FK_SoftwareNewsUsers_Utilisateurs]
GO
ALTER TABLE [dbo].[StatFactures]  WITH CHECK ADD  CONSTRAINT [FK_StatFactures_EntitesPayeurs] FOREIGN KEY([NoEntitePayeur])
REFERENCES [dbo].[EntitesPayeurs] ([NoEntitePayeur])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_EntitesPayeurs]
GO
ALTER TABLE [dbo].[StatFactures]  WITH CHECK ADD  CONSTRAINT [FK_StatFactures_InfoClients] FOREIGN KEY([ParNoClient])
REFERENCES [dbo].[InfoClients] ([NoClient])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_InfoClients]
GO
ALTER TABLE [dbo].[StatFactures]  WITH CHECK ADD  CONSTRAINT [FK_StatFactures_KeyPeople] FOREIGN KEY([ParNoKp])
REFERENCES [dbo].[KeyPeople] ([NoKP])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_KeyPeople]
GO
ALTER TABLE [dbo].[StatFactures]  WITH CHECK ADD  CONSTRAINT [FK_StatFactures_KeyPeople1] FOREIGN KEY([NoKp])
REFERENCES [dbo].[KeyPeople] ([NoKP])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_KeyPeople1]
GO
ALTER TABLE [dbo].[StatFactures]  WITH NOCHECK ADD  CONSTRAINT [FK_StatFactures_ListeAction] FOREIGN KEY([NoAction])
REFERENCES [dbo].[ListeAction] ([NoAction])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_ListeAction]
GO
ALTER TABLE [dbo].[StatFactures]  WITH NOCHECK ADD  CONSTRAINT [FK_StatFactures_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_Utilisateurs]
GO
ALTER TABLE [dbo].[StatFactures]  WITH CHECK ADD  CONSTRAINT [FK_StatFactures_Utilisateurs1] FOREIGN KEY([NoUserFacture])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_Utilisateurs1]
GO
ALTER TABLE [dbo].[StatFactures]  WITH CHECK ADD  CONSTRAINT [FK_StatFactures_Utilisateurs2] FOREIGN KEY([ParNoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[StatFactures] CHECK CONSTRAINT [FK_StatFactures_Utilisateurs2]
GO
ALTER TABLE [dbo].[StatFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_StatFolders_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StatFolders] CHECK CONSTRAINT [FK_StatFolders_InfoFolders]
GO
ALTER TABLE [dbo].[StatFolders]  WITH NOCHECK ADD  CONSTRAINT [FK_StatFolders_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[StatFolders] CHECK CONSTRAINT [FK_StatFolders_Utilisateurs]
GO
ALTER TABLE [dbo].[StatPaiements]  WITH CHECK ADD  CONSTRAINT [FK_StatPaiements_EntitesPayeurs] FOREIGN KEY([NoEntitePayeur])
REFERENCES [dbo].[EntitesPayeurs] ([NoEntitePayeur])
GO
ALTER TABLE [dbo].[StatPaiements] CHECK CONSTRAINT [FK_StatPaiements_EntitesPayeurs]
GO
ALTER TABLE [dbo].[StatPaiements]  WITH NOCHECK ADD  CONSTRAINT [FK_StatPaiements_ListeAction] FOREIGN KEY([NoAction])
REFERENCES [dbo].[ListeAction] ([NoAction])
GO
ALTER TABLE [dbo].[StatPaiements] CHECK CONSTRAINT [FK_StatPaiements_ListeAction]
GO
ALTER TABLE [dbo].[StatPaiements]  WITH NOCHECK ADD  CONSTRAINT [FK_StatPaiements_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[StatPaiements] CHECK CONSTRAINT [FK_StatPaiements_Utilisateurs]
GO
ALTER TABLE [dbo].[StatVisites]  WITH NOCHECK ADD  CONSTRAINT [FK_StatVisites_InfoVisites] FOREIGN KEY([NoVisite])
REFERENCES [dbo].[InfoVisites] ([NoVisite])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[StatVisites] CHECK CONSTRAINT [FK_StatVisites_InfoVisites]
GO
ALTER TABLE [dbo].[StatVisites]  WITH NOCHECK ADD  CONSTRAINT [FK_StatVisites_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[StatVisites] CHECK CONSTRAINT [FK_StatVisites_Utilisateurs]
GO
ALTER TABLE [dbo].[UsersAlerts]  WITH CHECK ADD  CONSTRAINT [FK_UsersAlerts_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsersAlerts] CHECK CONSTRAINT [FK_UsersAlerts_Utilisateurs]
GO
ALTER TABLE [dbo].[UsersConnected]  WITH CHECK ADD  CONSTRAINT [FK_UsersConnected_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsersConnected] CHECK CONSTRAINT [FK_UsersConnected_Utilisateurs]
GO
ALTER TABLE [dbo].[Utilisateurs]  WITH NOCHECK ADD  CONSTRAINT [FK_Utilisateurs_ListeTypeEmploye] FOREIGN KEY([NoTypeEmploye])
REFERENCES [dbo].[ListeTypeEmploye] ([NoTypeEmploye])
GO
ALTER TABLE [dbo].[Utilisateurs] CHECK CONSTRAINT [FK_Utilisateurs_ListeTypeEmploye]
GO
ALTER TABLE [dbo].[Utilisateurs]  WITH NOCHECK ADD  CONSTRAINT [FK_Utilisateurs_Titres] FOREIGN KEY([NoTitre])
REFERENCES [dbo].[Titres] ([NoTitre])
GO
ALTER TABLE [dbo].[Utilisateurs] CHECK CONSTRAINT [FK_Utilisateurs_Titres]
GO
ALTER TABLE [dbo].[Utilisateurs]  WITH NOCHECK ADD  CONSTRAINT [FK_Utilisateurs_TypeUtilisateur] FOREIGN KEY([NoType])
REFERENCES [dbo].[TypeUtilisateur] ([NoType])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Utilisateurs] NOCHECK CONSTRAINT [FK_Utilisateurs_TypeUtilisateur]
GO
ALTER TABLE [dbo].[Utilisateurs]  WITH NOCHECK ADD  CONSTRAINT [FK_Utilisateurs_Villes] FOREIGN KEY([NoVille])
REFERENCES [dbo].[Villes] ([NoVille])
GO
ALTER TABLE [dbo].[Utilisateurs] CHECK CONSTRAINT [FK_Utilisateurs_Villes]
GO
ALTER TABLE [dbo].[Ventes]  WITH NOCHECK ADD  CONSTRAINT [FK_Ventes_Equipements] FOREIGN KEY([NoEquipement])
REFERENCES [dbo].[Equipements] ([NoEquipement])
GO
ALTER TABLE [dbo].[Ventes] CHECK CONSTRAINT [FK_Ventes_Equipements]
GO
ALTER TABLE [dbo].[Ventes]  WITH NOCHECK ADD  CONSTRAINT [FK_Ventes_InfoFolders] FOREIGN KEY([NoFolder])
REFERENCES [dbo].[InfoFolders] ([NoFolder])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Ventes] CHECK CONSTRAINT [FK_Ventes_InfoFolders]
GO
ALTER TABLE [dbo].[Ventes]  WITH CHECK ADD  CONSTRAINT [FK_Ventes_Utilisateurs] FOREIGN KEY([NoTRP])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
GO
ALTER TABLE [dbo].[Ventes] CHECK CONSTRAINT [FK_Ventes_Utilisateurs]
GO
ALTER TABLE [dbo].[WorkHours]  WITH NOCHECK ADD  CONSTRAINT [FK_WorkHours_Utilisateurs] FOREIGN KEY([NoUser])
REFERENCES [dbo].[Utilisateurs] ([NoUser])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WorkHours] CHECK CONSTRAINT [FK_WorkHours_Utilisateurs]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "FT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 134
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "FTT"
            Begin Extent = 
               Top = 6
               Left = 252
               Bottom = 121
               Right = 442
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 2730
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FolderTexteDates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FolderTexteDates'
GO
USE [master]
GO
ALTER DATABASE [ClinicaDev] SET  READ_WRITE 
GO
