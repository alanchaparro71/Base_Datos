CREATE DATABASE IF NOT EXISTS torneo_futbol;
USE torneo_futbol;

CREATE TABLE equipos (
    id_equipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    fecha_fundacion DATE,
    UNIQUE (nombre)
);

CREATE TABLE estadios (
    id_estadio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    capacidad INT NOT NULL
);

CREATE TABLE jugadores (
    id_jugador INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    fecha_nacimiento DATE,
    posicion VARCHAR(30) NOT NULL,
    nacionalidad VARCHAR(50) NOT NULL
);

CREATE TABLE planteles (
    id_plantel INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo INT NOT NULL,
    id_jugador INT NOT NULL,
    numero_camiseta INT NOT NULL,
    fecha_alta DATE NOT NULL,
    FOREIGN KEY (id_equipo) REFERENCES equipos(id_equipo),
    FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
    UNIQUE (id_equipo, id_jugador),
    UNIQUE (id_equipo, numero_camiseta)
);

CREATE TABLE torneos (
    id_torneo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    temporada YEAR NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    UNIQUE (nombre, temporada)
);

CREATE TABLE partidos (
    id_partido INT AUTO_INCREMENT PRIMARY KEY,
    id_torneo INT NOT NULL,
    id_estadio INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    equipo_local INT NOT NULL,
    equipo_visitante INT NOT NULL,
    goles_local INT NOT NULL DEFAULT 0,
    goles_visitante INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_torneo) REFERENCES torneos(id_torneo),
    FOREIGN KEY (id_estadio) REFERENCES estadios(id_estadio),
    FOREIGN KEY (equipo_local) REFERENCES equipos(id_equipo),
    FOREIGN KEY (equipo_visitante) REFERENCES equipos(id_equipo),
    CHECK (equipo_local <> equipo_visitante),
    CHECK (goles_local >= 0 AND goles_visitante >= 0)
);

CREATE TABLE arbitros (
    id_arbitro INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE arbitrajes (
    id_arbitraje INT AUTO_INCREMENT PRIMARY KEY,
    id_partido INT NOT NULL,
    id_arbitro INT NOT NULL,
    rol VARCHAR(30) NOT NULL,
    FOREIGN KEY (id_partido) REFERENCES partidos(id_partido),
    FOREIGN KEY (id_arbitro) REFERENCES arbitros(id_arbitro),
    UNIQUE (id_partido, id_arbitro)
);

CREATE TABLE goles (
    id_gol INT AUTO_INCREMENT PRIMARY KEY,
    id_partido INT NOT NULL,
    id_jugador INT NOT NULL,
    minuto INT NOT NULL,
    tipo VARCHAR(30) NOT NULL DEFAULT 'Normal',
    FOREIGN KEY (id_partido) REFERENCES partidos(id_partido),
    FOREIGN KEY (id_jugador) REFERENCES jugadores(id_jugador),
    CHECK (minuto BETWEEN 1 AND 130)
);

-- Datos de ejemplo para comprobar las relaciones
INSERT INTO equipos (nombre, ciudad, fecha_fundacion) VALUES
('Los Andes FC','Mendoza','2010-03-15'),
('Cuyo United','Mendoza','2012-08-20'),
('Cordoba Stars','Cordoba','2008-05-10'),
('Malbec FC','Mendoza','2015-11-02');

INSERT INTO estadios (nombre, ciudad, capacidad) VALUES
('Estadio Central','Mendoza',25000),
('Cancha Municipal','Mendoza',12000);

INSERT INTO jugadores (nombre, apellido, fecha_nacimiento, posicion, nacionalidad) VALUES
('Lucas','Perez','2004-04-10','Delantero','Argentina'),
('Mateo','Gomez','2005-09-22','Mediocampista','Argentina'),
('Santiago','Lopez','2003-01-17','Defensor','Argentina'),
('Nicolas','Diaz','2004-12-03','Arquero','Argentina');

INSERT INTO planteles (id_equipo,id_jugador,numero_camiseta,fecha_alta) VALUES
(1,1,9,'2026-01-10'),
(1,2,8,'2026-01-10'),
(2,3,4,'2026-01-12'),
(2,4,1,'2026-01-12');

INSERT INTO torneos (nombre,temporada,fecha_inicio,fecha_fin) VALUES
('Copa Cuyo',2026,'2026-08-01','2026-12-15');

INSERT INTO partidos
(id_torneo,id_estadio,fecha_hora,equipo_local,equipo_visitante,goles_local,goles_visitante)
VALUES
(1,1,'2026-08-20 18:00:00',1,2,2,1);

INSERT INTO arbitros (nombre,apellido,categoria) VALUES
('Juan','Martinez','Regional'),
('Pedro','Fernandez','Nacional');

INSERT INTO arbitrajes (id_partido,id_arbitro,rol) VALUES
(1,1,'Principal'),
(1,2,'Asistente');

INSERT INTO goles (id_partido,id_jugador,minuto,tipo) VALUES
(1,1,35,'Normal'),
(1,2,70,'Normal'),
(1,3,82,'Normal');

-- Consultas de ejemplo
SELECT * FROM equipos;

SELECT
    p.id_partido,
    t.nombre AS torneo,
    el.nombre AS local,
    ev.nombre AS visitante,
    p.goles_local,
    p.goles_visitante,
    p.fecha_hora
FROM partidos p
JOIN torneos t ON p.id_torneo = t.id_torneo
JOIN equipos el ON p.equipo_local = el.id_equipo
JOIN equipos ev ON p.equipo_visitante = ev.id_equipo;

SELECT
    j.nombre,
    j.apellido,
    e.nombre AS equipo,
    pl.numero_camiseta
FROM planteles pl
JOIN jugadores j ON pl.id_jugador = j.id_jugador
JOIN equipos e ON pl.id_equipo = e.id_equipo;
