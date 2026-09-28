USE torneo_futbol2;

-- ---------------------------------------------------------------------
-- CONSULTA 1
-- Pregunta: Listar los equipos de la ciudad de Mendoza, ordenados
--           alfabéticamente por nombre.
-- Herramientas: WHERE + ORDER BY
-- ---------------------------------------------------------------------
SELECT
    id_equipo,
    nombre,
    ciudad,
    fecha_fundacion
FROM equipos
WHERE ciudad = 'Mendoza'
ORDER BY nombre ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 2
-- Pregunta: Listar los estadios con capacidad mayor a 15.000
--           espectadores, ordenados de mayor a menor capacidad.
-- Herramientas: WHERE + ORDER BY
-- ---------------------------------------------------------------------
SELECT
    id_estadio,
    nombre,
    ciudad,
    capacidad
FROM estadios
WHERE capacidad > 15000
ORDER BY capacidad DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 3
-- Pregunta: Listar los jugadores que juegan de Delantero o
--           Mediocampista y nacieron a partir del año 2004, ordenados
--           por apellido y nombre.
-- Herramientas: WHERE con IN y AND + ORDER BY con dos columnas
-- ---------------------------------------------------------------------
SELECT
    id_jugador,
    nombre,
    apellido,
    posicion,
    fecha_nacimiento
FROM jugadores
WHERE posicion IN ('Delantero', 'Mediocampista')
  AND fecha_nacimiento >= '2004-01-01'
ORDER BY apellido ASC, nombre ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 4
-- Pregunta: Mostrar el plantel de cada equipo (nombre del equipo,
--           jugador, posición y número de camiseta), ordenado por
--           equipo y número de camiseta.
-- Herramientas: INNER JOIN de 3 tablas (planteles, equipos, jugadores)
-- ---------------------------------------------------------------------
SELECT
    e.nombre           AS equipo,
    pl.numero_camiseta AS camiseta,
    j.nombre           AS nombre_jugador,
    j.apellido         AS apellido_jugador,
    j.posicion
FROM planteles pl
INNER JOIN equipos   e ON pl.id_equipo  = e.id_equipo
INNER JOIN jugadores j ON pl.id_jugador = j.id_jugador
ORDER BY e.nombre ASC, pl.numero_camiseta ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 5
-- Pregunta: Listar todos los partidos jugados con el torneo, la fecha
--           y hora, el estadio, el equipo local, el equipo visitante y
--           el resultado, del más reciente al más antiguo.
-- Herramientas: INNER JOIN de 5 tablas (la tabla equipos se une dos
--               veces con alias: una para el local y otra para el
--               visitante) + ORDER BY
-- ---------------------------------------------------------------------
SELECT
    p.id_partido,
    t.nombre      AS torneo,
    p.fecha_hora,
    es.nombre     AS estadio,
    el.nombre     AS equipo_local,
    ev.nombre     AS equipo_visitante,
    CONCAT(p.goles_local, ' - ', p.goles_visitante) AS resultado
FROM partidos p
INNER JOIN torneos  t  ON p.id_torneo        = t.id_torneo
INNER JOIN estadios es ON p.id_estadio       = es.id_estadio
INNER JOIN equipos  el ON p.equipo_local     = el.id_equipo
INNER JOIN equipos  ev ON p.equipo_visitante = ev.id_equipo
ORDER BY p.fecha_hora DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 6
-- Pregunta: Obtener la terna arbitral de cada partido (partido,
--           fecha, nombre del árbitro, categoría y rol que cumplió),
--           ordenada por partido y rol.
-- Herramientas: INNER JOIN de 3 tablas (arbitrajes, partidos, arbitros)
-- ---------------------------------------------------------------------
SELECT
    p.id_partido,
    p.fecha_hora,
    CONCAT(a.nombre, ' ', a.apellido) AS arbitro,
    a.categoria,
    ar.rol
FROM arbitrajes ar
INNER JOIN partidos p ON ar.id_partido = p.id_partido
INNER JOIN arbitros a ON ar.id_arbitro = a.id_arbitro
ORDER BY p.id_partido ASC, ar.rol ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 7
-- Pregunta: ¿Cuántos jugadores tiene registrados cada equipo en su
--           plantel? Incluir también los equipos sin jugadores y
--           ordenar de mayor a menor cantidad.
-- Herramientas: LEFT JOIN + COUNT + GROUP BY + ORDER BY
-- Nota: COUNT(pl.id_jugador) no cuenta los NULL, por eso un equipo sin
--       plantel aparece con 0.
-- ---------------------------------------------------------------------
SELECT
    e.nombre                AS equipo,
    COUNT(pl.id_jugador)    AS cantidad_jugadores
