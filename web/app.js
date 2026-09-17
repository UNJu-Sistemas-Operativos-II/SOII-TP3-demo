/**
 * SISTEMAS OPERATIVOS II - UNJu - CICLO LECTIVO 2026
 * Laboratorio Interactivo Web - TP N° 3 (DEMOSTRACIÓN DOCENTE)
 */

document.addEventListener('DOMContentLoaded', () => {
    initBiblioToggles();
    initDragAndDrop();
    initExportHandler();
    // Auto populate demo dropzone
    populateDemoZone();
});

function initBiblioToggles() {
    document.querySelectorAll('.biblio-header').forEach(header => {
        header.addEventListener('click', () => {
            header.closest('.biblio-guide').classList.toggle('open');
        });
    });
}

function initDragAndDrop() {
    const bankItems = document.querySelectorAll('.action-bank .dnd-item');
    const dropzone = document.getElementById('zone-stack');

    bankItems.forEach(item => {
        item.addEventListener('dragstart', (e) => {
            e.dataTransfer.setData('text/plain', JSON.stringify({
                id: item.dataset.id,
                text: item.innerText.trim()
            }));
            e.dataTransfer.effectAllowed = 'copy';
        });

        item.addEventListener('click', () => {
            addItemToZone(dropzone, item.dataset.id, item.innerText.trim());
        });
    });

    dropzone.addEventListener('dragover', (e) => {
        e.preventDefault();
        dropzone.classList.add('dragover');
    });

    dropzone.addEventListener('dragleave', () => dropzone.classList.remove('dragover'));

    dropzone.addEventListener('drop', (e) => {
        e.preventDefault();
        dropzone.classList.remove('dragover');
        try {
            const data = JSON.parse(e.dataTransfer.getData('text/plain'));
            addItemToZone(dropzone, data.id, data.text);
        } catch (err) {}
    });
}

function populateDemoZone() {
    const dropzone = document.getElementById('zone-stack');
    const demoItems = [
        { id: 'APP', text: '💻 Aplicación de Usuario (User Space)' },
        { id: 'SYSCALL', text: '📞 Interfaz de Llamadas al Sistema (Syscalls)' },
        { id: 'VFS', text: '🌐 Virtual File System (VFS)' },
        { id: 'FS_DRIVER', text: '🗂️ Sistema de Archivos Concreto (ext3/Buffer Cache)' },
        { id: 'DEVICE_DRIVER', text: '⚙️ Manejador de Dispositivo (Device Driver)' },
        { id: 'HARDWARE', text: '💾 Controlador de Hardware y Disco Físico' }
    ];
    dropzone.querySelectorAll('.dropped-chip').forEach(c => c.remove());
    demoItems.forEach(item => addItemToZone(dropzone, item.id, item.text));
}

function addItemToZone(zone, id, text) {
    const existing = zone.querySelectorAll('.dropped-chip');
    for (let c of existing) {
        if (c.dataset.id === id) return;
    }
    if (existing.length >= 6) return;

    const placeholder = zone.querySelector('.drop-placeholder');
    if (placeholder) placeholder.style.display = 'none';

    const currentRank = existing.length + 1;
    const chip = document.createElement('div');
    chip.className = 'dropped-chip';
    chip.dataset.id = id;
    chip.innerHTML = `
        <div style="display: flex; align-items: center;">
            <span class="chip-rank">Nivel ${currentRank}:</span>
            <span>${text}</span>
        </div>
        <button type="button" class="chip-delete" title="Eliminar">✕</button>
    `;

    chip.querySelector('.chip-delete').addEventListener('click', (e) => {
        e.stopPropagation();
        chip.remove();
        reindexZone(zone);
    });

    zone.appendChild(chip);
    reindexZone(zone);
}

function reindexZone(zone) {
    const chips = zone.querySelectorAll('.dropped-chip');
    const placeholder = zone.querySelector('.drop-placeholder');
    if (chips.length === 0 && placeholder) placeholder.style.display = 'block';
    chips.forEach((c, idx) => {
        const rank = c.querySelector('.chip-rank');
        if (rank) rank.textContent = `Nivel ${idx + 1}:`;
    });
}

function resetZone(zoneId) {
    const zone = document.getElementById(zoneId);
    if (!zone) return;
    zone.querySelectorAll('.dropped-chip').forEach(c => c.remove());
    const placeholder = zone.querySelector('.drop-placeholder');
    if (placeholder) placeholder.style.display = 'block';
}

function initExportHandler() {
    document.getElementById('btn-export').addEventListener('click', () => {
        const payload = {
            estudiante: {
                nombre_completo: document.getElementById('student-name').value.trim(),
                legajo: document.getElementById('student-lu').value.trim(),
                github_user: document.getElementById('student-github').value.trim(),
                fecha_entrega: new Date().toISOString().split('T')[0]
            },
            seccion1_conceptos: {
                q1_filosofia_io: document.querySelector('input[name="q1_filosofia_io"]:checked').value,
                q2_major_minor: document.querySelector('input[name="q2_major_minor"]:checked').value,
                q3_vfs_inodo: document.querySelector('input[name="q3_vfs_inodo"]:checked').value,
                q4_enlace_duro_vs_simbolico: document.querySelector('input[name="q4_enlace_duro_vs_simbolico"]:checked').value,
                q5_ext3_journaling: document.querySelector('input[name="q5_ext3_journaling"]:checked').value
            },
            seccion2_pila_io: {
                orden_pila_io: Array.from(document.querySelectorAll('#zone-stack .dropped-chip')).map(c => c.dataset.id)
            },
            seccion3_analisis_ext3: {
                journaling_mode: document.getElementById('ext3-journaling').value,
                tamano_maximo_archivo_ext3: document.getElementById('ext3-max-file').value,
                tamano_maximo_fs_ext3: document.getElementById('ext3-max-fs').value,
                mecanismo_ext3: document.getElementById('ext3-mecanismo').value
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
    });
}
