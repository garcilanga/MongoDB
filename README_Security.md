# Securización de MongoDB
![mongodbLogo](images/mongodb-logo.jpg)

La instalación por defecto de MongoDB no trae demasiadas medidas de seguridad. Por poner un ejemplo, no tiene activada la autenticación, lo que significa que cualquiera puede entrar en nuestro MongoDB, incluso de forma remota si el firewall no tiene bloqueado el puerto 27017.

Esto puede ser muy cómodo para desarrollo, pero para cualquier otra situación es necesario implantar algun tipo de medida de seguridad, dependiendo de la función que tenga el servidor MongoDB dentro la arquitectura y de su situación en la infraestructura.

La securización básica de MongoDB consiste en crear usuarios con sus contraseñas y permisos y activar la autenticación en el archivo de configuración de MongoDB.

Los usuarios deben crearse en la base de datos de sistema _admin_.

### Crear un usuario administrador

En primer lugar crearemos un usuario administrador para la base de datos de sistema _admin_. Para ello accedemos a MongoDB a través de su cliente por línea de comandos:

```
# Acceder al cliente de MongoDB
mongo
```
y una vez en el cliente ejecutaremos las siguientes instrucciones:

```
# Cambiar a base de datos admin
use admin

# Crear usuario
db.createUser({
    user: "admin",
    pwd: "padmin",
    roles: [{ role: "userAdminAnyDatabase", db: "admin" }] });

# Salir del cliente de MongoDB
exit
```

De esta forma hemos creado un usuario _admin_ con:
- contraseña _padmin_
- rol _userAdminAnyDatabase_ sobre la bade de datos _admin_, que proporciona acceso a las operaciones de administración de usuarios en todas las bases de datos del servidor, excepto _local_ y _config_, además de algunos privilegios sobre el clúster.

### Activar la configuración de seguridad

Después de crear el usuario administrador hay que activar la autenticación en el archivo de configuración de MongoDB. Para ello modificamos el archivo _/etc/mongod.conf_, por ejemplo con el editor _nano_:

```
sudo nano /etc/mongod.conf
```

El fichero de configuración de MongoDB por defecto presenta el siguiente contenido (MongoDB 3.6):

```
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# Where and how to store data.
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0


# how the process runs
processManagement:
  timeZoneInfo: /usr/share/zoneinfo

#security:

#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options:

#auditLog:

#snmp:
```

Para activar la autenticación descomentamos la línea _security_ (eliminando el caracter # del inicio de línea) y añadimos debajo de ella una nueva línea con el texto ‘_authorization: enabled_’, quedando la sección _security_ del siguiente modo:

```
security:
  authorization: enabled
```
Después de modificar el fichero de configuración debemos reiniciar el servicio, para que se apliquen los cambios, con alguna de las siguientes instrucciones:
```
sudo service mongod restart

# o bien...

sudo systemctl restart mongod
```

### Otros parámetros de configuración

Además de la sección _security_, el fichero de configuración presenta distintos apartados y propiedades de configuración. Veamos algunos de ellos:

- La propiedad _dbPath_ de la sección _storage_ permite seleccionar el directorio donde se almacenarán todos los datos de nuestras bases de datos. El usuario que ejecuta MongoDB debe tener permisos para poder acceder a ese directorio. Se pueden dar permisos al usuario de MongoDB ejecutando el comando:
    ```
    sudo chown mongodb:mongodb -R /var/lib/mongodb
    ```

- La propiedad _bindIp_ de la sección _net_ permite configurar la IP que tendrá acceso a MongoDB. Para que sólo acepte peticiones de la propia máquina se debe utilzar _localhost_ ó _127.0.0.1_. Para permitir el acceso desde otra máquina habría que poner su IP.

- La sección _systemLog_ permite configurar la escritura de los logs del servidor MongoDB.

### Conexión a la base de datos de administración con el usuario _admin_ creado anteriormente

Una vez creado el usuario _admin_ y activada la autenticación, podemos podemos conectarnos a la base de datos con el usuario _admin_ ejecutando por la consola alguna de las siguientes instrucciones:

- Indicando por línea de comandos el usuario y su password, la base de datos y el parámetro _-authenticationDatabase_:
```
mongo -u admin -p padmin -authenticationDatabase admin
```
- Indicando por línea de comandos la url de conexión (_host:port/database_), el usuario y su password:
```
mongo localhost:27017/admin -u admin -p padmin
```
- Indicando por línea de comandos el usuario, la base de datos, el parámetro _-authenticationDatabase_ y el parámetro -p para que que el sistema solicite la password:
```
mongo -u admin -authenticationDatabase admin -p
```
- Indicando por línea de comandos la url de conexión (_host:port/database_), el usuario y el parámetro -p para que que el sistema solicite la password:
```
mongo localhost:27017/admin -u admin -p
```
- Abriendo el cliente y empleando la función db.auth():
```
mongo

db.auth('admin', 'padmin')
```


Una vez conectados al servidor, podemos ver los usuarios asignados a la base de datos _admin_ con las siguientes instrucciones:
```
use admin
show users
```
Resultado:
```
{
	"_id" : "admin.admin",
	"user" : "admin",
	"db" : "admin",
	"roles" : [
		{
			"role" : "userAdminAnyDatabase",
			"db" : "admin"
		}
	]
}
```

### Crear un usuario no administrador con acceso a una base de datos determinada

Crearemos ahora un usuario que tenga permisos de lectura y escritura sobre la base de datos _test_:

```
# Acceder al cliente de MongoDB
mongo
```
```
# Cambiar a base de datos admin
use admin

# Crear usuario
db.createUser({
    user: "test",
    pwd: "ptest",
    roles: [{ role: "readWrite", db: "local" }] });

# Salir del cliente de MongoDB
exit
```

De esta forma hemos creado un usuario _test_ con:
- contraseña _ptest_
- rol "_readWrite_" sobre la base de datos _test_, que proporciona privilegios de lectura y modificación de datos en todas las colecciones de la base de datos _test_.

Ahora podemos conectarnos a la base de datos _test_ con el usuario _test_ recién creado, ejecutando por consola alguna de las instrucciones expuestas anteriormente para el usuario _admin_.

### Crear un superusuario

Algunos roles proporcionan acceso como superusuario, entre ellos el rol _root_, que proporciona todos los privilegios excepto sobre las colecciones que comiencen con el prefijo '_system._'

```
# Acceder al cliente de MongoDB
mongo
```
```
# Cambiar a base de datos admin
use admin

# Crear usuario
db.createUser({
    user: "root",
    pwd: "root",
    roles: ["root"] });

# Salir del cliente de MongoDB
exit
```

## Referencias y más información
- [Instalar y configurar MongoDB en Ubuntu 16.04](http://www.agiliacenter.com/instalar-y-configurar-mongodb-en-ubuntu-16-04/)
- [Seguridad en MongoDB](https://www.strsistemas.com/blog/seguridad-en-mongodb)
- [Security Reference](https://docs.mongodb.com/manual/reference/security/)
- [Security](https://docs.mongodb.com/manual/security/)

