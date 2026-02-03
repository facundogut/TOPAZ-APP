# Repositorio app central 
## Forma de uso 

 1. Primero clonar el repositorio

	    git clone https://git.nbch.com.ar/scm/top/topaz-app.git
 2. Posicionarse en la rama de trabajo

	    git checkout beta
 3.  Ya estamos en nuestra rama de trabajo, ahora como usar el repositorio, si vemos tenemos las mismas carpetas que en el servidor por lo tanto tenemos que copiar los archivos en la ubicación donde tiene que ir en el servidor

		 - biblioteca --> igual al repositorio biblioteca 
		 - hakuna
		 - jboss
		 - kettle
		 - shared
		 - sql --> igual al repositorio sql
		 

		> Dato importante cuando se quiera crear una carpeta vacía como se hacia con los zip de varios, deben copiar dentro de esa carpeta este archivo crearCarpetaVacia.txt que se encuentra en la raíz del repositorio, de lo contrario git no guardara la carpeta en el repositorio.

 4.  **PARAMETRIA**, los siguientes archivos en el banco los denominamos archivos de parametria ya que contienen variables que cambian por entorno, estas son asignadas en el momento del despliegue en el servidor, los valores correspondientes a cada entorno son tomadas de otro repositorio (https://git.nbch.com.ar/projects/TOP/repos/topaz-app-config/browse) , **CUIDADO** los archivos deben ser modificados y no remplazados, porque si se remplaza se pierden las variables que se usan para la asignación de valores.

		 - ./jboss/standalone/userlibrary/default/python/topsystems/processmgr/processes.py
		 - ./jboss/standalone/deployments/jDesktop.war/app/jdesktop.jnlp
		 - ./jboss/bin/runtopaz.sh
		 - ./jboss/standalone/configuration/standalone-full-ha.xml
		 - ./jboss/standalone/userlibrary/default/conf/properties/workflow.properties
		 - ./jboss/standalone/userlibrary/default/conf/properties/mscl.properties
		 - ./jboss/standalone/userlibrary/default/conf/properties/jboss.properties
		 - ./jboss/standalone/userlibrary/default/conf/properties/ldap.properties
		 - ./jboss/standalone/deployments/topaz.ear/jbankws.properties
		 - ./jboss/standalone/userlibrary/default/conf/TableRequestConfig.xml
		 - ./jboss/standalone/deployments/Topaz-Posicion.war/WEB-INF/classes/config.properties
		 - ./jboss/standalone/userlibrary/default/tools/kettle/FILE_PARAM/TOPAZSW.properties
		 - ./jboss/standalone/userlibrary/default/tools/kettle/FILE_PARAM/WS_URLs.properties
	

 5.  **LIBERACIÓN DE CORE** cuando se aplica actualizaciones de CORE con hakuna se modifican algunos de los archivos antes mencionados, por lo tanto, se propone lo siguiente para no tener conflicto el encargado de subir las actualizaciones de CORE deberá aplicar la ejecución es su máquina donde tiene los archivos esto provocará que hakuna actualice los archivos de parametria entonces el repositorio estará actualizado y no causaremos conflictos.

## Nueva Forma de trabajo
Por la gran cantidad de liberaciones, se propone la siguiente forma de trabajo

- Debe comunicar al resto de personas que trabajan sobre la misma rama que se encuentra realizando una liberación para no tener conflictos.
- Cuando alguien termina su funcionalidad, debe realizar un git pull de repo, luego preparar todo lo que va a subir para la liberación a la rama de beta
- Después de realizar el despliegue en beta y su respectivas pruebas, se debe crear una rama release_nombre, de esta forma si llega otro cambio de algún equipo a la rama beta, no afectara a la liberación ya que esta ahora esta en una rama aislada (estas ramas no permiten cambios)
- Comunicar a los interesados que la rama beta se encuentra disponible para recibir cambios 
- Luego se creara una pull requests de la rama release_nombre a la rama alpha por parte del equipo de Meteorito.
- El equipo banco del chaco deberá aprobar las pull requests, realizar el merge y correr el pipeline para la liberación.

## Despliegue 

 1. En el caso de una liberación de core se debe aplicar esta en primer lugar
 2. Luego se debe ejecutar el siguiente pipeline https://jenkinsmd.nbch.com.ar/job/Topaz/job/topaz-one-click/ , este se encarga de aplicar lo que hoy se encuentra separado y lo llamamos SQL, BIBLIOTECA y VARIOS. Además de parametrizar los archivos con los valores correctos para cada entorno. 
 3. Para ejecutar el pipeline deben seleccionar el entorno donde aplicaran los cambios, ejemplo: beta
 4. Una vez dentro hacer click en *Build with Parameters* 
 5. Debemos setear 2 parámetros:
			- El primero es en los servidores que queremos aplicar la liberación.
			- El segundo si solicitamos aplicar reinicio del servicio; (la opción telnet no esta desarrollada)
 6. Hacemos click en Ejecución 

# Configuraciones
> De no existir la variable y exista una razón valida para agregarla comunicarse con el equipo de implementaciones (implementaciones@nbch.com.ar) para realizarlo.

## Variables grupales configurables
Existen un set de variables que son susceptibles de poder ser usadas por varios servidores por ejemplo, la versión de java, los servicios de mule a los que apunta, para lo cual se utiliza una dispoción de las variables especial en el inventario de la aplicación que se encuentra en el repositorio de despliegue.

Las mismas son esepcificadas aquí: [variables grupales configurables](https://git.nbch.com.ar/projects/ANS/repos/topaz-inventory/browse)


## Variables configurables
Para poder realizar configuraciones especiales por ambiente se debe modificar el archivo de config del repo de configs en la rama especifica del ambiente [repositorio de configs aqui](https://git.nbch.com.ar/projects/TOP/repos/topaz-app-config/browse) con las configuraciones presentadas más abajo.	

Las configuraciones posibles son:
### Configuraciones de conexion a link
```
pos_link_canales:
  connection_type: 3
  max_connections: X
  dest_host: X
  dest_port_host: X
  time_to_reconnect: X
  output_message_response_list: X
  output_message_timeout: X
  min_spare_threads: X
  max_threads: X
  canales:
    - name: X
      local_port_output: X
```
#### Descripcion
connection_type:
- 3: deshabilitarlo
- 4: habilitarlo

max_connections: maxima conexiones posibles
dest_host: direccion de link o el emulador
dest_port_host: puerto de link o el emulador
time_to_reconnect: tiempo para reconectar
output_message_response_list: 
output_message_timeout:
min_spare_threads: cantidad minima de hilos desocupados
max_threads: cantidad maxima de hilos

##### Para trabajar con multiples canales
Se debe agregar un set nuevo de variables en canales.
En este ejemplo se muestro como trabajar con dos:
```
canales:
- name: X
  local_port_output: X
- name: X2
  local_port_output: X2
```

El nombre y el puerto deben ser distintos.