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

# 2) Archivos vacíos (en todo el repo)
empty = []
for root, _, files in os.walk("."):
    for f in files:
        p = os.path.join(root, f)
        try:
            if os.path.getsize(p) == 0:
                empty.append(p)
        except OSError:
            pass

if empty:
    print("ERROR: Archivos vacíos detectados (primeros 50):")
    for p in empty[:50]:
        print(" -", p)
    sys.exit(1)
ok("No hay archivos vacíos")

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
