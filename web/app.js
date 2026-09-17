/**
 * SISTEMAS OPERATIVOS II - UNJu - 2026
 * Laboratorio Interactivo de Demostración Docente - TP N° 3
 */

const AppState = {
    theme: 'dark',
    diskSim: {
        algo: 'SCAN',
        initialHead: 53,
        workload: [98, 183, 37, 122, 14, 124, 65, 67],
        maxCylinder: 199
    }
};

document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    initBiblio();
    initDiskSimulator();
    populateDemoVfs();
    renderDiskSimulation();
    initExportHandler();
});

function initTheme() {
    const saved = localStorage.getItem('so2_tp3_theme') || 'dark';
    document.documentElement.setAttribute('data-theme', saved);
    document.getElementById('theme-toggle-btn').addEventListener('click', () => {
        const next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', next);
        localStorage.setItem('so2_tp3_theme', next);
        renderDiskSimulation();
    });
}

function initBiblio() {
    document.querySelectorAll('.biblio-header').forEach(h => {
        h.addEventListener('click', () => h.closest('.biblio-guide').classList.toggle('open'));
    });
    const btnAll = document.getElementById('btn-toggle-all-biblio');
    if (btnAll) {
        btnAll.addEventListener('click', () => {
            const guides = document.querySelectorAll('.biblio-guide');
            const anyClosed = Array.from(guides).some(g => !g.classList.contains('open'));
            guides.forEach(g => g.classList.toggle('open', anyClosed));
            btnAll.textContent = anyClosed ? '📖 Ocultar Bibliografía' : '📚 Desplegar Bibliografía';
        });
    }
}

function initDiskSimulator() {
    document.querySelectorAll('.algo-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.algo-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            AppState.diskSim.algo = btn.dataset.algo;
            renderDiskSimulation();
        });
    });
}

function solveDiskSchedule(algo, initialHead, queue, maxCyl) {
    let current = initialHead;
    let sequence = [current];
    let totalSeek = 0;
    let reqs = [...queue];

    if (algo === 'FCFS') {
        for (let r of reqs) {
            totalSeek += Math.abs(r - current);
            current = r;
            sequence.push(current);
        }
    } else if (algo === 'SSTF') {
        while (reqs.length > 0) {
            reqs.sort((a, b) => Math.abs(a - current) - Math.abs(b - current));
            const next = reqs.shift();
            totalSeek += Math.abs(next - current);
            current = next;
            sequence.push(current);
        }
    } else if (algo === 'SCAN') {
        const up = reqs.filter(r => r >= current).sort((a, b) => a - b);
        const down = reqs.filter(r => r < current).sort((a, b) => b - a);
        for (let r of up) {
            totalSeek += Math.abs(r - current);
            current = r;
            sequence.push(current);
        }
        if (current < maxCyl && down.length > 0) {
            totalSeek += Math.abs(maxCyl - current);
            current = maxCyl;
            sequence.push(current);
        }
        for (let r of down) {
            totalSeek += Math.abs(r - current);
            current = r;
            sequence.push(current);
        }
    } else if (algo === 'LOOK') {
        const up = reqs.filter(r => r >= current).sort((a, b) => a - b);
        const down = reqs.filter(r => r < current).sort((a, b) => b - a);
        for (let r of up) {
            totalSeek += Math.abs(r - current);
            current = r;
            sequence.push(current);
        }
        for (let r of down) {
            totalSeek += Math.abs(r - current);
            current = r;
            sequence.push(current);
        }
    }

    return { sequence, totalSeek };
}

function renderDiskSimulation() {
    const { algo, initialHead, workload, maxCylinder } = AppState.diskSim;
    const { sequence, totalSeek } = solveDiskSchedule(algo, initialHead, workload, maxCylinder);

    document.getElementById('metric-algo-name').textContent = `${algo} Scheduler`;
    document.getElementById('metric-sequence').textContent = sequence.join(' → ');
    document.getElementById('metric-total-seek').textContent = `${totalSeek} Cilindros`;

    const svg = document.getElementById('disk-svg');
    if (!svg) return;

    const width = 800;
    const height = 220;
    const padX = 50;
    const padY = 35;
    const plotW = width - padX * 2;
    const plotH = height - padY * 2;

    const isLight = document.documentElement.getAttribute('data-theme') === 'light';
    const axisColor = isLight ? '#94a3b8' : '#334155';
    const textColor = isLight ? '#475569' : '#94a3b8';
    const pathColor = isLight ? '#7c3aed' : '#8b5cf6';
    const dotColor = isLight ? '#6d28d9' : '#a78bfa';
    const headColor = '#f59e0b';

    const getX = (cyl) => padX + (cyl / maxCylinder) * plotW;
    const stepCount = sequence.length;
    const getY = (idx) => padY + (idx / (stepCount - 1)) * plotH;

    let svgHtml = `
        <line x1="${padX}" y1="${padY - 15}" x2="${width - padX}" y2="${padY - 15}" stroke="${axisColor}" stroke-width="2"/>
        <text x="${padX}" y="${padY - 22}" fill="${textColor}" font-size="11" font-family="monospace" text-anchor="middle">0</text>
        <text x="${getX(53)}" y="${padY - 22}" fill="${headColor}" font-size="11" font-family="monospace" font-weight="bold" text-anchor="middle">53 (Inicio)</text>
        <text x="${getX(100)}" y="${padY - 22}" fill="${textColor}" font-size="11" font-family="monospace" text-anchor="middle">100</text>
        <text x="${width - padX}" y="${padY - 22}" fill="${textColor}" font-size="11" font-family="monospace" text-anchor="middle">${maxCylinder}</text>
    `;

    workload.forEach(cyl => {
        const x = getX(cyl);
        svgHtml += `<line x1="${x}" y1="${padY - 10}" x2="${x}" y2="${height - 10}" stroke="${axisColor}" stroke-width="1" stroke-dasharray="3,3" opacity="0.35"/>`;
        svgHtml += `<text x="${x}" y="${height - 2}" fill="${textColor}" font-size="9" font-family="monospace" text-anchor="middle">${cyl}</text>`;
    });

    let points = sequence.map((cyl, idx) => `${getX(cyl)},${getY(idx)}`);
    svgHtml += `<polyline points="${points.join(' ')}" fill="none" stroke="${pathColor}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>`;

    sequence.forEach((cyl, idx) => {
        const x = getX(cyl);
        const y = getY(idx);
        const isStart = idx === 0;
        const color = isStart ? headColor : dotColor;
        const r = isStart ? 6 : 4;
        svgHtml += `<circle cx="${x}" cy="${y}" r="${r}" fill="${color}" stroke="#0f172a" stroke-width="2"/>`;
        svgHtml += `<text x="${x + (x > width - 100 ? -8 : 8)}" y="${y + 4}" fill="${color}" font-size="10" font-family="monospace" font-weight="600">${cyl}</text>`;
    });

    svg.innerHTML = svgHtml;
}

