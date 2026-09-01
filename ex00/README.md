# 🛠️ Ejercicio 00 – Create Postgres DB

[← Volver al README principal](../README.md)

---

## 🎯 ¿Qué se pide exactamente?

Crear una base de datos **PostgreSQL** lista para usar, con los siguientes datos obligatorios:

| Parámetro          | Valor obligatorio          |
|--------------------|----------------------------|
| **Usuario**        | Tu login de estudiante     |
| **Nombre de la BD**| `piscineds`                |
| **Contraseña**     | `mysecretpassword`         |

Debemos poder conectarnos con este comando:

```bash
psql -U «tu_login» -d piscineds -h localhost -W
```

Cuando pida la contraseña, escribes: `mysecretpassword`

## El comando psql -U «tu_login» -d piscineds -h localhost -W 

- Sirve para **abrir una sesión** interactiva en una base de datos PostgreSQL utilizando la terminal. 
- Al ejecutarlo, dejas la línea de comandos habitual de tu sistema operativo y **entras directamente a la consola de PostgreSQL** para escribir consultas SQL (SELECT, INSERT, etc.).
- Las flags (los añadidos con guion) sirven para darle al programa las credenciales y la dirección exacta a la que debe dirigirse.
- A continuación tienes el desglose completo de qué hace, para qué sirve y qué ocurre si omites cada una de ellas de forma individual:

**👤 -U «tu_login» (User / Usuario)**

- ¿Qué hace exactamente? Le dice a PostgreSQL que intente **iniciar sesión con el nombre de cuenta de usuario «tu_login»** (un marcador que debes cambiar por tu usuario real).Para qué sirve: Para el control de accesos y permisos. 
- El sistema necesita saber quién eres para **aplicar tus reglas de seguridad** (por ejemplo, saber si puedes borrar tablas o solo leerlas).
- ¿Qué ocurre si NO se introduce? psql intentará conectarse utilizando de forma automática el mismo nombre de usuario que tienes en la sesión de tu sistema operativo (tu usuario de Mac, Linux o Windows). Si ese nombre no coincide exactamente con un usuario registrado dentro de PostgreSQL, **el servidor rechazará la conexión** con un error de autenticación.

**🗄️ -d piscineds (Database / Base de datos)**

- ¿Qué hace exactamente? Indica que, una vez que logres entrar, te sitúe inmediatamente dentro de la base de datos llamada piscineds.
- ¿Para qué sirve? Para ahorrar tiempo e ir directo al grano. Un único servidor de PostgreSQL puede albergar decenas de bases de datos diferentes; esta flag te evita tener que buscar y cambiar de base de datos de forma manual una vez dentro.
- ¿Qué ocurre si NO se introduce? Por defecto, el programa intentará conectarse a una base de datos que se llame exactamente igual que tu nombre de usuario. Si esa base de datos por defecto no existe en el sistema, la terminal te lanzará un error y no te dejará iniciar la sesión.

**🌐 -h localhost (Host / Servidor)**

- ¿Qué hace exactamente? Especifica la **dirección de red donde está corriendo el servidor de PostgreSQL**. La palabra localhost es una dirección interna que significa **"este mismo equipo"**.
- ¿Para qué sirve? Para la **comunicación IP**. Le dice a la terminal que busque el servicio de base de datos de forma local **en tu máquina** en lugar de buscar un servidor externo en internet o en la nube.
- ¿Qué ocurre si NO se introduce? psql intentará conectarse mediante un método interno llamado sockets de dominio Unix (un canal de comunicación local del sistema operativo) en lugar de usar la red local (TCP/IP). En sistemas Mac o Linux esto suele funcionar bien si todo está en la misma máquina, pero en Windows o en ciertos entornos virtuales (como Docker o contenedores) suele fallar estrepitosamente dando un error de **"Conexión rechazada"**.

**🔑 -W (Password / Contraseña)**

