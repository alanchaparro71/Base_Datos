-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS panol_herramientas;
USE panol_herramientas;

-- Tabla de categorías de herramientas
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de herramientas
CREATE TABLE herramientas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    id_categoria INT,
    estado ENUM('Disponible', 'Prestado', 'Mantenimiento', 'Dañado') DEFAULT 'Disponible',
    fecha_adquisicion DATE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id)
);

-- Tabla de personas (empleados que pueden pedir herramientas)
CREATE TABLE personas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(50),
    email VARCHAR(100)
);

-- Tabla de préstamos
CREATE TABLE prestamos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_herramienta INT NOT NULL,
    id_persona INT NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion DATE,
    observaciones TEXT,
    FOREIGN KEY (id_herramienta) REFERENCES herramientas(id),
    FOREIGN KEY (id_persona) REFERENCES personas(id)
);

-- Insertar datos de ejemplo
INSERT INTO categorias (nombre, descripcion) VALUES 
('Herramientas Manuales', 'Destornilladores, martillos, alicates, etc.'),
('Herramientas Eléctricas', 'Taladros, amoladoras, sierras eléctricas'),
('Medición y Precisión', 'Calibres, micrómetros, niveles'),
('Sujeción', 'Sargentos, prensas, tornillos de banco');

INSERT INTO herramientas (nombre, marca, modelo, id_categoria, estado, fecha_adquisicion) VALUES 
('Martillo de Bola', 'Stanley', 'MB-500', 1, 'Disponible', '2024-01-15'),
('Destornillador Phillips', 'Bahco', 'PH2', 1, 'Prestado', '2024-02-20'),
('Taladro Percutor', 'Bosch', 'GBM 13-2', 2, 'Disponible', '2024-03-10'),
('Calibre Digital', 'Mitutoyo', '500-196-30', 3, 'Mantenimiento', '2024-01-30'),
('Alicate Universal', 'Irwin', '8IN', 1, 'Disponible', '2024-02-28');

INSERT INTO personas (nombre, departamento, email) VALUES 
('Juan Pérez', 'Taller', 'juan.perez@empresa.com'),
('María García', 'Mantenimiento', 'maria.garcia@empresa.com'),
('Carlos López', 'Producción', 'carlos.lopez@empresa.com');

INSERT INTO prestamos (id_herramienta, id_persona, fecha_prestamo, fecha_devolucion, observaciones) VALUES 
(2, 1, '2024-10-01', NULL, 'Prestado para reparación urgente'),
(4, 2, '2024-09-28', '2024-10-02', 'Devolución con desgaste normal');