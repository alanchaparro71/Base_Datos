"""
Sistema de Gestión de Pañol - TP N.º 9
Conexión MySQL en la nube y operaciones CRUD.
Configurar las variables en un archivo .env local (no subirlo a GitHub).
"""
import os
from datetime import date
import mysql.connector
from mysql.connector import Error

def cargar_env():
    """Carga variables sencillas desde .env sin depender de otra librería."""
    ruta = os.path.join(os.path.dirname(__file__), ".env")
    if os.path.exists(ruta):
        with open(ruta, "r", encoding="utf-8") as archivo:
            for linea in archivo:
                linea = linea.strip()
                if not linea or linea.startswith("#") or "=" not in linea:
                    continue
                clave, valor = linea.split("=", 1)
                os.environ.setdefault(clave.strip(), valor.strip().strip('"').strip("'"))

cargar_env()

CONFIG_BD = {
    "host": os.getenv("DB_HOST", ""),
    "user": os.getenv("DB_USER", ""),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "panol_herramientas"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "connection_timeout": 10,
}
if os.getenv("DB_SSL_CA"):
    CONFIG_BD["ssl_ca"] = os.getenv("DB_SSL_CA")

def conectar_bd():
    faltantes = [k for k, v in {
        "DB_HOST": CONFIG_BD["host"], "DB_USER": CONFIG_BD["user"],
        "DB_PASSWORD": CONFIG_BD["password"], "DB_NAME": CONFIG_BD["database"]
    }.items() if not v]
    if faltantes:
        raise RuntimeError("Faltan datos de conexión en .env: " + ", ".join(faltantes))
    return mysql.connector.connect(**CONFIG_BD)

def pausar():
    input("\\nPresione Enter para continuar...")

def mostrar_menu():
    print("\\n" + "=" * 46)
    print("       SISTEMA DE GESTIÓN DE PAÑOL")
    print("=" * 46)
    print("1. Ver herramientas")
    print("2. Agregar herramienta")
    print("3. Cambiar estado de herramienta")
    print("4. Eliminar herramienta")
    print("5. Ver personas")
    print("6. Agregar persona")
    print("7. Registrar préstamo")
    print("8. Registrar devolución")
    print("9. Ver préstamos activos")
    print("0. Salir")
    print("=" * 46)

def ejecutar_consulta(sql, datos=None, obtener=True):
    conexion = conectar_bd()
    try:
        cursor = conexion.cursor()
        cursor.execute(sql, datos or ())
        resultado = cursor.fetchall() if obtener else None
        if not obtener:
            conexion.commit()
        cursor.close()
        return resultado
    finally:
        conexion.close()

def listar_herramientas():
    filas = ejecutar_consulta("""
        SELECT h.id, h.nombre, COALESCE(h.marca, '-'), COALESCE(h.modelo, '-'),
               COALESCE(c.nombre, 'Sin categoría'), h.estado
        FROM herramientas h LEFT JOIN categorias c ON h.id_categoria = c.id
        ORDER BY h.id
    """)
    print("\\nID | Herramienta | Marca | Modelo | Categoría | Estado")
    print("-" * 88)
    for f in filas:
        print(f"{f[0]} | {f[1]} | {f[2]} | {f[3]} | {f[4]} | {f[5]}")
    if not filas:
        print("No hay herramientas registradas.")

def listar_personas():
    filas = ejecutar_consulta("SELECT id, nombre, departamento, email FROM personas ORDER BY id")
    print("\\nID | Nombre | Departamento | Email")
    print("-" * 75)
    for f in filas:
        print(f"{f[0]} | {f[1]} | {f[2] or '-'} | {f[3] or '-'}")
    if not filas:
        print("No hay personas registradas.")

def agregar_herramienta():
    print("\\n--- AGREGAR HERRAMIENTA ---")
    nombre = input("Nombre: ").strip()
    if not nombre:
        print("El nombre es obligatorio.")
        return
    marca = input("Marca: ").strip() or None
    modelo = input("Modelo: ").strip() or None
    categorias = ejecutar_consulta("SELECT id, nombre FROM categorias ORDER BY id")
    if not categorias:
        print("No hay categorías. Agregue categorías en la base de datos primero.")
        return
    for c in categorias:
        print(f"{c[0]}. {c[1]}")
    try:
        categoria_id = int(input("ID de categoría: "))
        if categoria_id not in [c[0] for c in categorias]:
            print("Categoría inexistente.")
            return
    except ValueError:
        print("El ID debe ser numérico.")
        return
    ejecutar_consulta(
        "INSERT INTO herramientas (nombre, marca, modelo, id_categoria, estado) VALUES (%s,%s,%s,%s,'Disponible')",
        (nombre, marca, modelo, categoria_id), obtener=False)
    print("Herramienta agregada correctamente.")

def actualizar_estado():
    listar_herramientas()
    try:
        hid = int(input("ID de la herramienta: "))
    except ValueError:
        print("ID inválido."); return
    estados = {"1": "Disponible", "2": "Prestado", "3": "Mantenimiento", "4": "Dañado"}
    print("1. Disponible\\n2. Prestado\\n3. Mantenimiento\\n4. Dañado")
    opcion = input("Nuevo estado: ").strip()
    if opcion not in estados:
        print("Opción inválida."); return
    ejecutar_consulta("UPDATE herramientas SET estado=%s WHERE id=%s", (estados[opcion], hid), obtener=False)
    print("Estado actualizado (si el ID existe).")

