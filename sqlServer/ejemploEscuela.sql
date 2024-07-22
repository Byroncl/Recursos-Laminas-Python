-- Crear la base de datos
CREATE DATABASE Escuela;
GO

-- Usar la base de datos
USE Escuela;
GO

-- Crear tabla de Estudiantes
CREATE TABLE Estudiantes (
    EstudianteID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    FechaNacimiento DATE,
    Genero CHAR(1),
    Estado NVARCHAR(50) DEFAULT 'Activo'
);
GO

-- Crear tabla de Profesores
CREATE TABLE Profesores (
    ProfesorID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    Especialidad NVARCHAR(100)
);
GO

-- Crear tabla de Cursos
CREATE TABLE Cursos (
    CursoID INT PRIMARY KEY IDENTITY(1,1),
    NombreCurso NVARCHAR(100),
    Descripcion NVARCHAR(255),
    ProfesorID INT,
    FOREIGN KEY (ProfesorID) REFERENCES Profesores(ProfesorID)
);
GO

-- Crear tabla de Inscripciones
CREATE TABLE Inscripciones (
    InscripcionID INT PRIMARY KEY IDENTITY(1,1),
    EstudianteID INT,
    CursoID INT,
    FechaInscripcion DATE,
    Promedio DECIMAL(3, 2),
    Faltas INT,
    FOREIGN KEY (EstudianteID) REFERENCES Estudiantes(EstudianteID),
    FOREIGN KEY (CursoID) REFERENCES Cursos(CursoID)
);
GO

-- Crear tabla de Asistencias
CREATE TABLE Asistencias (
    AsistenciaID INT PRIMARY KEY IDENTITY(1,1),
    EstudianteID INT,
    CursoID INT,
    Fecha DATE,
    Asistio BIT,
    FOREIGN KEY (EstudianteID) REFERENCES Estudiantes(EstudianteID),
    FOREIGN KEY (CursoID) REFERENCES Cursos(CursoID)
);
GO

-- Insertar datos en la tabla Estudiantes
INSERT INTO Estudiantes (Nombre, Apellido, FechaNacimiento, Genero)
VALUES 
('Juan', 'Perez', '2005-01-15', 'M'),
('Maria', 'Lopez', '2006-03-22', 'F'),
('Carlos', 'Sanchez', '2004-05-10', 'M');

-- Insertar datos en la tabla Profesores
INSERT INTO Profesores (Nombre, Apellido, Especialidad)
VALUES 
('Ana', 'Gomez', 'Matemáticas'),
('Luis', 'Martinez', 'Ciencias');

-- Insertar datos en la tabla Cursos
INSERT INTO Cursos (NombreCurso, Descripcion, ProfesorID)
VALUES 
('Matemáticas 1', 'Curso de Matemáticas Básicas', 1),
('Ciencias 1', 'Curso de Ciencias Naturales', 2);

-- Insertar datos en la tabla Inscripciones
INSERT INTO Inscripciones (EstudianteID, CursoID, FechaInscripcion, Promedio, Faltas)
VALUES 
(1, 1, '2023-09-01', 8.5, 5),
(2, 2, '2023-09-02', 6.8, 16),
(3, 1, '2023-09-03', 9.0, 3);

-- Insertar datos en la tabla Asistencias
INSERT INTO Asistencias (EstudianteID, CursoID, Fecha, Asistio)
VALUES 
(1, 1, '2023-09-01', 1),
(1, 1, '2023-09-02', 1),
(2, 2, '2023-09-01', 0),
(2, 2, '2023-09-02', 0),
(3, 1, '2023-09-01', 1);

