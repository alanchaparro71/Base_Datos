# TP08 - Especificación de Requisitos y Consultas SQL
**Base de Datos 1 2026 - IPET 247**
**Proyecto personal: Base de datos "Torneo de Fútbol"**

---

## 1. Descripción del sistema

`torneo_futbol` es una base de datos relacional (MySQL/MariaDB, implementada en XAMPP y administrada con phpMyAdmin) que permite gestionar un torneo de fútbol. Almacena información sobre equipos, jugadores, planteles, torneos, partidos, estadios, árbitros, arbitrajes y goles.

**Propósito:** centralizar en un único lugar datos que normalmente estarían dispersos (planillas, mensajes, hojas de cálculo), para poder saber qué equipos participan, quiénes integran cada plantel, cuándo y dónde se juegan los partidos, quiénes los arbitran y qué goles se convirtieron.

**Alcance:** incluye el registro y la consulta de los datos del torneo. Quedan fuera del alcance de esta versión la interfaz gráfica de usuario, la venta de entradas, las tarjetas amarillas/rojas y las transferencias entre equipos con historial económico.

**Usuarios previstos:** organizador del torneo (administra los datos), árbitros/oficiales (consultan designaciones) y público o prensa (consultan resultados y estadísticas).

### Diagrama de la base de datos (Designer de phpMyAdmin)

![imagen PhpMyAdmin](imagen_PhpMyAdmin.png)

### Tablas

| Tabla | Descripción |
|---|---|
| `equipos` | Equipos participantes (nombre único, ciudad, fecha de fundación). |
| `estadios` | Estadios donde se juegan los partidos (ciudad y capacidad). |
| `jugadores` | Datos personales y posición de cada jugador. |
| `planteles` | Relaciona jugadores con equipos, con número de camiseta y fecha de alta. |
| `torneos` | Torneos por temporada, con fechas de inicio y fin. |
| `partidos` | Partidos de un torneo: estadio, fecha/hora, equipo local, visitante y goles. |
| `arbitros` | Datos de los árbitros y su categoría. |
| `arbitrajes` | Relaciona árbitros con partidos y su rol (Principal, Asistente, etc.). |
| `goles` | Cada gol: partido, jugador, minuto y tipo. |

---

## 2. Requisitos Funcionales (orientados a los datos)

Cada requisito tiene un ID único, una redacción formal, reglas de negocio y criterios de aceptación, siguiendo la guía de ERS de la cátedra. La prioridad usa el método MoSCoW (M = Must have, S = Should have).

### RF-01: Registro de equipos y estadios (M)
- **Formato (User Story):** "Como organizador del torneo, quiero registrar los equipos y los estadios, para poder programar partidos."
- **Reglas de negocio:** el nombre de un equipo no puede repetirse; todo equipo y todo estadio debe tener ciudad; la capacidad de un estadio es obligatoria.
- **Criterios de aceptación:** al intentar cargar un equipo con un nombre ya existente, la base de datos rechaza la inserción (restricción `UNIQUE`).

### RF-02: Registro de jugadores y armado de planteles (M)
- **Formato (Caso de uso resumido):** "El sistema permite al organizador registrar un jugador con sus datos personales y su posición, y asociarlo a un equipo con un número de camiseta y una fecha de alta."
- **Reglas de negocio:** un jugador no puede estar dos veces en el plantel del mismo equipo; dos jugadores del mismo equipo no pueden tener el mismo número de camiseta; un jugador puede pasar por distintos equipos a lo largo del tiempo.
- **Criterios de aceptación:** al cargar un número de camiseta repetido dentro de un mismo equipo, la inserción es rechazada (`UNIQUE (id_equipo, numero_camiseta)`).

### RF-03: Registro de torneos y partidos (M)
- **Formato (EARS):** "Cuando el organizador programe un partido, el sistema deberá guardar el torneo, el estadio, la fecha y hora, el equipo local y el equipo visitante."
- **Reglas de negocio:** un equipo no puede jugar contra sí mismo; los goles de cada equipo no pueden ser negativos (por defecto 0); un torneo no puede repetirse con el mismo nombre en la misma temporada.
- **Criterios de aceptación:** un partido con `equipo_local = equipo_visitante` o con goles negativos es rechazado (restricciones `CHECK`).

### RF-04: Designación de árbitros por partido (M)
- **Formato (User Story):** "Como organizador, quiero asignar uno o más árbitros a cada partido indicando su rol, para saber quién dirigió cada encuentro."
- **Reglas de negocio:** un partido puede tener varios árbitros; un mismo árbitro no puede aparecer dos veces en el mismo partido.
- **Criterios de aceptación:** al asignar dos veces el mismo árbitro al mismo partido, la inserción es rechazada (`UNIQUE (id_partido, id_arbitro)`).

