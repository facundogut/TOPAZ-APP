import os
import sys
import xml.etree.ElementTree as ET

REQUIRED_DIRS = ["biblioteca", "jboss", "shared_sync", "sql"]
XML_EXTS = (".xml", ".ktr", ".kjb", ".jrxml")

def fail(msg):
    print("ERROR:", msg)
    sys.exit(1)

def ok(msg):
    print("OK:", msg)

# Normalización de paths (Linux/Windows) para aplicar ignores por prefijo
def norm_rel(path):
    return os.path.relpath(path, ".").replace("\\", "/").lstrip("./")

IGNORED_PREFIXES = [
    "sql/scripts_viejos/",
    "sql/scripts-flyway-6.5.1/",
    "biblioteca/FML/",
    "jboss/standalone/userlibrary/default/python/topsystems/",
    "jboss/standalone/userlibrary/default/conf/"
]

def is_ignored(rel_path):
    rp = rel_path.replace("\\", "/").lstrip("./")
    rp = rp + "/" if os.path.isdir(rel_path) and not rp.endswith("/") else rp
    return any(rp.startswith(pref) for pref in IGNORED_PREFIXES)

# 1) Estructura mínima
for d in REQUIRED_DIRS:
    if not os.path.isdir(d):
        fail(f"Falta directorio requerido: {d}")
ok("Estructura mínima presente")

# 2) Archivos vacíos (permitidos por extensión o nombre), ignorando carpetas legacy
ALLOWED_EMPTY_EXTENSIONS = {".txt", ".TXT", ".LCK", ".XML", ".gitignore"}
ALLOWED_EMPTY_NAMES = {".gitignore", ".gitkeep"}

empty = []

for root, _, files in os.walk("."):
    for f in files:
        full = os.path.join(root, f)
        rel = norm_rel(full)

        # Ignorar carpetas completas
        if is_ignored(rel):
            continue

        try:
            if os.path.getsize(full) == 0:
                name, ext = os.path.splitext(f)

                # Permitir vacíos por nombre o por extensión (case-insensitive)
                if f in ALLOWED_EMPTY_NAMES:
                    continue

                if ext.upper() in {e.upper() for e in ALLOWED_EMPTY_EXTENSIONS}:
                    continue

                empty.append(rel)

        except OSError:
            pass

if empty:
    print("ERROR: Archivos vacíos no permitidos (primeros 50):")
    for p in empty[:50]:
        print(" -", p)
    sys.exit(1)

ok("No hay archivos vacíos no permitidos")

# 3) XML well-formed (ktr/kjb/jrxml/xml) ignorando carpetas legacy
bad_xml = []

for root, _, files in os.walk("."):
    for f in files:
        if not f.lower().endswith(XML_EXTS):
            continue

        full = os.path.join(root, f)
        rel = norm_rel(full)

        # Ignorar carpetas completas
        if is_ignored(rel):
            continue

        try:
            # Si está vacío, el control de vacíos ya decide (no parsear acá)
            if os.path.getsize(full) == 0:
                continue

            ET.parse(full)

        except Exception as e:
            bad_xml.append((rel, str(e)))

if bad_xml:
    print("ERROR: XML inválidos (primeros 20):")
    for p, e in bad_xml[:20]:
        print(" -", p, "=>", e)
    sys.exit(1)

ok("XML well-formed")
print("SMOKE OK")
