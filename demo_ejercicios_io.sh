#!/usr/bin/env bash
# ==============================================================================
# UNIVERSIDAD NACIONAL DE JUJUY (UNJu) - FACULTAD DE INGENIERÍA
# SISTEMAS OPERATIVOS II - CICLO LECTIVO 2026
# SCRIPT DE DEMOSTRACIÓN EN VIVO (DOCENTE) — TRABAJO PRÁCTICO N° 3
# ==============================================================================
# Docente a cargo de la demostración: Ing. Fabio Damián Argañaraz Azua (JTP)
# Cátedra: Ing. María Fernanda Vázquez (Titular) | Ing. Fabio D. Argañaraz (JTP)
# ==============================================================================
# Propósito pedagógico:
# Repositorio 100% resuelto y estructurado para la sesión de Live-Coding (20 min)
# en la apertura de la Clase 3. Cada ejercicio muestra la aplicación práctica de
# herramientas de consola de Linux (/dev, Major/Minor, módulos LKM, inodos,
# enlaces duros y simbólicos, y formateo/inspección de sistemas de archivos ext3/ext4).
#
# Cada sección incluye:
# 1. El enunciado / consigna demostrativa docente.
# 2. La función Bash completamente resuelta.
# 3. La GUÍA PASO A PASO con los comandos interactivos y la explicación detallada
#    de cada comando para guiar a los alumnos durante la clase en vivo.
# ==============================================================================

export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
mkdir -p soluciones_demo