### RF-05: Registro de los goles de cada partido (M)
- **Formato (EARS):** "Cuando se convierta un gol, el sistema deberá registrar el partido, el jugador que lo convirtió, el minuto y el tipo de gol (por defecto 'Normal')."
- **Reglas de negocio:** el minuto debe estar entre 1 y 130 (incluye tiempo adicional y suplementario); todo gol se asocia a un partido y a un jugador existentes.
- **Criterios de aceptación:** un gol con minuto 0 o mayor a 130 es rechazado (restricción `CHECK`); un gol con un `id_jugador` inexistente es rechazado (clave foránea).

### RF-06: Consulta de estadísticas y posiciones (S)
- **Formato (Caso de uso resumido):** "El sistema permite consultar la tabla de posiciones, el ranking de goleadores, los planteles y la designación arbitral mediante sentencias SQL."
- **Criterios de aceptación:** las 10 consultas de la sección siguiente se ejecutan sin errores en phpMyAdmin y devuelven los datos esperados.

---

## 3. Listado descriptivo de consultas principales

Cada consulta está implementada en el archivo [`consultas.sql`](consultas.sql) con el mismo número.

| N° | Consulta en lenguaje natural | Herramientas SQL |
|---|---|---|
| 1 | Listar los equipos de la ciudad de Mendoza, ordenados alfabéticamente por nombre. | `WHERE`, `ORDER BY` |
| 2 | Listar los estadios con capacidad mayor a 15.000 espectadores, ordenados de mayor a menor capacidad. | `WHERE`, `ORDER BY` |
| 3 | Listar los jugadores que juegan de Delantero o Mediocampista y nacieron a partir de 2004, ordenados por apellido y nombre. | `WHERE` (`IN`, `AND`), `ORDER BY` |
| 4 | Mostrar el plantel de cada equipo (equipo, jugador, posición y número de camiseta), ordenado por equipo y camiseta. | `INNER JOIN` (3 tablas) |
| 5 | Listar todos los partidos con torneo, fecha y hora, estadio, equipo local, equipo visitante y resultado, del más reciente al más antiguo. | `INNER JOIN` (5 tablas, `equipos` con dos alias) |
| 6 | Obtener la terna arbitral de cada partido (árbitro, categoría y rol), ordenada por partido y rol. | `INNER JOIN` (3 tablas) |
| 7 | ¿Cuántos jugadores tiene registrados cada equipo en su plantel? Incluir equipos sin jugadores, de mayor a menor cantidad. | `LEFT JOIN`, `COUNT`, `GROUP BY` |
| 8 | Obtener el ranking de los 5 máximos goleadores, con su total de goles y el minuto promedio en que convirtieron. | `JOIN`, `COUNT`, `AVG`, `GROUP BY`, `LIMIT` |
| 9 | Para cada estadio, mostrar cuántos partidos se jugaron, el total de goles y el promedio de goles por partido. | `JOIN`, `COUNT`, `SUM`, `AVG`, `GROUP BY` |
| 10 | Obtener la tabla de posiciones de la "Copa Cuyo" 2026 (partidos jugados, goles a favor y en contra, diferencia y puntos: victoria 3, empate 1, derrota 0). | Subconsulta con `UNION ALL`, `JOIN`, `SUM`, `CASE`, `GROUP BY` |

---

## 4. Cómo ejecutar el proyecto

1. Iniciar **Apache** y **MySQL** desde el panel de control de XAMPP.
2. Abrir `http://localhost/phpmyadmin`.
3. Importar (pestaña *Importar*) el archivo `torneo_futbol.sql` del TP07 para crear la base y cargar los datos de ejemplo.
4. Abrir la pestaña *SQL*, pegar el contenido de `consultas.sql` y ejecutar cada consulta (o seleccionarlas de a una para ver cada resultado por separado).

---
## 5. Ficha de Declaración de IA

| Herramienta | Propósito | Prompt utilizado |
|---|---|---|
| Claude (Anthropic) | Redacción de los requisitos funcionales, del listado de consultas en lenguaje natural y de las 10 sentencias SQL comentadas. | "puedes revisar y decirme que me falta para completar con las consignas del tp8" (adjuntando la consigna del TP08, la guía de ERS, el archivo `torneo_futbol.sql`, el README del TP07 y la imagen del diseñador de phpMyAdmin). |
