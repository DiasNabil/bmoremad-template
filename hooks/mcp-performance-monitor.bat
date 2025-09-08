@echo off
REM MCP Performance Monitor Hook
REM Surveille les performances des agents parallèles

setlocal enabledelayedexpansion

REM Configuration
set "PERF_LOG=logs\audit\mcp-performance.log"
set "TIMESTAMP=%date% %time%"
set "CPU_THRESHOLD=80"
set "MEMORY_THRESHOLD=75"

REM Log de début d'exécution
echo [%TIMESTAMP%] MCP Performance Monitor - START >> "%PERF_LOG%"

REM Récupération des métriques système
for /f "tokens=2 delims==" %%i in ('wmic cpu get loadpercentage /value ^| find "="') do set CPU_USAGE=%%i
for /f "tokens=4" %%i in ('wmic OS get TotalVisibleMemorySize^,FreePhysicalMemory /format:value ^| find "FreePhysicalMemory"') do set FREE_MEM=%%i
for /f "tokens=4" %%i in ('wmic OS get TotalVisibleMemorySize^,FreePhysicalMemory /format:value ^| find "TotalVisibleMemorySize"') do set TOTAL_MEM=%%i

REM Calcul du pourcentage de mémoire utilisée
set /a USED_MEM_PERCENT=100-(!FREE_MEM!*100/!TOTAL_MEM!)

echo [%TIMESTAMP%] System Metrics - CPU: %CPU_USAGE%%% Memory: !USED_MEM_PERCENT!%% >> "%PERF_LOG%"

REM Vérification des seuils CPU
if %CPU_USAGE% GTR %CPU_THRESHOLD% (
    echo [%TIMESTAMP%] WARNING: High CPU usage - %CPU_USAGE%%% ^> %CPU_THRESHOLD%%% >> "%PERF_LOG%"
    echo [%TIMESTAMP%] Recommending agent load balancing >> "%PERF_LOG%"
)

REM Vérification des seuils mémoire
if !USED_MEM_PERCENT! GTR %MEMORY_THRESHOLD% (
    echo [%TIMESTAMP%] WARNING: High memory usage - !USED_MEM_PERCENT!%% ^> %MEMORY_THRESHOLD%%% >> "%PERF_LOG%"
    echo [%TIMESTAMP%] Recommending agent resource optimization >> "%PERF_LOG%"
)

REM Contrôle des processus Claude/MCP
tasklist /fi "imagename eq claude*" /fo csv | find /c "claude" > nul
if !errorlevel! equ 0 (
    for /f %%i in ('tasklist /fi "imagename eq claude*" /fo csv ^| find /c "claude"') do (
        echo [%TIMESTAMP%] Active Claude processes: %%i >> "%PERF_LOG%"
    )
)

REM Métriques de performance des agents
if exist "logs\audit\agent-metrics.json" (
    echo [%TIMESTAMP%] Reading agent performance metrics... >> "%PERF_LOG%"
    
    REM Log la taille du fichier de métriques
    for %%F in ("logs\audit\agent-metrics.json") do (
        echo [%TIMESTAMP%] Agent metrics file size: %%~zF bytes >> "%PERF_LOG%"
    )
)

echo [%TIMESTAMP%] MCP Performance Monitor - COMPLETED >> "%PERF_LOG%"

exit /b 0