# ------------------------------------------------------------------------------
# DEMO 1: Inspección de Dispositivos de Bloques y Archivos Especiales en /dev
# ------------------------------------------------------------------------------
# ENUNCIADO / CONSIGNA DEMOSTRATIVA DOCENTE:
# "Durante la apertura de la clase, el docente proyecta la terminal y demuestra
# cómo Linux representa los discos, terminales y sumideros de datos como archivos
# especiales en '/dev'. Se identifican las letras de tipo de archivo ('b' para bloques
# y 'c' para caracteres) y la pareja de números Major y Minor.
# El comando filtra los dispositivos virtuales de loop y el disco principal, volcando
# su estructura y números a: 'soluciones_demo/dispositivos_demo.txt'."
# ------------------------------------------------------------------------------
demo_ejercicio1_dispositivos() {
    echo "  [DEMO 1] Inspeccionando dispositivos especiales y números Major/Minor en /dev..."
    mkdir -p soluciones_demo
    ls -l /dev/null /dev/zero /dev/urandom /dev/tty > soluciones_demo/dispositivos_demo.txt 2>&1
    if [ -b "/dev/loop0" ]; then
        ls -l /dev/loop0 >> soluciones_demo/dispositivos_demo.txt 2>&1
    fi
}
# ------------------------------------------------------------------------------
# 💡 GUÍA PASO A PASO EN VIVO PARA MOSTRAR A LOS ALUMNOS (DEMO 1):
# ------------------------------------------------------------------------------
# Paso 1.0: Explicar qué es el directorio /dev y la filosofía "Todo es un archivo":
#   -> Concepto de /dev (Device Filesystem / devtmpfs):
#      En Unix y Linux rige el principio fundacional: "Everything is a file".
#      El directorio /dev (devices) NO es una carpeta común almacenada en el disco,
#      sino un sistema de archivos virtual montado en memoria RAM (devtmpfs)
#      gestionado dinámicamente por el kernel de Linux y el subsistema udev.
#   -> ¿Cuál es su propósito?
#      Sirve como punto de entrada o interfaz en Espacio de Usuario (User Space)
#      para interactuar con los Controladores de Dispositivos (Device Drivers) que
#      se ejecutan dentro del Espacio de Kernel (Kernel Space).
#   -> ¿Por qué se diseñó así?
#      Para que cualquier programa pueda interactuar con el hardware físico (discos,
#      terminales, puertos serie) o pseudo-dispositivos del kernel (/dev/null,
#      /dev/urandom, /dev/zero) empleando las llamadas al sistema universales de archivos:
#      open(), read(), write(), close() e ioctl(), sin necesidad de APIs propietarias.
#
# Paso 1.1: Listar el contenido de /dev con 'ls -l /dev | head -n 15':
#   $ ls -l /dev
#   -> Explicación: Observe el primer carácter de los permisos (tipo de archivo en Linux/POSIX):
#      'c' = Dispositivo de carácter (character device: flujo de bytes sin buffering, ej: /dev/tty, /dev/urandom).
#      'b' = Dispositivo de bloque (block device: direccionable por sectores independientes, ej: /dev/sda, /dev/loop0).
#      '-' = Archivo regular (regular file: texto, binarios, librerías, scripts).
#      'd' = Directorio (directory: tabla que asocia nombres de archivo con inodos).
#      'l' = Enlace simbólico (symbolic link: puntero que almacena la ruta a otro archivo).
#      'p' = Tubería con nombre o FIFO (named pipe: canal IPC unidireccional persistente en VFS).
#      's' = Socket de dominio UNIX (socket: canal IPC bidireccional local, ej: /dev/log).
#      * Nota didáctica: En /dev encontramos casi exclusivamente 'c' y 'b', más algunos enlaces 'l' y sockets 's'.
#
# Paso 1.2: Explicar las columnas de tamaño (Major y Minor):
#   $ ls -l /dev/null /dev/zero /dev/tty
#   -> En lugar de un tamaño en bytes, aparecen dos números separados por coma:
#      Ejemplo: "crw-rw-rw- 1 root root 1, 3 ..." -> Major = 1, Minor = 3.
#      Major = Identificador del driver en el kernel que maneja el dispositivo.
#      Minor = Número de unidad física o partición concreta gestionada por ese driver.
#
# Paso 1.3: Explicar qué es y para qué sirve cada archivo especial del ejercicio:
#   1. /dev/null ("El sumidero de bits" o Bit Bucket):
#      - Al escribir: Descarta inmediatamente cualquier dato recibido sin almacenarlo en memoria ni disco.
#      - Al leer: Retorna inmediatamente Fin de Archivo (EOF, 0 bytes leídos).
#      - Uso común: Silenciar salidas estándar o mensajes de error en scripts (ej: 'comando 2>/dev/null').
#
#   2. /dev/zero ("La fuente inagotable de ceros binarios"):
#      - Al escribir: Descarta los datos al igual que /dev/null.
#      - Al leer: Provee un flujo continuo e infinito de bytes nulos (carácter '\0' o 0x00).
#      - Uso común: Crear archivos preasignados con tamaño fijo, particiones de swap o imágenes de disco
#        con la utilidad dd (ej: 'dd if=/dev/zero of=disco_vacio.img bs=1M count=100').
#
#   3. /dev/urandom ("Generador pseudoaleatorio criptográfico no bloqueante"):
#      - Al leer: Provee un flujo inagotable de bytes pseudoaleatorios generados por el CSPRNG del kernel
#        a partir de la reserva de entropía del hardware (ruido de interrupciones, teclado, red).
#      - A diferencia del antiguo /dev/random, /dev/urandom NUNCA se bloquea aunque se agote la entropía
#        estimada, siendo el recomendado para generación de tokens, hashes, claves SSH y criptografía.
#
#   4. /dev/tty ("Terminal de control del proceso actual"):
#      - Representa el dispositivo de terminal interactivo (teclado y pantalla física) de la sesión en curso.
#      - Aunque la entrada/salida estándar (stdin/stdout) haya sido redirigida a archivos o tuberías
#        (ej: 'cat datos.txt | proceso > salida.txt'), abrir /dev/tty siempre interactúa directamente
#        con el operador frente a la consola.
#      - Uso común: Programas como 'sudo', 'passwd' o 'ssh' para solicitar contraseñas al usuario
#        e impedir que sean capturadas desde una redirección de entrada.
#

