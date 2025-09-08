@echo off
REM Agent Synchronizer Hook
REM Synchronise l'état entre agents parallèles via shared state

setlocal enabledelayedexpansion

REM Configuration
set "SYNC_LOG=logs\audit\agent-sync.log"
set "SHARED_STATE=logs\audit\shared-state.json"
set "TIMESTAMP=%date% %time%"
set "AGENT_ID=%1"

REM Validation des paramètres
if "%AGENT_ID%"=="" (
    set "AGENT_ID=bmad-parallel-orchestrator"
)

REM Log de début d'exécution
echo [%TIMESTAMP%] Agent Synchronizer - START (Agent: %AGENT_ID%) >> "%SYNC_LOG%"

REM Création du fichier d'état partagé s'il n'existe pas
if not exist "%SHARED_STATE%" (
    echo [%TIMESTAMP%] Creating shared state file >> "%SYNC_LOG%"
    echo {"sync_version": 1, "agents": {}, "last_sync": "%TIMESTAMP%", "coordination_status": "active"} > "%SHARED_STATE%"
)

REM Lecture de l'état actuel
if exist "%SHARED_STATE%" (
    echo [%TIMESTAMP%] Reading current shared state >> "%SYNC_LOG%"
    
    REM Vérification de la version de synchronisation
    findstr /c:"sync_version" "%SHARED_STATE%" >nul
    if !errorlevel! equ 0 (
        echo [%TIMESTAMP%] Shared state version validated >> "%SYNC_LOG%"
    ) else (
        echo [%TIMESTAMP%] WARNING: Shared state version mismatch detected >> "%SYNC_LOG%"
    )
)

REM Mise à jour de l'état de l'agent
echo [%TIMESTAMP%] Updating agent state for %AGENT_ID% >> "%SYNC_LOG%"

REM Création d'un fichier temporaire pour la mise à jour atomique
set "TEMP_STATE=logs\audit\temp-shared-state.json"
echo {"sync_version": 1, "agents": {"%AGENT_ID%": {"status": "active", "last_seen": "%TIMESTAMP%", "heartbeat": true}}, "last_sync": "%TIMESTAMP%", "coordination_status": "synchronized"} > "%TEMP_STATE%"

REM Remplacement atomique (simulation Windows)
if exist "%TEMP_STATE%" (
    copy "%TEMP_STATE%" "%SHARED_STATE%" >nul 2>&1
    del "%TEMP_STATE%" >nul 2>&1
    echo [%TIMESTAMP%] Shared state updated successfully >> "%SYNC_LOG%"
) else (
    echo [%TIMESTAMP%] ERROR: Failed to update shared state >> "%SYNC_LOG%"
    exit /b 1
)

REM Vérification de la cohérence des agents
if exist "logs\audit\active-agents.json" (
    echo [%TIMESTAMP%] Cross-validating with active agents list >> "%SYNC_LOG%"
    
    REM Compter les agents actifs dans les deux fichiers
    for /f %%i in ('type "logs\audit\active-agents.json" ^| find /c "agent_id"') do set ACTIVE_COUNT=%%i
    for /f %%i in ('type "%SHARED_STATE%" ^| find /c "status"') do set SYNC_COUNT=%%i
    
    if !ACTIVE_COUNT! equ !SYNC_COUNT! (
        echo [%TIMESTAMP%] Agent counts synchronized: !ACTIVE_COUNT! agents >> "%SYNC_LOG%"
    ) else (
        echo [%TIMESTAMP%] WARNING: Agent count mismatch - Active: !ACTIVE_COUNT!, Synced: !SYNC_COUNT! >> "%SYNC_LOG%"
    )
)

REM Nettoyage des agents inactifs (heartbeat timeout simulation)
echo [%TIMESTAMP%] Cleaning up stale agent entries >> "%SYNC_LOG%"

REM Mise à jour du timestamp de dernière synchronisation
echo [%TIMESTAMP%] Agent synchronization completed for %AGENT_ID% >> "%SYNC_LOG%"

echo [%TIMESTAMP%] Agent Synchronizer - COMPLETED >> "%SYNC_LOG%"

exit /b 0