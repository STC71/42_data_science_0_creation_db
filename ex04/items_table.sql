-- EX04 – Tabla Items
-- Subject: tabla "items", columnas del CSV, ≥ 3 tipos

-- DROP... borra si existe para poder reejecutar y no tener errores al reejecutar.
DROP TABLE IF EXISTS items;

CREATE TABLE items (
    product_id      INTEGER,         -- 1) entero
    category_id     BIGINT,          -- 2) entero muy grande (IDs largos)
    category_code   VARCHAR(255),    -- 3) texto (puede ir vacío)
    brand           VARCHAR(100)     -- 4) texto (puede ir vacío)
);

-- La carga (COPY) la hacemos en el siguiente paso,
-- porque la ruta del CSV en el host no es la misma que dentro del contenedor.

-- En product_id guardan los identificadores únicos de los productos.
-- En category_id se almacenan los identificadores de las categorías a las que 
-- 	pertenecen esos productos. Algo así como las familias de productos, 
-- 	para poder agruparlos y clasificarlos. 
-- La columna category_code almacena un código alfanumérico que representa 
-- 	la categoría. Mientras que la categoría puede ser algo como "Electrónica", 
-- 	"Ropa", "Hogar", etc.; el código de categoría es una forma más compacta y 
--	estandarizada de referirse a esa categoría, como una abreviatura o un 
-- 	identificador único.
-- Por último, en la columna brand seguarda el nombre de la marca del producto.

-- INTEGER es suficiente para los valores de product_id de este CSV.
-- BIGINT se mantiene en category_id porque sus valores son mucho mayores.

-- VARCHAR(255 vs VARCHAR(100): la diferencia es el tamaño máximo de caracteres 
-- que pueden almacenar. VARCHAR(255) puede almacenar hasta 255 caracteres, 
-- mientras que VARCHAR(100) puede almacenar hasta 100 caracteres. 
-- En este caso, se ha elegido un tamaño mayor para category_code porque se 
-- espera que pueda contener códigos más largos, mientras que brand se limita 
-- a 100 caracteres, ya que los nombres de marcas suelen ser más cortos.
