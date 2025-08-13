# CyberArk API Tools

Scripts y utilidades en PowerShell para interactuar con la API REST de CyberArk Privilege Cloud (Gen2 clásico).

## 📌 Objetivo

Este repositorio contiene scripts reutilizables para:

- Consultar uso de licencias
- Gestionar cuentas privilegiadas
- Forzar rotación de contraseñas
- Automatizar flujos de onboarding/offboarding
- Integraciones con otros sistemas

## 📂 Estructura

| Script                     | Descripción                                        |
|---------------------------|----------------------------------------------------|
| `Get-LicenseUsage.ps1`    | Consulta y exporta uso de licencias actuales       |
| `Get-AccountsFromSafe.ps1`| (Ejemplo) Lista todas las cuentas de un safe       |
| `Rotate-Password.ps1`     | (Ejemplo) Fuerza rotación inmediata de una cuenta  |

## 📦 Requisitos

- PowerShell 5.x o PowerShell Core
- Acceso a una instancia de CyberArk Privilege Cloud (Gen2 clásico)
- Usuario con permisos de API

## 🔐 Seguridad

> Este repositorio no almacena tokens ni contraseñas. Se recomienda ejecutar los scripts desde entornos seguros.

## 📄 Licencia

MIT License – ver archivo [LICENSE](LICENSE)