- ¿Qué hace exactamente? Fuerza al programa a **pedirte la contraseña** de manera obligatoria en la pantalla antes de intentar la conexión.
- ¿Para qué sirve? Es una **medida de seguridad proactiva**. Te asegura que la terminal se detenga y te muestre el mensaje Contraseña para usuario «tu_login»: para que puedas teclearla. 
(Nota: cuando la escribas no verás letras ni asteriscos por privacidad; escríbela a ciegas y pulsa Enter).
- ¿Qué ocurre si NO se introduce? El programa intentará conectarse directamente. Si el servidor PostgreSQL requiere contraseña, te la va a pedir de todas formas de manera automática. Sin embargo, si el servidor está configurado en modo "confianza" (trust) o tienes tus credenciales guardadas en un archivo oculto de tu sistema (.pgpass), entrarás directamente sin que te pida teclear absolutamente nada.


## ¿Y si no uso las Flags?

Cuando no utilizas las flags (-U, -d, -h), psql interpreta tus palabras en un orden estricto y predeterminado basado en su manual de uso. 

El orden que espera psql cuando pones argumentos sueltos es:
- Primer argumento sin flag: El nombre de la Base de datos.
- Segundo argumento sin flag: El nombre del Usuario. Por lo tanto, si escribes psql «tu_login» piscineds localhost: psql pensará que quieres entrar a una base de datos llamada «tu_login». Pensará que tu nombre de usuario es piscineds.
- Tercer argumento (localhost) romperá el comando porque el sistema no sabrá qué hacer con él (te dará un error de sintaxis como "extra command-line argument").

## ¿Cómo SÍ se podría sustituir para escribir menos?

Si quieres evitar escribir las flags y acortar el comando al máximo, tienes dos opciones válidas:

- **Opción 1:** Respetar el orden nativo de psql (Sin flags) Si quitas las flags, debes poner primero la base de datos y luego el usuario.
<br> ⚠️ Usa el código con precaución. <br>
¿Por qué funciona? Al ver dos palabras, psql asume automáticamente que la primera (piscineds) es la base de datos y la segunda «tu_login» es el usuario.<br>
¿Y el host (-h) y la contraseña (-W)? <br> Al omitir el host, el sistema asumirá por defecto que te conectas a localhost. <br>Al omitir la -W, si el servidor requiere contraseña, te la pedirá automáticamente de todos modos.

```bash
psql piscineds «tu_login»
```

