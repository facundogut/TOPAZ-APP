import os, sys
import xml.etree.ElementTree as ET

REQUIRED_DIRS = ["biblioteca", "jboss", "shared_sync", "sql"]
XML_EXTS = (".xml", ".ktr", ".kjb", ".jrxml")

def fail(msg):
    print("ERROR:", msg)
    sys.exit(1)

def ok(msg):
    print("OK:", msg)

# 1) Estructura mínima
for d in REQUIRED_DIRS:
    if not os.path.isdir(d):
        fail(f"Falta directorio requerido: {d}")
ok("Estructura mínima presente")

# 2) Archivos vacíos
ALLOWED_EMPTY_EXTENSIONS = {".txt", ".LCK", ".XML", ".gitignore", ".TXT"}

IGNORED_DIRS = [
    os.path.normpath("sql/scripts_viejos"),
    os.path.normpath("sql/scripts-flyway-6.5.1"),
    os.path.normpath("biblioteca/FML"),
    os.path.normpath("jboss/standalone/userlibrary/default/python/topsystems"),
]

def is_ignored_path(path):
    norm = os.path.normpath(path)
    return any(norm.startswith(d + os.sep) or norm == d for d in IGNORED_DIRS)

empty = []

for root, _, files in os.walk("."):
    for f in files:
        p = os.path.join(root, f)
        rel_path = os.path.normpath(os.path.relpath(p, "."))

        try:
            if os.path.getsize(p) == 0:
                # Ignorar carpetas completas
                if is_ignored_path(rel_path):
                    continue

                _, ext = os.path.splitext(f)

                # Permitir extensiones vacías específicas
                if ext not in ALLOWED_EMPTY_EXTENSIONS:
                    empty.append(rel_path)

        except OSError:
            pass

if empty:
    print("ERROR: Archivos vacíos no permitidos (primeros 50):")
    for p in empty[:50]:
        print(" -", p)
    sys.exit(1)

ok("No hay archivos vacíos no permitidos")

# 3) XML well-formed (ktr/kjb/jrxml/xml)
bad_xml = []
for root, _, files in os.walk("."):
    for f in files:
        if f.lower().endswith(XML_EXTS):
            p = os.path.join(root, f)
            try:
                ET.parse(p)
            except Exception as e:
                bad_xml.append((p, str(e)))

if bad_xml:
    print("ERROR: XML inválidos (primeros 20):")
    for p, e in bad_xml[:20]:
        print(" -", p, "=>", e)
    sys.exit(1)

ok("XML well-formed")
print("SMOKE OK")