FROM equipos e
LEFT JOIN planteles pl ON e.id_equipo = pl.id_equipo
GROUP BY e.id_equipo, e.nombre
ORDER BY cantidad_jugadores DESC, e.nombre ASC;


-- ---------------------------------------------------------------------
-- CONSULTA 8
-- Pregunta: Obtener el ranking de goleadores: los 5 jugadores que más
--           goles convirtieron, con la cantidad total de goles y el
--           minuto promedio en que convirtieron.
-- Herramientas: INNER JOIN + COUNT + AVG + GROUP BY + ORDER BY + LIMIT
-- ---------------------------------------------------------------------
SELECT
    j.id_jugador,
    CONCAT(j.nombre, ' ', j.apellido) AS jugador,
    COUNT(g.id_gol)                   AS total_goles,
    ROUND(AVG(g.minuto), 1)           AS minuto_promedio
FROM goles g
INNER JOIN jugadores j ON g.id_jugador = j.id_jugador
GROUP BY j.id_jugador, j.nombre, j.apellido
ORDER BY total_goles DESC, jugador ASC
LIMIT 5;


-- ---------------------------------------------------------------------
-- CONSULTA 9
-- Pregunta: Para cada estadio, mostrar cuántos partidos se jugaron,
--           el total de goles convertidos y el promedio de goles por
--           partido, ordenado del estadio más goleador al menos
--           goleador.
-- Herramientas: INNER JOIN + COUNT + SUM + AVG + GROUP BY + ORDER BY
-- ---------------------------------------------------------------------
SELECT
    es.nombre                                        AS estadio,
    COUNT(p.id_partido)                              AS partidos_jugados,
    SUM(p.goles_local + p.goles_visitante)           AS total_goles,
    ROUND(AVG(p.goles_local + p.goles_visitante), 2) AS promedio_goles_por_partido
FROM partidos p
INNER JOIN estadios es ON p.id_estadio = es.id_estadio
GROUP BY es.id_estadio, es.nombre
ORDER BY promedio_goles_por_partido DESC;


-- ---------------------------------------------------------------------
-- CONSULTA 10 (avanzada)
-- Pregunta: Obtener la tabla de posiciones del torneo "Copa Cuyo"
--           2026 con partidos jugados, goles a favor, goles en contra,
--           diferencia de gol y puntos (victoria = 3, empate = 1,
--           derrota = 0), ordenada por puntos, luego diferencia de
--           gol y luego goles a favor.
-- Herramientas: subconsulta con UNION ALL (cada partido se cuenta una
--               vez para el local y otra para el visitante) + JOIN +
--               WHERE + COUNT + SUM + CASE + GROUP BY + ORDER BY
-- ---------------------------------------------------------------------
SELECT
    e.nombre                                   AS equipo,
    COUNT(*)                                   AS partidos_jugados,
    SUM(r.goles_favor)                         AS goles_favor,
    SUM(r.goles_contra)                        AS goles_contra,
    SUM(r.goles_favor - r.goles_contra)        AS diferencia_gol,
    SUM(CASE
            WHEN r.goles_favor > r.goles_contra THEN 3
            WHEN r.goles_favor = r.goles_contra THEN 1
            ELSE 0
        END)                                   AS puntos
FROM (
    -- Vista de cada partido desde el punto de vista del equipo local
    SELECT id_torneo,
           equipo_local     AS id_equipo,
           goles_local      AS goles_favor,
           goles_visitante  AS goles_contra
    FROM partidos
    UNION ALL
    -- Vista de cada partido desde el punto de vista del equipo visitante
    SELECT id_torneo,
           equipo_visitante AS id_equipo,
           goles_visitante  AS goles_favor,
           goles_local      AS goles_contra
    FROM partidos
) AS r
INNER JOIN equipos e ON r.id_equipo = e.id_equipo
INNER JOIN torneos t ON r.id_torneo = t.id_torneo
WHERE t.nombre = 'Copa Cuyo'
  AND t.temporada = 2026
GROUP BY e.id_equipo, e.nombre
ORDER BY puntos DESC, diferencia_gol DESC, goles_favor DESC;
