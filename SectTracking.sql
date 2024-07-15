USE SectTracking;
GO

-- Écrire une procédure qui affiche le nombre d'adhérents par secte
DROP PROCEDURE IF EXISTS sp_GetAdherentsCountBySect;
GO

CREATE PROCEDURE sp_GetAdherentsCountBySect
AS
BEGIN
    SELECT s.name, COUNT(a.adherent_id) AS AdherentCount
    FROM Adherent AS a
    JOIN SectAdherent AS sa ON sa.FK_adherent_id = a.adherent_id
    JOIN Sect AS s ON s.sect_id = sa.FK_sect_id
    GROUP BY s.name;
END
GO

-- Insérer une relation secte-adhérent si elle n'existe pas
DROP PROCEDURE IF EXISTS sp_InsertIfNotAlreadyIn;
GO

CREATE PROCEDURE sp_InsertIfNotAlreadyIn
    @adherent_id INT,
    @sect_id INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM SectAdherent AS s 
        WHERE s.FK_adherent_id = @adherent_id AND s.FK_sect_id = @sect_id
    )
    BEGIN
        INSERT INTO SectAdherent (FK_adherent_id, FK_sect_id) 
        VALUES (@adherent_id, @sect_id);
    END
END
GO

-- Écrire une procédure qui associe chacun des adhérents à chacune des sectes
DROP PROCEDURE IF EXISTS sp_AssociateEachAdherentToEachSect;
GO

CREATE PROCEDURE sp_AssociateEachAdherentToEachSect
AS
BEGIN
    DECLARE @sect_id INT;
    DECLARE @adherent_id INT;

    DECLARE sect_cursor CURSOR FOR
    SELECT sect_id FROM Sect;

    OPEN sect_cursor;
    FETCH NEXT FROM sect_cursor INTO @sect_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE adherent_cursor CURSOR FOR
        SELECT adherent_id FROM Adherent;

        OPEN adherent_cursor;
        FETCH NEXT FROM adherent_cursor INTO @adherent_id;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXECUTE sp_InsertIfNotAlreadyIn @adherent_id, @sect_id;
            FETCH NEXT FROM adherent_cursor INTO @adherent_id;
        END;

        CLOSE adherent_cursor;
        DEALLOCATE adherent_cursor;

        FETCH NEXT FROM sect_cursor INTO @sect_id;
    END;

    CLOSE sect_cursor;
    DEALLOCATE sect_cursor;
END
GO

-- Exécuter la procédure pour associer chaque adhérent à chaque secte
EXECUTE sp_AssociateEachAdherentToEachSect;
GO

-- Exécuter la procédure pour afficher le nombre d'adhérents par secte
EXECUTE sp_GetAdherentsCountBySect;
GO

-- Écrire une procédure qui retourne le nombre de sectes dans un argument de sortie
DROP PROCEDURE IF EXISTS sp_GetSectsCountForSect;
GO

CREATE PROCEDURE sp_GetSectsCountForSect
    @SectsCount INT OUTPUT
AS
BEGIN
    SELECT @SectsCount = COUNT(sect_id) FROM Sect;
END
GO

-- Déclarer une variable pour récupérer le nombre de sectes et l'afficher
DECLARE @SectsCount INT;
EXECUTE sp_GetSectsCountForSect @SectsCount = @SectsCount OUTPUT;
PRINT @SectsCount;
GO
