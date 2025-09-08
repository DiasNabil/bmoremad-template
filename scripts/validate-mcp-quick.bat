@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM MCP Quick Validation - Windows Batch Script  
REM Agent: contains-eng-devops (BMAD harmonisé)
REM Description: Validation rapide serveurs critiques (< 30 secondes)
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                     MCP QUICK VALIDATION                                █
echo █               Serveurs critiques uniquement (^<30s)                     █
echo ████████████████████████████████████████████████████████████████████████████
echo.

set SCRIPT_DIR=%~dp0

echo [%TIME%] Lancement validation PowerShell...
echo.

REM Exécution validation rapide avec PowerShell
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Quick" -TimeoutSeconds 10 -RetryAttempts 1

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                    VALIDATION RAPIDE TERMINÉE                           █
echo ████████████████████████████████████████████████████████████████████████████
echo.

if !errorlevel! equ 0 (
    echo ✅ Validation rapide réussie - Serveurs critiques opérationnels
) else (
    echo ❌ Problèmes détectés - Consulter les logs pour plus de détails
)

echo.
echo Pour une validation complète: %SCRIPT_DIR%validate-mcp-full.bat
echo Pour monitoring temps réel: %SCRIPT_DIR%monitor-mcp.bat
echo.

pause
endlocal