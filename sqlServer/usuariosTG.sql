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
GRANT INSERT, UPDATE, DELETE, ALTER, CONTROL ON MiTabla TO Usuario1;
GRANT INSERT, UPDATE, DELETE, ALTER, CONTROL ON MiTabla TO Usuario2;
GRANT INSERT, UPDATE, DELETE, ALTER, CONTROL ON MiTabla TO Usuario3;

-- Crear el trigger
CREATE TRIGGER MiTrigger
ON MiTabla
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Acciones del trigger
    PRINT 'Operación realizada en MiTabla';
END;





-- Revocar permisos en MiTabla
REVOKE INSERT, UPDATE, DELETE, ALTER, CONTROL ON MiTabla FROM Usuario1;
REVOKE INSERT, UPDATE, DELETE, ALTER, CONTROL ON MiTabla FROM Usuario2;
REVOKE INSERT, UPDATE, DELETE, ALTER, CONTROL ON MiTabla FROM Usuario3;