def eliminar_herramienta():
    listar_herramientas()
    try:
        hid = int(input("ID a eliminar: "))
    except ValueError:
        print("ID inválido."); return
    confirmar = input("¿Confirma la eliminación? (s/n): ").strip().lower()
    if confirmar != "s":
        print("Operación cancelada."); return
    try:
        ejecutar_consulta("DELETE FROM herramientas WHERE id=%s", (hid,), obtener=False)
        print("Herramienta eliminada si no tiene préstamos asociados.")
    except Error as e:
        print("No se pudo eliminar. Puede tener préstamos asociados:", e)

def agregar_persona():
    print("\\n--- AGREGAR PERSONA ---")
    nombre = input("Nombre completo: ").strip()
    if not nombre:
        print("El nombre es obligatorio."); return
    departamento = input("Departamento: ").strip() or None
    email = input("Email: ").strip() or None
    ejecutar_consulta("INSERT INTO personas (nombre, departamento, email) VALUES (%s,%s,%s)",
                      (nombre, departamento, email), obtener=False)
    print("Persona agregada correctamente.")

def registrar_prestamo():
    disponibles = ejecutar_consulta("SELECT id, nombre FROM herramientas WHERE estado='Disponible' ORDER BY id")
    if not disponibles:
        print("No hay herramientas disponibles."); return
    print("\\nHerramientas disponibles:")
    for h in disponibles: print(f"{h[0]}. {h[1]}")
    personas = ejecutar_consulta("SELECT id, nombre FROM personas ORDER BY id")
    if not personas:
        print("No hay personas registradas."); return
    try:
        hid = int(input("ID de herramienta: "))
        pid = int(input("ID de persona: "))
    except ValueError:
        print("Los ID deben ser numéricos."); return
    if hid not in [h[0] for h in disponibles] or pid not in [p[0] for p in personas]:
        print("Herramienta o persona no válida."); return
    conexion = conectar_bd()
    try:
        cursor = conexion.cursor()
        cursor.execute("INSERT INTO prestamos (id_herramienta,id_persona,fecha_prestamo) VALUES (%s,%s,%s)",
                       (hid, pid, date.today()))
        cursor.execute("UPDATE herramientas SET estado='Prestado' WHERE id=%s", (hid,))
        conexion.commit()
        cursor.close()
        print("Préstamo registrado correctamente.")
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()

def registrar_devolucion():
    filas = ejecutar_consulta("""
        SELECT p.id, h.id, h.nombre, per.nombre, p.fecha_prestamo
        FROM prestamos p JOIN herramientas h ON p.id_herramienta=h.id
        JOIN personas per ON p.id_persona=per.id
        WHERE p.fecha_devolucion IS NULL ORDER BY p.id
    """)
    if not filas:
        print("No hay préstamos activos."); return
    print("\\nID préstamo | Herramienta | Persona | Fecha")
    for f in filas: print(f"{f[0]} | {f[2]} | {f[3]} | {f[4]}")
    try:
        prestamo_id = int(input("ID del préstamo a devolver: "))
    except ValueError:
        print("ID inválido."); return
    seleccionado = next((f for f in filas if f[0] == prestamo_id), None)
    if not seleccionado:
        print("Ese préstamo no está activo."); return
    conexion = conectar_bd()
    try:
        cursor = conexion.cursor()
        cursor.execute("UPDATE prestamos SET fecha_devolucion=%s WHERE id=%s AND fecha_devolucion IS NULL",
                       (date.today(), prestamo_id))
        cursor.execute("UPDATE herramientas SET estado='Disponible' WHERE id=%s", (seleccionado[1],))
        conexion.commit()
        cursor.close()
        print("Devolución registrada correctamente.")
    except Exception:
        conexion.rollback()
        raise
    finally:
        conexion.close()

def ver_prestamos_activos():
    filas = ejecutar_consulta("""
        SELECT p.id, h.nombre, per.nombre, p.fecha_prestamo
        FROM prestamos p JOIN herramientas h ON p.id_herramienta=h.id
        JOIN personas per ON p.id_persona=per.id
        WHERE p.fecha_devolucion IS NULL ORDER BY p.id
    """)
    print("\\nID | Herramienta | Persona | Fecha de préstamo")
    for f in filas: print(f"{f[0]} | {f[1]} | {f[2]} | {f[3]}")
    if not filas: print("No hay préstamos activos.")

def main():
    print("Sistema de Gestión de Pañol - TP N.º 9")
    try:
        conexion = conectar_bd()
        conexion.close()
        print("Conexión a MySQL exitosa.")
    except (Error, RuntimeError, ValueError) as e:
        print("No se pudo conectar a la base de datos.")
        print("Detalle:", e)
        print("Revise el archivo .env y los datos de Clever Cloud.")
        return
    opciones = {
        "1": listar_herramientas, "2": agregar_herramienta,
        "3": actualizar_estado, "4": eliminar_herramienta,
        "5": listar_personas, "6": agregar_persona,
        "7": registrar_prestamo, "8": registrar_devolucion,
        "9": ver_prestamos_activos,
    }
    while True:
        mostrar_menu()
        opcion = input("Seleccione una opción: ").strip()
        if opcion == "0":
            print("Hasta luego.")
            break
        funcion = opciones.get(opcion)
        if not funcion:
            print("Opción inválida.")
            continue
        try:
            funcion()
        except (Error, RuntimeError, ValueError) as e:
            print("Ocurrió un error:", e)
        pausar()

if __name__ == "__main__":
    main()