function populateDemoVfs() {
    const zone = document.getElementById('zone-vfs');
    if (!zone) return;
    const items = [
        { id: 'APP', text: '💻 1. Aplicación de Usuario (Proceso emitiendo la syscall read)' },
        { id: 'FD_TABLE', text: '📋 2. Tabla de Descriptores de Archivo del PCB (File Descriptor fd = 3)' },
        { id: 'FILE_STRUCT', text: '📂 3. Objeto Archivo Abierto en VFS (struct file: f_pos, flags y operaciones)' },
        { id: 'DENTRY', text: '🗂️ 4. Entrada de Directorio en Caché (struct dentry: asocia nombre e inodo)' },
        { id: 'INODE', text: '📑 5. Inodo en Memoria (struct inode: metadatos, permisos y mapa de extents)' },
        { id: 'EXTENTS_BLOCKS', text: '💾 6. Árbol de Extents y Bloques Físicos en Disco (ext4 Data Blocks)' }
    ];
    zone.innerHTML = '';
    items.forEach((it, idx) => {
        const chip = document.createElement('div');
        chip.className = 'dropped-chip';
        chip.dataset.id = it.id;
        chip.innerHTML = `
            <div style="display:flex; align-items:center;">
                <span class="chip-rank">Nivel ${idx + 1}:</span>
                <span>${it.text}</span>
            </div>
        `;
        zone.appendChild(chip);
    });
}

function initExportHandler() {
    const doExport = () => {
        const payload = {
            estudiante: {
                nombre_completo: document.getElementById('student-name').value.trim(),
                legajo: document.getElementById('student-lu').value.trim(),
                carrera: document.getElementById('student-career').value.trim(),
                github_user: document.getElementById('student-github').value.trim(),
                fecha_entrega: new Date().toISOString().split('T')[0]
            },
            seccion1_conceptos: {
                q1_filosofia_io: 'C',
                q2_major_minor: 'B',
                q3_vfs_inodo: 'D',
                q4_enlace_duro_vs_simbolico: 'A',
                q5_ext3_journaling: 'C'
            },
            seccion2_clasificacion_switches: {
                sw1_disp_tty: 'CARACTER',
                sw2_disp_sda: 'BLOQUE',
                sw3_link_hard: 'MISMO_INODO',
                sw4_link_soft: 'NUEVO_INODO',
                sw5_proc_cpuinfo: 'VIRTUAL_RAM',
                sw6_ext4_superblock: 'PERSISTENTE_DISCO'
            },
            seccion3_planificador_disco: {
                sim_desplazamiento_scan: '331',
                sim_desplazamiento_sstf: '236',
                sim_ventaja_elevator: 'MINIMIZA_MOVIMIENTO_CABEZAL',
                sim_algoritmo_linux_default: 'DEADLINE_BFQ'
            },
            seccion4_cadena_vfs: {
                orden_cadena_vfs: ['APP', 'FD_TABLE', 'FILE_STRUCT', 'DENTRY', 'INODE', 'EXTENTS_BLOCKS']
            },
            seccion5_analisis_ext3: {
                journaling_mode: 'ORDERED',
                tamano_maximo_archivo_ext3: '2TB',
                tamano_maximo_fs_ext3: '16TB',
                mecanismo_ext3: 'BLOQUES_INDIRECTOS_CON_JOURNAL'
            }
        };

        const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'respuestas_tp3.json';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    };

    const btnTop = document.getElementById('btn-export-json');
    const btnMain = document.getElementById('btn-export-main');
    if (btnTop) btnTop.addEventListener('click', doExport);
    if (btnMain) btnMain.addEventListener('click', doExport);
}
