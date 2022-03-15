
---- 1. Crear el modelo en una base de datos llamada biblioteca, considerando las tablas
---- definidas y sus atributos.


-- CREANDO BASE DATOS
CREATE DATABASE biblioteca;

--  \c biblioteca

----CREANDO TABLAS


CREATE TABLE direccion (
  id_direccion SERIAL UNIQUE PRIMARY KEY,
  calle VARCHAR (100) NOT NULL,
  numero INT NOT NULL,
  comuna VARCHAR (50) NOT NULL
);

CREATE TABLE socios(
rut_socio VARCHAR(9) UNIQUE PRIMARY KEY NOT NULL,
nombre_socio VARCHAR (30) NOT NULL,
apellido_socio VARCHAR (30) NOT NULL,
id_direccion INT NOT NULL,
telefono INT NOT NULL,
FOREIGN KEY (id_direccion) REFERENCES direccion (id_direccion)
);


CREATE TABLE autor (
 cod_autor SERIAL UNIQUE PRIMARY KEY,
 nombre_autor VARCHAR (30) NOT NULL,
 apellido_autor VARCHAR (30) NOT NULL,
 nacimiento INT NOT NULL,
 muerte INT
)


CREATE TABLE libros (
 isbn VARCHAR (30)  PRIMARY KEY,
 pag INT NOT NULL,
 titulo VARCHAR (50) NOT NULL
);


CREATE TABLE prestamos (
id_prestamo SERIAL PRIMARY KEY,
fecha_prestamo  DATE NOT NULL,
fecha_devolucion DATE NOT NULL,
isbn VARCHAR (20) NOT NULL,
rut_socio VARCHAR (9) NOT NULL,
FOREIGN KEY (isbn) REFERENCES libros (isbn),
FOREIGN KEY (rut_socio) REFERENCES socios (rut_socio)
);



 CREATE TABLE libros_autor ( 
  tipo_autor VARCHAR (15) NOT NULL,
  isbn VARCHAR (30) NOT NULL,
  cod_autor INT NOT NULL,
  FOREIGN KEY (isbn) REFERENCES libros (isbn),
  FOREIGN KEY (cod_autor) REFERENCES autor (cod_autor)
 );



---- 2. Se deben insertar los registros en las tablas correspondientes


INSERT INTO direccion (calle,numero,comuna)
VALUES
('AVENIDA',1,'SANTIAGO'),
('PASAJE',2,'SANTIAGO'),
('AVENIDA',2,'SANTIAGO'),
('AVENIDA',3,'SANTIAGO'),
('PASAJE',3,'SANTIAGO')
;

SELECT*FROM direccion;


INSERT INTO socios (rut_socio,nombre_socio,apellido_socio,id_direccion,telefono)
VALUES
('1111111-1','JUAN', 'SOTO',1, '911111111'),
('2222222-2','ANA', 'PEREZ',2,'922222222'),
('3333333-3','SANDRA', 'AGUILAR',3,'933333333'),
('4444444-4','ESTEBAN', 'JEREZ',4,'944444444'),
('5555555-5','SILVANA', 'MUÑOZ',5,'955555555')
;

SELECT*FROM socios;

INSERT INTO autor (nombre_autor,apellido_autor,nacimiento,muerte)
VALUES
('ANDRES','ULLOA',1982, null),
('SERGIO','MARDONES',1950,2012),
('JOSE','SALGADO',1968,2020),
('ANA','SALGADO',1972, null), 
('MARTIN','PORTA', 1976, null)
  ;

SELECT*FROM autor;
  
  INSERT INTO libros (isbn,pag,titulo)
  VALUES
('111-1111111-111',344,'CUENTOS DE TERROR'),
('222-2222222-222',167,'POESIAS CONTEMPORANEAS'),
('333-3333333-333',511,'HISTORIA DE ASIA'),
('444-4444444-444',298,'MANUAL DE MECANICA')
;

SELECT*FROM libros;

INSERT INTO prestamos (fecha_prestamo,fecha_devolucion,isbn,rut_socio)
VALUES
('20-01-2020','27-01-2020','111-1111111-111','1111111-1'),
('20-01-2020','30-01-2020','222-2222222-222','5555555-5'),
('22-01-2020','30-01-2020','333-3333333-333','3333333-3'),
('23-01-2020','30-01-2020','444-4444444-444','4444444-4'),
('27-01-2020','04-02-2020','111-1111111-111','2222222-2'),
('31-01-2020','12-02-2020','444-4444444-444','1111111-1'),   
('31-01-2020','12-02-2020','222-2222222-222','3333333-3')
;

