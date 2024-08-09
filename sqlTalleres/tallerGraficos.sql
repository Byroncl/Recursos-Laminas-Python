create database grafi;
use grafi;
-- Crear tabla para el gráfico spider
CREATE TABLE SpiderChartData (
    Estudiantes VARCHAR(50),
    Matematicas FLOAT,
    Fisica FLOAT,
    Quimica FLOAT,
    Literatura FLOAT,
    Arte FLOAT
);

-- Insertar datos de ejemplo en la tabla SpiderChartData
INSERT INTO SpiderChartData (Estudiantes, Matematicas, Fisica, Quimica, Literatura, Arte)
VALUES
('byron', 4.1, 3.4, 5.5, 2.3, 4.8),
('gregorio', 3.2, 4.5, 2.5, 5.3, 3.8),
('calderon', 5.2, 3.5, 4.5, 3.3, 2.8);

-- Crear tabla para el gráfico de barras
CREATE TABLE BarChartData (
    Candidatos VARCHAR(50),
    Sierra FLOAT,
    Costa FLOAT
);

-- Insertar datos de ejemplo en la tabla BarChartData
INSERT INTO BarChartData (Candidatos, Sierra, Costa)
VALUES
('byron', 7.1, 3.4),
('calderon', 6.2, 4.1),
('lopez', 5.2, 5.5);

-- Crear tabla para el gráfico de pastel
CREATE TABLE PieChartData (
    Candidatos VARCHAR(50),
    Votos FLOAT
);

-- Insertar datos de ejemplo en la tabla PieChartData
INSERT INTO PieChartData (Candidatos, Votos)
VALUES
('byron', 50),
('calderon', 30),
('lopez', 20);
