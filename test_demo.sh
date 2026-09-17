#!/usr/bin/env bash
# ==============================================================================
# UNIVERSIDAD NACIONAL DE JUJUY (UNJu) - FACULTAD DE INGENIERÍA
# SISTEMAS OPERATIVOS II - 2026
# SUITE DE PRUEBAS DEMOSTRATIVA — TRABAJO PRÁCTICO N° 3 (DOCENTE)
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PUNTAJE_TOTAL=0
MAX_PUNTAJE=100
FALLOS=0

export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin

imprimir_banner() {
    echo -e "${BLUE}================================================================${NC}"
    echo -e "${BOLD}   UNJu — SO II — SUITE DE PRUEBAS DEMO DOCENTE TP 3 (100/100)    ${NC}"
    echo -e "${BLUE}================================================================${NC}"
}

if [ ! -f "demo_ejercicios_io.sh" ]; then
    echo -e "${RED}[ERROR CRÍTICO] No se encontró 'demo_ejercicios_io.sh'.${NC}"
    exit 1
fi

source ./demo_ejercicios_io.sh
mkdir -p soluciones_demo

# Demo 1
test_demo1() {
    echo -e "\n${BOLD}Verificando Demo 1: Dispositivos en /dev...${NC}"
    demo_ejercicio1_dispositivos > /dev/null 2>&1
    local target="soluciones_demo/dispositivos_demo.txt"
    if [ -s "$target" ]; then
        echo -e "  ${GREEN}✓ [PASS] Demo 1 verificado (+20 Pts)${NC}"
        PUNTAJE_TOTAL=$((PUNTAJE_TOTAL + 20))
    else
        echo -e "  ${RED}✗ [FAIL] Demo 1 falló (+0 Pts)${NC}"
        FALLOS=$((FALLOS + 1))
    fi
}

# Demo 2
test_demo2() {
    echo -e "\n${BOLD}Verificando Demo 2: Módulos del Kernel con modinfo...${NC}"
    demo_ejercicio2_modulos > /dev/null 2>&1
    local target="soluciones_demo/modulos_demo.txt"
    if [ -s "$target" ]; then
        echo -e "  ${GREEN}✓ [PASS] Demo 2 verificado (+20 Pts)${NC}"
        PUNTAJE_TOTAL=$((PUNTAJE_TOTAL + 20))
    else
        echo -e "  ${RED}✗ [FAIL] Demo 2 falló (+0 Pts)${NC}"
        FALLOS=$((FALLOS + 1))
    fi
}

# Demo 3
test_demo3() {
    echo -e "\n${BOLD}Verificando Demo 3: Enlaces duros vs simbólicos...${NC}"
    demo_ejercicio3_enlaces > /dev/null 2>&1
    local target="soluciones_demo/enlaces_demo.txt"
    if [ -s "$target" ]; then
        echo -e "  ${GREEN}✓ [PASS] Demo 3 verificado (+20 Pts)${NC}"
        PUNTAJE_TOTAL=$((PUNTAJE_TOTAL + 20))
    else
        echo -e "  ${RED}✗ [FAIL] Demo 3 falló (+0 Pts)${NC}"
        FALLOS=$((FALLOS + 1))
    fi
}

# Demo 4
test_demo4() {
    echo -e "\n${BOLD}Verificando Demo 4: Creación de ext3 y superbloque...${NC}"
    demo_ejercicio4_filesystem > /dev/null 2>&1
    local target="soluciones_demo/superbloque_demo.txt"
    if [ -s "$target" ]; then
        echo -e "  ${GREEN}✓ [PASS] Demo 4 verificado (+20 Pts)${NC}"
        PUNTAJE_TOTAL=$((PUNTAJE_TOTAL + 20))
    else
        echo -e "  ${RED}✗ [FAIL] Demo 4 falló (+0 Pts)${NC}"
        FALLOS=$((FALLOS + 1))
    fi
}

# Demo 5
test_demo5() {
    echo -e "\n${BOLD}Verificando Demo 5: Autograder criptográfico docente...${NC}"
    local resp="soluciones_demo/respuestas_tp3.json"
    if [ ! -f "$resp" ]; then
        echo -e "  ${RED}✗ Falta '$resp'.${NC}"
        FALLOS=$((FALLOS + 1))
        return
    fi
    python3 autograder_tp3_demo.py "$resp" --rubric rubric_tp3_demo.json --json > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ [PASS] Demo 5 evaluador criptográfico 100/100 (+20 Pts)${NC}"
        PUNTAJE_TOTAL=$((PUNTAJE_TOTAL + 20))
    else
        echo -e "  ${RED}✗ [FAIL] Demo 5 no alcanzó el 100% (+0 Pts)${NC}"
        FALLOS=$((FALLOS + 1))
    fi
}

imprimir_banner
test_demo1
test_demo2
test_demo3
test_demo4
test_demo5

echo -e "\n${BLUE}================================================================${NC}"
echo -e "  Calificación Docente: ${BOLD}${PUNTAJE_TOTAL} / ${MAX_PUNTAJE} Pts${NC}"
if [ $PUNTAJE_TOTAL -eq 100 ]; then
    echo -e "  Estado: ${GREEN}${BOLD}DEMOSTRACIÓN DOCENTE 100% VERIFICADA ✅${NC}"
    echo -e "${BLUE}================================================================${NC}\n"
    exit 0
else
    echo -e "  Estado: ${RED}${BOLD}ERROR EN DEMOSTRACIÓN DOCENTE ❌${NC}"
    echo -e "${BLUE}================================================================${NC}\n"
    exit 1
fi
