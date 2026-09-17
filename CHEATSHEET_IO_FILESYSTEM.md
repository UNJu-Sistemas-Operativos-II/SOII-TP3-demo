# 📖 Cheatsheet: Entrada/Salida, VFS y Sistemas de Archivos en Linux (Demostración Docente)

> **Cátedra:** Sistemas Operativos II — Ciclo Lectivo 2026  
> **Facultad de Ingeniería — Universidad Nacional de Jujuy (UNJu)**  
> **Docentes:** Ing. María Fernanda Vázquez | Ing. Fabio Damián Argañaraz Azua  

---

## 1. Tipos de Archivo y Archivos Especiales (`/dev`)

En Linux, la primera letra de la salida de `ls -l` define la naturaleza del nodo en el sistema de archivos:

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
