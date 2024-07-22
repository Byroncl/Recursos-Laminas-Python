-- Crear la base de datos
CREATE DATABASE Empresa;
GO

-- Usar la base de datos
USE Empresa;
GO

-- Crear tabla de Empleados
CREATE TABLE Empleados (
    EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    FechaNacimiento DATE,
    FechaContratacion DATE,
    Salario DECIMAL(10, 2),
    DepartamentoID INT
);
GO

-- Crear tabla de Departamentos
CREATE TABLE Departamentos (
    DepartamentoID INT PRIMARY KEY IDENTITY(1,1),
    NombreDepartamento NVARCHAR(100)
);
GO

-- Crear tabla de Proyectos
CREATE TABLE Proyectos (
    ProyectoID INT PRIMARY KEY IDENTITY(1,1),
    NombreProyecto NVARCHAR(100),
    FechaInicio DATE,
    FechaFin DATE,
    Presupuesto DECIMAL(15, 2)
);
GO

-- Crear tabla de Asignaciones
CREATE TABLE Asignaciones (
    AsignacionID INT PRIMARY KEY IDENTITY(1,1),
    EmpleadoID INT,
    ProyectoID INT,
    FechaAsignacion DATE,
    HorasAsignadas INT,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
    FOREIGN KEY (ProyectoID) REFERENCES Proyectos(ProyectoID)
);
GO

-- Insertar datos en la tabla Departamentos
INSERT INTO Departamentos (NombreDepartamento)
VALUES 
('Recursos Humanos'),
('Desarrollo'),
('Marketing');

-- Insertar datos en la tabla Empleados
INSERT INTO Empleados (Nombre, Apellido, FechaNacimiento, FechaContratacion, Salario, DepartamentoID)
VALUES 
('Juan', 'Perez', '1980-01-15', '2010-06-01', 50000, 1),
('Maria', 'Lopez', '1985-03-22', '2012-08-15', 55000, 2),
('Carlos', 'Sanchez', '1990-05-10', '2015-09-10', 60000, 2),
('Ana', 'Martinez', '1982-07-18', '2011-11-20', 58000, 3);

-- Insertar datos en la tabla Proyectos
INSERT INTO Proyectos (NombreProyecto, FechaInicio, FechaFin, Presupuesto)
VALUES 
('Proyecto A', '2023-01-01', '2023-12-31', 100000),
('Proyecto B', '2023-02-01', '2023-11-30', 150000);

-- Insertar datos en la tabla Asignaciones
INSERT INTO Asignaciones (EmpleadoID, ProyectoID, FechaAsignacion, HorasAsignadas)
VALUES 
(1, 1, '2023-01-15', 100),
(2, 1, '2023-02-01', 150),
(3, 2, '2023-02-15', 200),
(4, 2, '2023-03-01', 120);

-- Crear trigger para verificar la asignación de empleados a proyectos
CREATE TRIGGER trg_InsertAsignacion
ON Asignaciones
AFTER INSERT
AS
BEGIN
    DECLARE @EmpleadoID INT;
    DECLARE @HorasTotales INT;

    SELECT @EmpleadoID = INSERTED.EmpleadoID
    FROM INSERTED;

    -- Verificar que el empleado no tenga más de 40 horas asignadas por semana
    SELECT @HorasTotales = SUM(HorasAsignadas)
    FROM Asignaciones
    WHERE EmpleadoID = @EmpleadoID AND DATEPART(WEEK, FechaAsignacion) = DATEPART(WEEK, GETDATE());

    IF @HorasTotales > 40
    BEGIN
        RAISERROR('El empleado no puede tener más de 40 horas asignadas por semana.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Crear trigger para auditar cambios en la tabla Empleados
CREATE TRIGGER trg_UpdateEmpleado
ON Empleados
AFTER UPDATE
AS
BEGIN
    DECLARE @EmpleadoID INT;
    DECLARE @OldSalario DECIMAL(10, 2);
    DECLARE @NewSalario DECIMAL(10, 2);

    SELECT @EmpleadoID = INSERTED.EmpleadoID, @OldSalario = DELETED.Salario, @NewSalario = INSERTED.Salario
    FROM INSERTED
    JOIN DELETED ON INSERTED.EmpleadoID = DELETED.EmpleadoID;

    -- Insertar un registro en la tabla de auditoría (crea la tabla de auditoría si no existe)
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaEmpleados')
    BEGIN
        CREATE TABLE AuditoriaEmpleados (
            AuditoriaID INT PRIMARY KEY IDENTITY(1,1),
            EmpleadoID INT,
            FechaCambio DATETIME,
            SalarioAnterior DECIMAL(10, 2),
            SalarioNuevo DECIMAL(10, 2)
        );
    END

    INSERT INTO AuditoriaEmpleados (EmpleadoID, FechaCambio, SalarioAnterior, SalarioNuevo)
    VALUES (@EmpleadoID, GETDATE(), @OldSalario, @NewSalario);
END;
GO

-- Crear trigger para verificar que el presupuesto del proyecto no se exceda
CREATE TRIGGER trg_VerificarPresupuesto
ON Asignaciones
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ProyectoID INT;
    DECLARE @Presupuesto DECIMAL(15, 2);
    DECLARE @CosteTotal DECIMAL(15, 2);

    SELECT @ProyectoID = INSERTED.ProyectoID
    FROM INSERTED;

    -- Calcular el coste total del proyecto
    SELECT @CosteTotal = SUM(a.HorasAsignadas * e.Salario / 2080)
    FROM Asignaciones a
    JOIN Empleados e ON a.EmpleadoID = e.EmpleadoID
    WHERE a.ProyectoID = @ProyectoID;

    -- Obtener el presupuesto del proyecto
    SELECT @Presupuesto = Presupuesto
    FROM Proyectos
    WHERE ProyectoID = @ProyectoID;

    IF @CosteTotal > @Presupuesto
    BEGIN
        RAISERROR('El presupuesto del proyecto ha sido excedido.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Consultar todos los empleados y sus asignaciones a proyectos
SELECT e.Nombre, e.Apellido, p.NombreProyecto, a.HorasAsignadas
FROM Empleados e
JOIN Asignaciones a ON e.EmpleadoID = a.EmpleadoID
JOIN Proyectos p ON a.ProyectoID = p.ProyectoID;
GO

-- Consultar el número de empleados en cada departamento
SELECT d.NombreDepartamento, COUNT(e.EmpleadoID) AS NumeroEmpleados
FROM Departamentos d
LEFT JOIN Empleados e ON d.DepartamentoID = e.DepartamentoID
GROUP BY d.NombreDepartamento;
GO

-- Consultar todos los proyectos y su presupuesto restante
SELECT p.NombreProyecto, p.Presupuesto - ISNULL(SUM(a.HorasAsignadas * e.Salario / 2080), 0) AS PresupuestoRestante
FROM Proyectos p
LEFT JOIN Asignaciones a ON p.ProyectoID = a.ProyectoID
LEFT JOIN Empleados e ON a.EmpleadoID = e.EmpleadoID
GROUP BY p.NombreProyecto, p.Presupuesto;
GO

-- Consultar la auditoría de cambios en la tabla Empleados
SELECT * FROM AuditoriaEmpleados;
GO
