-- Crear logins
CREATE LOGIN Usuario1 WITH PASSWORD = 'password123!';
CREATE LOGIN Usuario2 WITH PASSWORD = 'password123!';
CREATE LOGIN Usuario3 WITH PASSWORD = 'password123!';

-- Crear usuarios en la base de datos
USE NombreBaseDatos; -- Reemplaza NombreBaseDatos por el nombre de tu base de datos
CREATE USER Usuario1 FOR LOGIN Usuario1;
CREATE USER Usuario2 FOR LOGIN Usuario2;
CREATE USER Usuario3 FOR LOGIN Usuario3;

-- Otorgar permisos en MiTabla
GRANT INSERT, UPDATE, DELETE, ALTER, VIEW DEFINITION ON MiTabla TO Usuario1;
GRANT INSERT, UPDATE, DELETE, ALTER, VIEW DEFINITION ON MiTabla TO Usuario2;
GRANT INSERT, UPDATE, DELETE, ALTER, VIEW DEFINITION ON MiTabla TO Usuario3;

-- Crear un procedimiento almacenado
CREATE PROCEDURE MiProcedimiento
AS
BEGIN
    SELECT * FROM MiTabla;
END;
GO

-- Otorgar permisos de ejecución en el procedimiento almacenado
GRANT EXECUTE ON MiProcedimiento TO Usuario1;
GRANT EXECUTE ON MiProcedimiento TO Usuario2;
GRANT EXECUTE ON MiProcedimiento TO Usuario3;
