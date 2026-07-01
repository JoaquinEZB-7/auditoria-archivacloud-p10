# Auditoría de Seguridad — ArchivaCloud P-10

Este repositorio contiene los entregables de la auditoría de seguridad
realizada sobre la aplicación ArchivaCloud P-10, en el marco de la
asignatura Arquitectura On-Premise y On-Cloud (INACAP).

## Autoría

- **Auditoría realizada por:** Joaquín Eduardo Zambrano Baeza
- **Aplicación auditada (desarrollo original):** ArchivaCloud P-10, desarrollada
  por Jordán Fernández. Código original disponible en:
  https://github.com/JdanFdez2002/AWS-Cloud-E3

Este repositorio contiene únicamente los productos de la auditoría. El código
de la aplicación auditada no se reproduce aquí; se referencia su repositorio
original.

## Contenido

- `informe/` — Informe técnico de la auditoría (PDF) y resumen ejecutivo (PDF).
- `iac/` — Código de Infraestructura como Código (Terraform) de la
  arquitectura objetivo propuesta.
- `scripts/` — Comandos de las pruebas dinámicas de la Fase 3 (`pruebas.sh`) y (`fase4_cloud.sh` incluye los comandos AWS CLI y sus resultados). 
- `evidencias/` — Capturas de los hallazgos y salidas de la Fase 4
- `modelo-amenazas/` — DFD nivel 1, matriz STRIDE y diagrama de arquitectura
  objetivo.

## Reproducción de las pruebas

**Consideración ética:** todas las pruebas se ejecutaron exclusivamente sobre
una instancia propia desplegada en un entorno de laboratorio (AWS Academy),
conforme al alcance ético descrito en el informe y a la Ley 21.459. No deben
ejecutarse contra infraestructura ajena.

Requisitos previos:
- Backend (FastAPI) corriendo en `localhost:8000`.
- Frontend (React + Vite) corriendo en `localhost:5173`.
- Un bucket S3 de pruebas propio y credenciales temporales de laboratorio.

Pasos:
1. Desplegar la aplicación siguiendo las instrucciones de su repositorio original.
2. Ejecutar las pruebas de la Fase 3 con `bash scripts/pruebas.sh` (o comando
   por comando, según se documenta en el archivo).
3. Los resultados esperados de cada prueba se encuentran en `evidencias/`.
4. La auditoría de configuración cloud (Fase 4) se reproduce con los comandos
   AWS CLI documentados en `evidencias/fase4_cloud.txt`.