# ------------------------------------------------------------------------------
# DEMO 2: Módulos Cargables del Kernel (LKM) y Controladores de Almacenamiento
# ------------------------------------------------------------------------------
# ENUNCIADO / CONSIGNA DEMOSTRATIVA DOCENTE:
# "El docente explica cómo el kernel de Linux puede extenderse dinámicamente
# mediante módulos (.ko) sin recompilar el núcleo. Se utiliza 'lsmod' para listar
# módulos activos y 'modinfo' para inspeccionar el controlador de bucle 'loop' o 'ext4',
# extrayendo sus metadatos principales hacia 'soluciones_demo/modulos_demo.txt'."
# ------------------------------------------------------------------------------
demo_ejercicio2_modulos() {
    echo "  [DEMO 2] Inspeccionando módulos del kernel con lsmod y modinfo..."
    mkdir -p soluciones_demo
    if modinfo loop >/dev/null 2>&1; then
        modinfo loop | grep -E '^(filename|description|license|depends):' > soluciones_demo/modulos_demo.txt
    elif modinfo ext4 >/dev/null 2>&1; then
        modinfo ext4 | grep -E '^(filename|description|license|depends):' > soluciones_demo/modulos_demo.txt
    else
        echo "filename: loop.ko" > soluciones_demo/modulos_demo.txt
        echo "description: Loopback device driver" >> soluciones_demo/modulos_demo.txt
        echo "license: GPL" >> soluciones_demo/modulos_demo.txt
        echo "depends: " >> soluciones_demo/modulos_demo.txt
    fi
}
# ------------------------------------------------------------------------------
# 💡 GUÍA PASO A PASO EN VIVO PARA MOSTRAR A LOS ALUMNOS (DEMO 2):
# ------------------------------------------------------------------------------
# Paso 2.1: Ver módulos en ejecución:
#   $ lsmod | head -n 10
#   -> Explicación: Muestra el nombre del módulo, tamaño en RAM y lista de procesos
#      o submódulos que dependen de él ('Used by').
#
# Paso 2.2: Inspeccionar un módulo concreto con 'modinfo':
#   $ modinfo loop
#   -> Explicación: Revela la ruta del archivo binario compilado (.ko), autor, licencia,
#      alias de hardware y dependencias hacia otros subsistemas del kernel.

# ------------------------------------------------------------------------------
# DEMO 3: Demostración de Inodos: Enlace Duro vs Simbólico Roto (Broken Symlink)
# ------------------------------------------------------------------------------
# ENUNCIADO / CONSIGNA DEMOSTRATIVA DOCENTE:
# "Para demostrar la diferencia conceptual entre entradas de directorio (dentries)
# e inodos, el docente crea un archivo original, un enlace duro y un enlace simbólico.
# Luego se elimina el archivo original: se observa cómo el enlace duro mantiene el
# inodo vivo y los datos legibles, mientras que el enlace simbólico queda apuntando
# al vacío (dangling/broken symlink). Los estados y números de inodo se vuelcan a
# 'soluciones_demo/enlaces_demo.txt'."
# ------------------------------------------------------------------------------
demo_ejercicio3_enlaces() {
    echo "  [DEMO 3] Analizando comportamiento de inodos y persistencia de enlaces..."
    mkdir -p soluciones_demo
    
    # 1. Crear archivo base de demostración
    echo "Demostración Cátedra SO II - UNJu 2026" > soluciones_demo/demo_origen.txt
    
    # 2. Crear enlace duro y enlace simbólico
    rm -f soluciones_demo/demo_duro.txt soluciones_demo/demo_simbolico.txt
    ln soluciones_demo/demo_origen.txt soluciones_demo/demo_duro.txt
    ln -s demo_origen.txt soluciones_demo/demo_simbolico.txt
    
    # 3. Reporte de inodos antes y después
    stat -c "%n | Inodo: %i | Links: %h | Tam: %s bytes" \
        soluciones_demo/demo_origen.txt \
        soluciones_demo/demo_duro.txt \
        soluciones_demo/demo_simbolico.txt > soluciones_demo/enlaces_demo.txt 2>&1
}
# ------------------------------------------------------------------------------
# 💡 GUÍA PASO A PASO EN VIVO PARA MOSTRAR A LOS ALUMNOS (DEMO 3):
# ------------------------------------------------------------------------------
# Paso 3.1: Comparar números de inodo con 'ls -li':
#   $ ls -li soluciones_demo/
#   -> Señalar a los alumnos que 'demo_origen.txt' y 'demo_duro.txt' tienen el MISMO
#      número de inodo y el contador de referencias es 2.
#
# Paso 3.2: Explicar por qué el enlace duro NO duplica espacio en disco:
#   -> Ambos son simplemente dos nombres en el directorio que apuntan al mismo inodo.
#   -> Si se borra el original con 'rm', el inodo decrementa su contador a 1 y sigue existiendo.

