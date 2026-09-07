-- Borrar la tabla si ya existía (útil al reintentar)

DROP TABLE IF EXISTS data_2022_dec;

-- DROP es una instrucción de SQL que se utiliza para eliminar una tabla existente en la base de datos. 
-- En este caso, se está eliminando la tabla "data_2022_dec" si ya existía, lo que es útil al reintentar 
-- la creación de la tabla para evitar errores de duplicación.

-- ************************************************************************************************

-- Tabla con TODAS las columnas del CSV y ≥ 6 tipos distintos

CREATE TABLE data_2022_dec (
    event_time    TIMESTAMPTZ,     -- cuándo ocurrió el evento
    event_type    VARCHAR(50),     -- tipo de acción (view, cart, ...)(ver, carrito, ...)
    product_id    INTEGER,         -- identificador del producto
    price         NUMERIC(10,2),   -- precio del producto
    user_id       BIGINT,          -- identificador del usuario
    user_session  UUID             -- identificador de la sesión
);

-- La instrucción CREATE TABLE se utiliza para crear una nueva tabla en la base de datos.
-- En este caso, se está creando la tabla "data_2022_dec" con las siguientes columnas:
-- - event_time: de tipo TIMESTAMPTZ, que almacena la fecha y hora del evento con zona horaria.
-- - event_type: de tipo VARCHAR(50), que almacena el tipo de acción realizada (por ejemplo, "view", "cart", etc.).
--     el tipo VARCHAR(50) permite almacenar cadenas de texto de hasta 50 caracteres.
-- - product_id: de tipo INTEGER, que almacena el identificador del producto. 
--     Tamaño = 4 bytes, rango de -2,147,483,648 a 2,147,483,647.
-- - price: de tipo NUMERIC(10,2), que almacena el precio del producto con hasta 10 dígitos en total y 2 decimales.
-- - user_id: de tipo BIGINT, que almacena el identificador del usuario. BIGINT es un tipo de dato que permite 
--     almacenar números enteros grandes, lo que es útil para identificar usuarios de manera única.
--     ¿Cómo de grandes? puede almacenar números de hasta 19 dígitos.
-- - user_session: de tipo UUID, que almacena el identificador de la sesión del usuario.
--     UUID (Universally Unique Identifier) es un identificador único que se utiliza para identificar 
--     de manera única una sesión de usuario en la base de datos. Se genera de manera aleatoria y es 
--     prácticamente imposible que se repita, lo que lo hace ideal para identificar sesiones de usuario de manera única.
--     Cuando hablamos de sesión de usuario, nos referimos a un período de tiempo durante el cual 
--     un usuario interactúa con una aplicación o sitio web.

-- ************************************************************************************************

-- Cargar datos desde un archivo CSV en la tabla "data_2022_dec"
COPY data_2022_dec (
    event_time, 
    event_type, 
    product_id, 
    price, 
    user_id, 
    user_session
)

FROM '/tmp/data_2022_dec.csv'		
-- FROM especifica la ruta del archivo CSV que contiene los datos a cargar.
--   en concreto los datos que copiamos en el contenedor de Docker con el comando:
--   "docker cp data_2022_dec.csv postgres_piscineds:/tmp/data_2022_dec.csv"

WITH (
    FORMAT csv, 
    HEADER true
);     
-- WITH especifica opciones adicionales para la carga de datos. 
--  En este caso, se indica que el formato del archivo es CSV 
--  y que la primera fila del archivo contiene los nombres de las columnas (HEADER true).