SELECT*FROM prestamos;


INSERT INTO libros_autor (tipo_autor,isbn,cod_autor)
VALUES 
('PRINCIPAL','111-1111111-111',3),
('COAUTOR',  '111-1111111-111',4),
('PRINCIPAL','222-2222222-222',1),
('PRINCIPAL','333-3333333-333',2),
('PRINCIPAL','444-4444444-444',5)
;

SELECT*FROM libros_autor;





---- 3. Realizar las siguientes consultas:
---- a. Mostrar todos los libros que posean menos de 300 páginas. 

  SELECT titulo AS LIBRO, pag AS "<300 Pag." FROM libros
  WHERE pag < 300
  ORDER by pag DESC
  ;

----          libro          | <300 Pag.
---- ------------------------+-----------
----  MANUAL DE MECANICA     |       298
----  POESIAS CONTEMPORANEAS |       167
---- (2 rows)



---- b. Mostrar todos los autores que hayan nacido después del 01-01-1970.

SELECT nombre_autor AS NOMBRE, apellido_autor AS APELLIDO, nacimiento AS "Nacido en:"
FROM autor
WHERE nacimiento > 1970
ORDER BY nacimiento ASC
;

----  nombre | apellido | Nacido en:
---- --------+----------+------------
----  ANA    | SALGADO  |       1972
----  MARTIN | PORTA    |       1976
----  ANDRES | ULLOA    |       1982
---- (3 rows)


---- c. ¿Cuál es el libro más solicitado? 
----EN CASO QUE EXISTIERA UN UNICO LIBRO MAS SOLICITADO

SELECT  COUNT(*) as "VECES SOLCITADO", libros.titulo AS LIBRO
FROM prestamos, libros
WHERE prestamos.isbn=libros.isbn
GROUP BY LIBRO
ORDER by COUNT (LIBROS) DESC
LIMIT 1
;

----  VECES SOLCITADO |       libro
---- -----------------+--------------------
----                2 | MANUAL DE MECANICA
---- (1 row)


----EN EL CASO DE LPROBLEMA PLANTEANDO EXISTE TRES LIBROS MAS SOLICITADO
----CON LAS MISMA CANTIDAD DE LIBROS SOLICITADOS 

SELECT  COUNT(*) as "VECES SOLCITADO", libros.titulo AS LIBRO
FROM prestamos, libros
WHERE prestamos.isbn=libros.isbn
GROUP BY LIBRO
HAVING COUNT(libros.titulo)>1
;


----  VECES SOLCITADO |         libro
---- -----------------+------------------------
----                2 | MANUAL DE MECANICA
----                2 | POESIAS CONTEMPORANEAS
----                2 | CUENTOS DE TERROR
---- (3 rows)



---- d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto
---- debería pagar cada usuario que entregue el préstamo después de 7 días.
----//Se resta a la Fecha Devolucion la Fecha de Prestamo, y al resultado se resta los 7 dias. 
----//Los cuales son los dias de plazo que tiene que devolver el libro para no tener multa, si el resultado 0 o Negativo, 
----//SIGNIFICA QUE LO HA DEVUELTO DENTRO DEL PLAZO O JUSTO EN PLAZO de los 7 dias 

SELECT socios.nombre_socio AS "SOCIO", ((prestamos.fecha_devolucion - prestamos.fecha_prestamo)-7) AS "DIAS ATRASADOS", ((prestamos.fecha_devolucion - prestamos.fecha_prestamo)-7)*100 AS "MULTA"
FROM prestamos, socios
WHERE socios.rut_socio=prestamos.rut_socio
ORDER BY "DIAS ATRASADOS" DESC
;


----   SOCIO  | DIAS ATRASADOS | MULTA
---- ---------+----------------+-------
----  JUAN    |              5 |   500
----  SANDRA  |              5 |   500
----  SILVANA |              3 |   300
----  SANDRA  |              1 |   100
----  ANA     |              1 |   100
----  ESTEBAN |              0 |     0
----  JUAN    |              0 |     0
---- (7 rows)




