# TP07 - Base de Datos: Torneo de Fútbol

## 1. Descripción
Esta base de datos permite gestionar un torneo de fútbol. Guarda información sobre equipos, jugadores, planteles, torneos, partidos, estadios, árbitros, arbitrajes y goles.

## 2. Justificación de importancia
El sistema organiza información que normalmente estaría dispersa. Permite conocer qué equipos participan, qué jugadores pertenecen a cada plantel, cuándo y dónde se juegan los partidos, quiénes arbitran y qué goles se registraron.

## 3. Objetivos
- Registrar equipos y sus datos principales.
- Registrar jugadores y sus posiciones.
- Relacionar jugadores con sus equipos mediante planteles.
- Registrar torneos y temporadas.
- Registrar partidos, resultados y estadios.
- Registrar árbitros y sus funciones.
- Registrar los goles de cada partido.
- Permitir consultas mediante SQL.

## 4. Tablas
La base contiene 9 tablas:
1. equipos
2. estadios
3. jugadores
4. planteles
5. torneos
6. partidos
7. arbitros
8. arbitrajes
9. goles

## 5. Relaciones principales
- equipos -> planteles: un equipo puede tener muchos jugadores.
- jugadores -> planteles: un jugador puede estar registrado en distintos planteles a lo largo del tiempo.
- torneos -> partidos: un torneo tiene muchos partidos.
- estadios -> partidos: un estadio puede recibir muchos partidos.
- equipos -> partidos: un equipo puede aparecer como local o visitante.
- partidos -> arbitrajes -> arbitros: un partido puede tener varios árbitros.
- partidos -> goles -> jugadores: un partido puede tener varios goles y cada gol se asocia a un jugador.

## 6. Implementación en XAMPP/phpMyAdmin
imagen en el repositorio
![imagen PhpMyAdmin](imagen_PhpMyAdmin.png)

## 7. Git y GitHub
Crear un repositorio público y subir:
- `torneo_futbol.sql`
- `README.md`

Comandos:
```bash
git init
git add .
git commit -m "TP07 - Proyecto de Base de Datos"
git branch -M main
git remote add origin URL_DEL_REPOSITORIO
git push -u origin main
```

## 8. Declaración de uso de IA
Se utilizó ChatGPT como herramienta de apoyo para la ayuda en la solucion de problemas