- **Opción 2:** Utilizar el formato de URI (El más moderno) <br>PostgreSQL permite conectarte usando una estructura similar a un enlace web (URL). Es una sola cadena de texto muy limpia 
<br>⚠️ Usa el código con precaución. <br>
¿Por qué funciona? Este formato (protocolo://usuario@servidor/base_de_datos) es estándar en desarrollo. El sistema descompone la URL automáticamente y sabe exactamente quién eres y a dónde vas, sin necesidad de usar guiones.

```bash
psql postgres://tu_login@localhost/piscineds
```
---

## 📁 Archivos a entregar

Dentro de la carpeta `ex00/` debes entregar **uno** de estos archivos:

- `docker-compose.yml`  ← **recomendado**
- o `setup.sh`
- o `VM-instructions.txt`

---

## 🧠 Explicación sencilla (para quien no sabe nada)

Imagina que PostgreSQL es un **almacén grande y profesional**.  
Docker es como una **caja mágica** que contiene ese almacén ya montado y listo para usar.  

En vez de instalar PostgreSQL a mano (que puede ser complicado y diferente en cada ordenador), usamos Docker para que **todo el mundo tenga exactamente el mismo entorno**.

---

## 🚀 Cómo implementarlo paso a paso (opción recomendada: Docker)

### Paso 1: Crear el archivo `docker-compose.yml`

Abre un editor de texto y crea el archivo `ex00/docker-compose.yml` con este contenido:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: postgres_piscineds
    environment:
      POSTGRES_USER: «tu_login»          # ← ¡Cambia esto por tu login real!
      POSTGRES_PASSWORD: mysecretpassword
      POSTGRES_DB: piscineds
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:

```

**Importante:** sustituye `«tu_login»` por tu login real de 42. <br>
⚠️ **Usa el código con precaución.**

### Paso 2: Arrancar el servicio

Abre una terminal en la carpeta `ex00/` y ejecuta:

```bash
docker-compose up -d
```

El comando docker-compose up -d sirve para **leer tu plano de configuración** (docker-compose.yml) y **encender la base de datos** en segundo plano sin bloquear tu terminal.<br>
Imagínalo como el botón de **"Encendido General"** de tu fábrica virtual de bases de datos.<br>
Aquí tienes el desglose exacto de qué hace y para qué sirve cada palabra:
- **docker-compose**: Es el capataz de la obra. <br>
Se encargará de leer el archivo de texto donde tenemos las instrucciones de tu base de datos y coordinar todo el trabajo pesado.
- **up**: Es la orden de <i>"¡Construye y levanta todo!"</i>. <br>
Le dice al capataz que descargue la imagen de PostgreSQL de internet (si no la tiene ya), cree el contenedor, configure las contraseñas, conecte el disco duro virtual (volume) y lo ponga en marcha.
- **-d** (Detached / Modo Desacoplado): Significa <i>"Hazlo en segundo plano"</i>. <br>
Si no pones esta -d, la terminal se quedará "secuestrada" mostrando un flujo infinito de textos y logs del sistema, y no podrás seguir escribiendo comandos. <br>Al poner -d, el contenedor se enciende de forma silenciosa "por detrás" y te devuelve el control de la terminal inmediatamente para que puedas seguir trabajando.

(Verás que aparecen unas barras de descarga si es la primera vez, y luego un mensaje con un check verde que dice algo como Started o Running) ✅

### Paso 3: Comprueba que está vivo: 
Si quieres asegurarte de que tu contenedor está **encendido y funcionando** bien en segundo plano, escribe:
``` bash
docker ps
```

### Paso 4: Verificar que funciona

Prueba la conexión:

```bash
psql -U tu_login -d piscineds -h localhost -W
```

Si te pide la contraseña y luego ves el prompt `piscineds=#`, **¡está perfecto! 🎉**

Para salir de `psql` escribe `\q` y pulsa Enter.

### Paso 5: Comandos útiles de Docker

```bash
# Ver si el contenedor está corriendo
docker ps

# Ver los logs
docker-compose logs

# Parar el servicio 
docker-compose down

# Parar y borrar los datos ¡cuidado! 🧨
docker-compose down -v
```

---

## 📝 Alternativas (si no quieres usar Docker)

### Opción A: `setup.sh`
Un script de bash que instale y configure PostgreSQL nativamente.

### Opción B: `VM-instructions.txt`
Un archivo de texto con las instrucciones exactas para instalar PostgreSQL dentro de una máquina virtual.

---

## ✅ Cómo saber que lo has hecho bien

- Puedes ejecutar el comando `psql` y entrar a la base de datos.
- El usuario, la contraseña y el nombre de la BD son exactamente los que se piden.
- Si usas Docker, el archivo `docker-compose.yml` sigue las buenas prácticas del proyecto Inception.

---

## 📋 ¿Cómo leer y entender los logs?

```bash
docker logs postgres_piscineds
```
- docker logs: Le dice al sistema:<br> 
<i>"Quiero leer la caja negra o el diario de registro de lo que ha estado pasando aquí dentro"</i>.
- postgres_piscineds:<br>
Es el nombre exacto que le hemos dado al contenedor en la línea container_name en el «plano de Docker».

---

## 💡 Los dos trucos más útiles para revisar errores

Cuando algo falla, tirar el comando a secas puede mostrarte miles de líneas de texto antiguo. Para evitar marearte, podemos usar estas dos variantes:
- Ver lo que pasa "en vivo" (**Modo Espía 🕵️‍♂️**)<br>
¿Para qué sirve?<br> 
Es perfecto si estás intentando **ejecutar tu comando psql en otra pestaña** y quieres **ver exactamente qué error salta** en el servidor al mismo tiempo.<br>
¿Cómo salir?<br> 
Para cerrar este modo y recuperar tu terminal, presiona las teclas **Ctrl + C**.<br>
**Si quieres dejar la terminal abierta** y ver cómo se escribe el historial en tiempo real mientras intentas conectarte, **añade la flag -f** (Follow / Seguir):

```bash
docker logs -f postgres_piscineds
```

- Ver solo las **últimas líneas**<br>
Si no quieres un testamento de texto y solo te interesa el error más reciente, **añade --tail seguido del número de líneas que quieras** inspeccionar.<br>
El siguiente comando mostrará únicamente las **últimas 20 líneas** del historial, que es donde casi siempre se **esconde el motivo** por el cual falló la conexión:

```bash
docker logs --tail 20 postgres_piscineds
```

---

## 🔗 Navegación

- [← README principal](../README.md)
- [Siguiente ejercicio: ex01 →](../ex01/README.md)
