@echo off
REM ====================================================================
REM MCP Coordination Validator Hook - BMad Parallel Orchestrator
REM Valide la coordination entre agents parallèles MCP
REM ====================================================================

setlocal enabledelayedexpansion

REM Configuration des chemins
set "AUDIT_DIR=logs\audit"
set "COORDINATION_LOG=%AUDIT_DIR%\mcp-coordination.log"
set "ACTIVE_AGENTS=%AUDIT_DIR%\active-agents.json"
set "RESOURCE_LOCKS=%AUDIT_DIR%\resource-locks.json"

REM Créer le répertoire audit s'il n'existe pas
if not exist "%AUDIT_DIR%" mkdir "%AUDIT_DIR%"

REM Timestamp pour les logs
for /f "tokens=1-3 delims=/" %%a in ('date /t') do set "current_date=%%c-%%a-%%b"
for /f "tokens=1-2 delims= " %%a in ('time /t') do set "current_time=%%a"
set "timestamp=%current_date% %current_time%"

echo [%timestamp%] MCP Coordination Validator - Debut validation >> "%COORDINATION_LOG%"

REM Vérifier les agents actifs
if not exist "%ACTIVE_AGENTS%" (
    echo [] > "%ACTIVE_AGENTS%"
    echo [%timestamp%] Fichier active-agents.json initialisé >> "%COORDINATION_LOG%"
)

REM Vérifier les verrous de ressources
if not exist "%RESOURCE_LOCKS%" (
    echo {} > "%RESOURCE_LOCKS%"
    echo [%timestamp%] Fichier resource-locks.json initialisé >> "%COORDINATION_LOG%"
)

REM Validation de la coordination
set "validation_ok=1"

REM Compter les agents actifs
for /f %%i in ('findstr /c:"bmad-" "%ACTIVE_AGENTS%" 2^>nul ^| find /c /v ""') do set "active_count=%%i"

REM Vérifier le nombre maximum d'agents
if !active_count! gtr 3 (
    echo [%timestamp%] ERREUR: Trop d'agents actifs (!active_count!/3) >> "%COORDINATION_LOG%"
    set "validation_ok=0"
)

REM Vérifier les conflits de ressources
findstr /c:"locked" "%RESOURCE_LOCKS%" >nul 2>&1
if !errorlevel! equ 0 (
    echo [%timestamp%] AVERTISSEMENT: Ressources verrouillées détectées >> "%COORDINATION_LOG%"
)

if !validation_ok! equ 1 (
    echo [%timestamp%] Validation coordination MCP - SUCCÈS >> "%COORDINATION_LOG%"
    exit /b 0
) else (
    echo [%timestamp%] Validation coordination MCP - ÉCHEC >> "%COORDINATION_LOG%"
    exit /b 1
)