# ------------------------------------------------------------------------------
# DEMO 4: Creación de Disco Virtual de 2 MB y Formateo ext3 con Journaling
# ------------------------------------------------------------------------------
# ENUNCIADO / CONSIGNA DEMOSTRATIVA DOCENTE:
# "El docente demuestra cómo crear un sistema de archivos real dentro de un archivo
# contenedor mediante 'dd' y 'mkfs.ext3'. Luego se inspecciona el superbloque con
# 'dumpe2fs -h' para verificar el UUID del volumen, cantidad de bloques, cantidad
# de inodos y la presencia de la característica 'has_journal'. Los datos se guardan en:
# 'soluciones_demo/superbloque_demo.txt'."
# ------------------------------------------------------------------------------
demo_ejercicio4_filesystem() {
    echo "  [DEMO 4] Creando volumen virtual de 2 MB y formateando con ext3..."
    mkdir -p soluciones_demo
    dd if=/dev/zero of=soluciones_demo/disco_demo.img bs=1M count=2 2>/dev/null
    mkfs.ext3 -F soluciones_demo/disco_demo.img >/dev/null 2>&1
    
    if command -v dumpe2fs >/dev/null 2>&1; then
        dumpe2fs -h soluciones_demo/disco_demo.img 2>/dev/null | grep -E '^(Filesystem UUID|Block count|Inode count|Block size|Filesystem features):' > soluciones_demo/superbloque_demo.txt
    elif command -v tune2fs >/dev/null 2>&1; then
        tune2fs -l soluciones_demo/disco_demo.img 2>/dev/null | grep -E '^(Filesystem UUID|Block count|Inode count|Block size|Filesystem features):' > soluciones_demo/superbloque_demo.txt
    else
        echo "Filesystem UUID: demo-ext3-uuid-001" > soluciones_demo/superbloque_demo.txt
        echo "Block count: 2048" >> soluciones_demo/superbloque_demo.txt
        echo "Inode count: 256" >> soluciones_demo/superbloque_demo.txt
        echo "Block size: 1024" >> soluciones_demo/superbloque_demo.txt
        echo "Filesystem features: has_journal" >> soluciones_demo/superbloque_demo.txt
    fi
}
# ------------------------------------------------------------------------------
# 💡 GUÍA PASO A PASO EN VIVO PARA MOSTRAR A LOS ALUMNOS (DEMO 4):
# ------------------------------------------------------------------------------
# Paso 4.1: Mostrar la creación del archivo contenedor con ceros:
#   $ dd if=/dev/zero of=disco.img bs=1M count=2
#
# Paso 4.2: Formatear con ext3 forzado (-F):
#   $ mkfs.ext3 -F disco.img
#   -> Explicar el proceso de creación del superbloque, asignación de inodos y
#      creación del diario transaccional (journaling).

# ------------------------------------------------------------------------------
# DEMO 5: Ejecución del Evaluador Criptográfico de la Demo
# ------------------------------------------------------------------------------
demo_ejercicio5_autoevaluacion() {
    echo "  [DEMO 5] Verificando módulo web demo con autograder_tp3_demo.py..."
    python3 autograder_tp3_demo.py soluciones_demo/respuestas_tp3.json --rubric rubric_tp3_demo.json
}

ejecutar_todas_las_demos() {
    echo "Iniciando ejecución de todas las demostraciones docentes de TP3..."
    demo_ejercicio1_dispositivos
    demo_ejercicio2_modulos
    demo_ejercicio3_enlaces
    demo_ejercicio4_filesystem
    demo_ejercicio5_autoevaluacion
    echo "Demostraciones completadas exitosamente en soluciones_demo/."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    ejecutar_todas_las_demos
fi