-- Crear trigger para verificar la inscripción de estudiantes en cursos
CREATE TRIGGER trg_InsertInscripcion
ON Inscripciones
AFTER INSERT
AS
BEGIN
    DECLARE @EstudianteID INT;
    DECLARE @CursoID INT;
    
    SELECT @EstudianteID = INSERTED.EstudianteID, @CursoID = INSERTED.CursoID
    FROM INSERTED;

    -- Verificar que el estudiante no esté inscrito en más de 5 cursos
    IF (SELECT COUNT(*) FROM Inscripciones WHERE EstudianteID = @EstudianteID) > 5
    BEGIN
        RAISERROR('El estudiante no puede inscribirse en más de 5 cursos.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Crear trigger para auditar cambios en la tabla Estudiantes
CREATE TRIGGER trg_UpdateEstudiante
ON Estudiantes
AFTER UPDATE
AS
BEGIN
    DECLARE @EstudianteID INT;
    DECLARE @OldNombre NVARCHAR(100);
    DECLARE @NewNombre NVARCHAR(100);

    SELECT @EstudianteID = INSERTED.EstudianteID, @OldNombre = DELETED.Nombre, @NewNombre = INSERTED.Nombre
    FROM INSERTED
    JOIN DELETED ON INSERTED.EstudianteID = DELETED.EstudianteID;

    -- Insertar un registro en la tabla de auditoría (crea la tabla de auditoría si no existe)
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaEstudiantes')
    BEGIN
        CREATE TABLE AuditoriaEstudiantes (
            AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
            EstudianteID INT,
            FechaCambio DATETIME,
            NombreAnterior NVARCHAR(100),
            NombreNuevo NVARCHAR(100)
        );
    END

    INSERT INTO AuditoriaEstudiantes (EstudianteID, FechaCambio, NombreAnterior, NombreNuevo)
    VALUES (@EstudianteID, GETDATE(), @OldNombre, @NewNombre);
END;
GO

-- Crear trigger para actualizar el estado de los estudiantes según su promedio y faltas
CREATE TRIGGER trg_Estudiantes_Aprobacion
ON Inscripciones
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @EstudianteID INT;
    DECLARE @Promedio DECIMAL(3, 2);
    DECLARE @Faltas INT;

    SELECT @EstudianteID = INSERTED.EstudianteID, @Promedio = INSERTED.Promedio, @Faltas = INSERTED.Faltas
    FROM INSERTED;

    IF @Promedio < 7 OR @Faltas >= 15
    BEGIN
        UPDATE Estudiantes
        SET Estado = 'Desaprobado'
        WHERE EstudianteID = @EstudianteID;
    END
    ELSE
    BEGIN
        UPDATE Estudiantes
        SET Estado = 'Aprobado'
        WHERE EstudianteID = @EstudianteID;
    END
END;
GO

-- Crear trigger para actualizar el estado de los estudiantes según sus asistencias
CREATE TRIGGER trg_Estudiantes_Asistencias
ON Asistencias
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @EstudianteID INT;
    DECLARE @Faltas INT;

    -- Obtener el ID del estudiante afectado
    SELECT @EstudianteID = INSERTED.EstudianteID
    FROM INSERTED;

    -- Contar las faltas del estudiante en todos los cursos
    SELECT @Faltas = COUNT(*)
    FROM Asistencias
    WHERE EstudianteID = @EstudianteID AND Asistio = 0;

    -- Verificar si el estudiante tiene más de 10 faltas
    IF @Faltas > 10
    BEGIN
        UPDATE Estudiantes
        SET Estado = 'Desaprobado por Faltas'
        WHERE EstudianteID = @EstudianteID;
    END
END;
GO

-- Consultar todos los estudiantes y sus cursos
SELECT e.Nombre, e.Apellido, c.NombreCurso
FROM Estudiantes e
JOIN Inscripciones i ON e.EstudianteID = i.EstudianteID
JOIN Cursos c ON i.CursoID = c.CursoID;
GO

-- Consultar el número de estudiantes inscritos en cada curso
SELECT c.NombreCurso, COUNT(i.InscripcionID) AS NumeroEstudiantes
FROM Cursos c
LEFT JOIN Inscripciones i ON c.CursoID = i.CursoID
GROUP BY c.NombreCurso;
GO

-- Consultar todos los cursos y sus profesores
SELECT c.NombreCurso, p.Nombre AS ProfesorNombre, p.Apellido AS ProfesorApellido
FROM Cursos c
JOIN Profesores p ON c.ProfesorID = p.ProfesorID;
GO

-- Consultar la auditoría de cambios en la tabla Estudiantes
SELECT * FROM AuditoriaEstudiantes;
GO

-- Consultar el estado de los estudiantes
SELECT Nombre, Apellido, Estado
FROM Estudiantes;
GO


