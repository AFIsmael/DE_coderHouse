--Consigna

-- En las últimas décadas el cambio climático ha hecho que muchas personas se cuestionen si seguiremos 
-- existiendo como raza humana. Es por esto que desde el panel por el cambio climático (IPCC)
-- se han hecho proyecciones climáticas de cómo podrían cambiar algunos parámetros como la temperatura,
-- nivel de oxígeno así como de desastres (Tsunamis, Olas de Calor, Terremotos, Incendios)
-- entre el 2023-2030 y cantidad de muertes por rangos de edad. 

-- Este panel se reúne cada cuatro años y quiere que dejes almacenado un procedimiento llamado pETL_Desastres
-- que permita cuantificar el cambio promedio en Temperatura y Oxígeno así como la suma total de los otros eventos
-- mencionados por cuatrienios (2023-2026 y 2027-2030) llenando una tabla denominada DESASTRES_FINAL
-- en una base de datos llamada DESASTRES_BDE.



-- 1.crear base de datos
CREATE DATABASE DESASTRES;
GO
--
USE DESASTRES  
GO


-- 2. crear tabla clima futuro global
CREATE TABLE clima
(año INT NOT NULL PRIMARY KEY,
Temperatura FLOAT NOT NULL,
Oxigeno FLOAT NOT NULL);
GO

-- Insertar valores manualmente
INSERT INTO clima VALUES (2023, 22.5,230);
INSERT INTO clima VALUES (2024, 22.7,228.6);
INSERT INTO clima VALUES (2025, 22.9,227.5);
INSERT INTO clima VALUES (2026, 23.1,226.7);
INSERT INTO clima VALUES (2027, 23.2,226.4);
INSERT INTO clima VALUES (2028, 23.4,226.2);
INSERT INTO clima VALUES (2029, 23.6,226.1);
INSERT INTO clima VALUES (2030, 23.8,225.1);

-- 3. crear tabla desastres proyectados globales
CREATE TABLE desastres
(año INT NOT NULL PRIMARY KEY,
Tsunamis INT NOT NULL,
Olas_Calor INT NOT NULL,
Terremotos INT NOT NULL,
Erupciones INT NOT NULL,
Incendios INT NOT NULL);
GO
-- Insertar valores manualmente
INSERT INTO desastres VALUES (2023, 2,15, 6,7,50);
INSERT INTO desastres VALUES (2024, 1,12, 8,9,46);
INSERT INTO desastres VALUES (2025, 3,16, 5,6,47);
INSERT INTO desastres VALUES (2026, 4,12, 10,13,52);
INSERT INTO desastres VALUES (2027, 5,12, 6,5,41);
INSERT INTO desastres VALUES (2028, 4,18, 3,2,39);
INSERT INTO desastres VALUES (2029, 2,19, 5,6,49);
INSERT INTO desastres VALUES (2030, 4,20, 6,7,50);

-- 4. crear tabla muertes proyectadas por rangos de edad
CREATE TABLE muertes
(año INT NOT NULL PRIMARY KEY,
R_Menor15 INT NOT NULL,
R_15_a_30 INT NOT NULL,
R_30_a_45 INT NOT NULL,
R_45_a_60 INT NOT NULL,
R_M_a_60 INT NOT NULL);
GO
-- Insertar valores manualmente
INSERT INTO muertes VALUES (2023, 1000,1300, 1200,1150,1500);
INSERT INTO muertes VALUES (2024, 1200,1250, 1260,1678,1940);
INSERT INTO muertes VALUES (2025, 987,1130, 1160,1245,1200);
INSERT INTO muertes VALUES (2026, 1560,1578, 1856,1988,1245);
INSERT INTO muertes VALUES (2027, 1002,943, 1345,1232,986);
INSERT INTO muertes VALUES (2028, 957,987, 1856,1567,1756);
INSERT INTO muertes VALUES (2029, 1285,1376, 1465,1432,1236);
INSERT INTO muertes VALUES (2030, 1145,1456, 1345,1654,1877);

-- 5. Crear base de datos para alojar resumenes de estadisticas
CREATE DATABASE DESASTRES_BDE;
GO

USE DESASTRES_BDE
GO

CREATE TABLE DESASTRES_FINAL
(Cuatrenio varchar(20) NOT NULL PRIMARY KEY,
Temp_AVG FLOAT NOT NULL, Oxi_AVG FLOAT NOT NULL,
T_Tsunamis INT NOT NULL, T_OlasCalor INT NOT NULL,
T_Terremotos INT NOT NULL, T_Erupciones INT NOT NULL, 
T_Incendios INT NOT NULL,M_Jovenes_AVG FLOAT NOT NULL,
M_Adutos_AVG FLOAT NOT NULL,M_Ancianos_AVG FLOAT NOT NULL);
GO


--6. Crear un procedimiento almacenado para el ETL
USE DESASTRES
GO
--- es la tecnica mas sencilla (aclarado y rellenado) pero no es la unica tecnica (e.g actualizacion)

CREATE PROCEDURE pETL_Desastres
AS
DELETE FROM DESASTRES_BDE.dbo.DESASTRES_FINAL;
INSERT INTO DESASTRES_BDE.dbo.DESASTRES_FINAL
SELECT 
    CASE 
        WHEN c.año BETWEEN 2023 AND 2026 THEN '2023-2026' 
        WHEN c.año BETWEEN 2027 AND 2030 THEN '2027-2030' 
    END AS cuatrenio,
    AVG(c.Oxigeno) as AvgOxigeno,
    AVG(c.Temperatura) as AvgTemp,
    SUM(d.Tsunamis) as TTsunamis,
    SUM(d.Olas_Calor) as TOCalor,
    SUM(d.Terremotos)as TTerremotos,
    SUM(d.Erupciones)as TErupciones,
    SUM(d.Incendios)as TIncendios,
    AVG(R_Menor15) as MJovenes, 
    AVG(R_15_a_30 + R_30_a_45) as MAdulutos,
    AVG(R_45_a_60 + R_M_a_60)as MAncianos
FROM DESASTRES.dbo.clima as c
JOIN DESASTRES.dbo.desastres as d ON c.año =d.año
JOIN DESASTRES.dbo.muertes as m ON c.año = m.año
WHERE c.año BETWEEN 2023 AND 2030
GROUP BY 
    CASE 
        WHEN c.año BETWEEN 2023 AND 2026 THEN '2023-2026' 
        WHEN c.año BETWEEN 2027 AND 2030 THEN '2027-2030' 
    END;

-- ir a Programatically>> Stores Procedures y verificar que se creo el procedimeinto

--7. Executar procedimeinto
EXECUTE pETL_Desastres;
GO

-- 8. Verificar que se tiene el resultado
USE DESASTRES_BDE

SELECT * FROM DESASTRES_FINAL
GO