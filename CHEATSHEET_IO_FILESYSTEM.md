# 📖 Cheatsheet: Entrada/Salida, VFS y Sistemas de Archivos en Linux (Demostración Docente)

> **Cátedra:** Sistemas Operativos II — Ciclo Lectivo 2026  
> **Facultad de Ingeniería — Universidad Nacional de Jujuy (UNJu)**  
> **Docentes:** Ing. María Fernanda Vázquez | Ing. Fabio Damián Argañaraz Azua  

---

## 1. El Directorio `/dev` y Tipos de Archivo Especiales

### ¿Qué es el directorio `/dev`?
En Unix y Linux rige el principio fundacional: **"Todo es un archivo" (*Everything is a file*)**.  
El directorio `/dev` (*devices*) **no es una carpeta común almacenada en el disco**, sino un **sistema de archivos virtual montado en memoria RAM (`devtmpfs`)** que el kernel de Linux y el subsistema `udev` gestionan dinámicamente en tiempo de ejecución.

* **Propósito:** Actúa como puente o interfaz en el **Espacio de Usuario (*User Space*)** para comunicarse con los **Controladores de Dispositivos (*Device Drivers*)** que residen en el **Espacio del Kernel (*Kernel Space*)**.
* **Ventaja del modelo:** Permite que cualquier programa interactúe con el hardware físico (discos rígidos, terminales, buses) o con pseudo-dispositivos del kernel (`/dev/null`, `/dev/zero`, `/dev/urandom`) empleando las llamadas al sistema universales de archivos: `open()`, `read()`, `write()`, `close()` e `ioctl()`, sin requerir APIs propietarias.

En Linux, el primer carácter de los permisos en `ls -l` define la naturaleza del nodo en el sistema de archivos:

| Tipo | Letra | Descripción | Ejemplos en el Sistema |
| :--- | :---: | :--- | :--- |
| **Regular** | `-` | Archivo ordinario (binario o texto plano). | `informe.pdf`, `kernel.img`, `script.sh` |
| **Directorio** | `d` | Tabla que asocia nombres de archivo con inodos. | `/usr`, `/home`, `/etc` |
| **Carácter** | `c` | Flujo secuencial de bytes sin buffering directo. | `/dev/tty`, `/dev/null`, `/dev/zero`, `/dev/urandom` |
| **Bloque** | `b` | Dispositivo de almacenamiento direccionable por bloques. | `/dev/sda`, `/dev/sdb1`, `/dev/loop0`, `/dev/nvme0n1` |
| **Enlace Simbólico** | `l` | Puntero textual independiente a otra ruta de archivo. | `/bin -> /usr/bin`, `soluciones_demo/link.txt` |
| **Socket UNIX** | `s` | Punto de comunicación bidireccional local por IPC. | `/run/systemd/journal/stdout`, `/tmp/mysql.sock` |
| **Tubería FIFO** | `p` | Canal de comunicación unidireccional por búfer en RAM. | `/run/systemd/initctl/fifo` |

### Números Major y Minor
Al listar archivos en `/dev`, las columnas de tamaño se reemplazan por dos números separados por coma:
```bash
crw-rw-rw- 1 root root 1, 3 Sep 17 10:00 /dev/null
brw-rw---- 1 root disk 8, 1 Sep 17 10:00 /dev/sda1
```
* **Major (primer número):** Identifica al **manejador o driver** en el kernel responsable de gestionar el dispositivo (`1` = controladores de memoria/nulos, `8` = discos SCSI/SATA `sd`).
* **Minor (segundo número):** Distingue la **instancia física o partición concreta** atendida por ese driver (`3` = `/dev/null`, `1` = primera partición de `/dev/sda`).

### Dispositivos Especiales Clave en `/dev`
* **`/dev/null` (El sumidero de bits / Bit Bucket):**
  * *Escritura:* Descarta inmediatamente cualquier flujo de datos enviado sin almacenarlo en memoria ni disco.
  * *Lectura:* Retorna de inmediato Fin de Archivo (`EOF` / 0 bytes).
  * *Uso típico:* Silenciar mensajes de error o salidas no deseadas en scripts: `comando 2>/dev/null` o `comando > /dev/null 2>&1`.
* **`/dev/zero` (La fuente inagotable de ceros):**
  * *Escritura:* Se comporta como `/dev/null` (descarta los datos).
  * *Lectura:* Provee un flujo continuo e infinito de bytes nulos (`\0` o `0x00`).
  * *Uso típico:* Crear imágenes de disco vacías o particiones de swap preasignadas: `dd if=/dev/zero of=swap.img bs=1M count=512`.
* **`/dev/urandom` (Generador pseudoaleatorio criptográfico no bloqueante):**
  * *Lectura:* Entrega un flujo infinito de bytes pseudoaleatorios generados por el CSPRNG del kernel a partir de la reserva de entropía del hardware.
  * *Ventaja frente a `/dev/random`:* Nunca se bloquea en espera de entropía física adicional.
  * *Uso típico:* Creación de claves criptográficas SSH, hashes de sesión, contraseñas y sobreescritura segura de discos.
* **`/dev/tty` (Terminal de control del proceso actual):**
  * Representa el teclado físico y pantalla interactiva asociados a la sesión del proceso.
  * Incluso si la entrada/salida estándar (`stdin`/`stdout`) fue redirigida a archivos o tuberías (`cat archivo | comando > salida.txt`), abrir `/dev/tty` interactúa siempre de forma directa con el operador de la terminal.
  * *Uso típico:* Comandos como `sudo`, `passwd` y `ssh` para solicitar contraseñas de forma interactiva e impedir que sean capturadas desde una tubería.

---

## 2. Inodos y Enlaces (Hard Links vs Symbolic Links)

Un **Inodo** almacena los metadatos completos del archivo: permisos, dueño (UID), grupo (GID), marcas de tiempo (`atime`, `mtime`, `ctime`), tamaño en bytes y punteros o extents a bloques de datos en disco.  
> [!IMPORTANT]
> **El nombre del archivo NO reside en el inodo**. El nombre se almacena en la entrada de directorio (**dentry**), la cual mapea el nombre textual al número de inodo.

```bash
# Ver número de inodo con ls
ls -li archivo.txt

# Reporte detallado de inodo, enlaces y tamaño con stat
stat archivo.txt

# Formato personalizado con stat
stat -c "Nombre: %n | Inodo: %i | Links: %h | Tamaño: %s bytes" archivo.txt

# Crear Enlace Duro (Hard Link) -> Comparte el mismo inodo
ln archivo_origen.txt enlace_duro.txt

# Crear Enlace Simbólico (Soft Link) -> Inodo nuevo con ruta como contenido
ln -s archivo_origen.txt enlace_simbolico.txt
```

---

## 3. Módulos Cargables del Kernel (LKM)

```bash
# Listar todos los módulos cargados actualmente en memoria
lsmod

# Inspeccionar información detallada de un módulo (.ko)
modinfo ext4
modinfo loop
```

---

## 4. Creación y Análisis de Sistemas de Archivos (`ext2` / `ext3` / `ext4`)

```bash
# 1. Crear contenedor de almacenamiento virtual con dd
dd if=/dev/zero of=disco_virtual.img bs=1M count=4

# 2. Formatear como ext3
mkfs.ext3 -F disco_virtual.img

# 3. Formatear como ext4
mkfs.ext4 -F disco_virtual.img

# 4. Inspeccionar el Superbloque (metadatos globales del FS)
dumpe2fs -h disco_virtual.img
```
