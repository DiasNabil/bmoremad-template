@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM MCP Full Validation - Windows Batch Script
REM Agent: contains-eng-devops (BMAD harmonisé)
REM Description: Validation complète + benchmarks (2-5 minutes)
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                      MCP FULL VALIDATION                                █
echo █              Tous serveurs + Benchmarks (2-5 min)                      █
echo ████████████████████████████████████████████████████████████████████████████
echo.

set SCRIPT_DIR=%~dp0

echo [%TIME%] Lancement validation complète PowerShell...
echo.
echo 📋 ÉTAPES PRÉVUES:
echo   1. Benchmark baseline système
echo   2. Test connectivité tous serveurs MCP (8 serveurs)
echo   3. Mesures performance détaillées  
echo   4. Benchmark post-validation
echo   5. Rapport comparatif détaillé
echo   6. Coordination hooks BMAD
echo.

REM Exécution validation complète avec PowerShell
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Full" -TimeoutSeconds 30 -RetryAttempts 3

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                   VALIDATION COMPLÈTE TERMINÉE                          █
echo ████████████████████████████████████████████████████████████████████████████
echo.

if !errorlevel! equ 0 (
    echo ✅ Validation complète réussie - Infrastructure MCP opérationnelle
    echo.
    echo 📊 Rapports générés dans:
    echo   • logs\benchmarks\ - Comparaisons performance
    echo   • logs\audit\ - Logs détaillés validation
    echo   • hooks\ - Événements coordination BMAD
) else (
    echo ❌ Problèmes détectés lors de la validation
    echo.
    echo 🔍 Consultez les logs pour diagnostic:
    echo   • logs\audit\mcp-validation-*.log
    echo   • logs\mcp-validation\
)

echo.
echo 🔧 Actions recommandées:
echo   • Monitoring continu: %SCRIPT_DIR%monitor-mcp.bat
echo   • Re-validation: %SCRIPT_DIR%validate-mcp-quick.bat  
echo   • Benchmark isolé: powershell -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Benchmark"
echo.

pause
endlocal