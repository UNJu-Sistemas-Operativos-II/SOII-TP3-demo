#!/usr/bin/env python3
"""
=============================================================================
EVALUADOR AUTOMÁTICO DE TRABAJOS PRÁCTICOS - SISTEMAS OPERATIVOS II
Universidad Nacional de Jujuy (UNJu - Facultad de Ingeniería)
Ciclo Lectivo 2026 | Titular: Ing. María Fernanda Vázquez | JTP: Ing. Fabio D. Argañaraz
=============================================================================
Módulo de Evaluación Criptográfica del TP N° 3 (DEMOSTRACIÓN DOCENTE EXPANDIDA)
"""

import sys
import os
import json
import hashlib
import argparse
from datetime import datetime

if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RUBRIC_FILE = os.path.join(SCRIPT_DIR, "rubric_tp3_demo.json")
CATEDRA_SALT = "SOII_UNJu_FI_2026_CatedraVazquez_SecretSalt"

def compute_hash(ex_id, item_key, val):
    clean_val = str(val).strip().lower() if val is not None else ""
    raw = f"{ex_id}:{item_key}:{clean_val}:{CATEDRA_SALT}"
    return hashlib.sha256(raw.encode('utf-8')).hexdigest()

def load_json(filepath):
    if not os.path.exists(filepath):
        print(f"[ERROR] No se encontró el archivo: {filepath}", file=sys.stderr)
        sys.exit(1)
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"[ERROR] Error al leer JSON '{filepath}': {e}", file=sys.stderr)
        sys.exit(1)

def grade_submission(submission, rubric):
    student = submission.get("estudiante", {})
    exercises_rubric = rubric.get("exercises", {})
    
    total_score = 0
    max_total_score = rubric.get("max_score", 100)
    exercise_results = {}

    for ex_id, ex_spec in exercises_rubric.items():
        weight = ex_spec.get("weight", 10)
        feedback = ex_spec.get("feedback", "")
        ex_score = 0
        details = []

        student_data = submission.get(ex_id, {})

        if "hashes" in ex_spec:
            expected_hashes = ex_spec["hashes"]

            if ex_spec.get("type") == "ordered_list":
                items_list = expected_hashes.get("items", [])
                total_items = len(items_list)
                correct_items_count = 0
                list_key = ex_spec.get("list_key", "orden_cadena_vfs")
                actual_list = student_data.get(list_key, [])
                for idx, exp_hash in enumerate(items_list):
                    actual_val = actual_list[idx] if idx < len(actual_list) else None
                    actual_hash = compute_hash(ex_id, f"pos_{idx}", actual_val)
                    is_correct = (actual_hash == exp_hash)
                    if is_correct:
                        correct_items_count += 1
                    details.append({
                        "item": f"Nivel {idx + 1}",
                        "submitted": actual_val,
                        "is_correct": is_correct
                    })
                if total_items > 0:
                    ex_score = round((correct_items_count / total_items) * weight, 2)
            else:
                total_items = len(expected_hashes)
                correct_items_count = 0
                for item_key, exp_hash in expected_hashes.items():
                    actual_val = student_data.get(item_key)
                    actual_hash = compute_hash(ex_id, item_key, actual_val)
                    is_correct = (actual_hash == exp_hash)
                    if is_correct:
                        correct_items_count += 1
                    details.append({
                        "item": item_key,
                        "submitted": actual_val,
                        "is_correct": is_correct
                    })
                if total_items > 0:
                    ex_score = round((correct_items_count / total_items) * weight, 2)

        total_score += ex_score
        exercise_results[ex_id] = {
            "title": ex_spec.get("title", ex_id),
            "score": ex_score,
            "max_score": weight,
            "passed": (ex_score == weight),
            "feedback": feedback,
            "details": details
        }

    total_score = round(total_score, 2)
    return {
        "estudiante": student,
        "total_score": total_score,
        "max_score": max_total_score,
        "passed": (total_score >= max_total_score),
        "exercise_results": exercise_results,
        "evaluated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

def print_report(results):
    GREEN = "\033[92m"
    RED = "\033[91m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    BOLD = "\033[1m"
    RESET = "\033[0m"

    est = results.get("estudiante", {})
    print(f"\n{BLUE}{'='*74}{RESET}")
    print(f"{BOLD}  REPORTE DE EVALUACIÓN AUTOMÁTICA - DEMOSTRACIÓN DOCENTE TP 3{RESET}")
    print(f"  Cátedra: Sistemas Operativos II (UNJu - Ciclo Lectivo 2026)")
    print(f"{BLUE}{'='*74}{RESET}")
    print(f"  {BOLD}Docente:{RESET}     {est.get('nombre_completo', 'N/A')}")
    print(f"  {BOLD}Identificador:{RESET} {est.get('legajo', 'N/A')}")
    print(f"  {BOLD}GitHub:{RESET}      {est.get('github_user', 'N/A')}")
    print(f"  {BOLD}Fecha Eval:{RESET}  {results.get('evaluated_at')}")
    print(f"{BLUE}{'-'*74}{RESET}")

    for ex_id, data in results["exercise_results"].items():
        status_symbol = f"{GREEN}✓ PASS{RESET}" if data["passed"] else f"{RED}✗ FAIL{RESET}"
        score_str = f"{data['score']}/{data['max_score']} Pts"
        print(f"\n  {BOLD}{data['title']}{RESET}")
        print(f"  Estado: {status_symbol} [{score_str}]")
        
        for d in data.get("details", []):
            mark = f"{GREEN}✓{RESET}" if d["is_correct"] else f"{RED}✗{RESET}"
            sub_val = d['submitted'] if d['submitted'] is not None else "(vacío)"
            print(f"    {mark} {d['item']}: {sub_val}")

    print(f"\n{BLUE}{'='*74}{RESET}")
    total = results["total_score"]
    max_s = results["max_score"]
    if results["passed"]:
        print(f"  {BOLD}{GREEN}CALIFICACIÓN DOCENTE: {total} / {max_s} Pts — ¡DEMOSTRACIÓN EXITOSA! ✅{RESET}")
    else:
        print(f"  {BOLD}{RED}CALIFICACIÓN: {total} / {max_s} Pts — REVISAR RESPUESTAS ❌{RESET}")
    print(f"{BLUE}{'='*74}{RESET}\n")

def main():
    parser = argparse.ArgumentParser(description="Autograder criptográfico para SOII - TP3 Demo")
    parser.add_argument("submission", help="Ruta al archivo de respuestas JSON de la demo")
    parser.add_argument("--rubric", default=RUBRIC_FILE, help="Ruta a la rúbrica pública JSON")
    parser.add_argument("--json", action="store_true", help="Salida exclusivamente en formato JSON")
    args = parser.parse_args()

    rubric = load_json(args.rubric)
    submission = load_json(args.submission)
    results = grade_submission(submission, rubric)

    if args.json:
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        print_report(results)

    if results["passed"]:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
