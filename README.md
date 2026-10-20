# Sistema de Gestión de Pañol — TP N.º 9

Aplicación de consola en Python conectada a MySQL (Clever Cloud). Permite administrar herramientas y personas, cambiar estados y registrar préstamos y devoluciones.

## Requisitos
- Python 3.10 o superior.
- Una base de datos MySQL creada en Clever Cloud.
- Las tablas `categorias`, `herramientas`, `personas` y `prestamos` del script SQL del TP07.

## Instalación
1. Descargá o cloná este repositorio.
2. Instalá las dependencias:
   ```bash
   pip install -r requirements.txt
   ```
3. Copiá `.env.example` a `.env`.
4. Completá `.env` con el host, puerto, nombre de base, usuario y contraseña que muestra Clever Cloud.
5. Ejecutá `SistemaGestionPanol.py`:
   ```bash
   python SistemaGestionPanol.py
   ```

## Seguridad
- **No subas `.env` ni credenciales reales a GitHub.**
- `.env.example` contiene valores ficticios y sí se puede publicar.
- Entregá los datos reales en un `.txt` privado por Classroom, según la consigna.
- Si alguna contraseña se publicó accidentalmente, cambiala en el proveedor.

## Operaciones
- **Crear:** agregar herramientas y personas; registrar préstamos.
- **Leer:** listar herramientas, personas y préstamos activos.
- **Actualizar:** cambiar estado de herramientas y registrar devoluciones.
- **Eliminar:** eliminar herramientas que no tengan registros relacionados que lo impidan.

## Archivos
- `SistemaGestionPanol.py`: aplicación.
- `script_BD.sql`: estructura y datos de ejemplo (si se incluye).
- `.env.example`: plantilla sin secretos.
- `.gitignore`: excluye `.env` y archivos temporales.
- `requirements.txt`: dependencia de MySQL.

## Antes de entregar
1. Confirmá que la base de datos esté activa y que las tablas existan.
2. Probá cada opción con datos de prueba.
3. Revisá que `.env` no aparezca en los archivos a subir.
4. Adjuntá en Classroom un documento de texto con las credenciales reales y la ficha de declaración de IA solicitada por la materia.
