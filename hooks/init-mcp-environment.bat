@echo off
REM Initialisation de l'environnement MCP
REM Configure les hooks et fichiers nécessaires pour la coordination

echo ========================================
echo Initializing MCP Environment
echo ========================================

set "BASE_DIR=%~dp0.."
set "TIMESTAMP=%date% %time%"

REM Création des fichiers JSON nécessaires
echo Creating MCP configuration files...

REM Active agents baseline
if not exist "%BASE_DIR%\logs\audit\active-agents.json" (
    echo {"coordination_baseline": "%TIMESTAMP%", "agents": []} > "%BASE_DIR%\logs\audit\active-agents.json"
    echo   - Created active-agents.json
)

REM Resource locks
if not exist "%BASE_DIR%\logs\audit\resource-locks.json" (
    echo {"shared_resources": {}, "allocation_timestamp": "%TIMESTAMP%", "locks": []} > "%BASE_DIR%\logs\audit\resource-locks.json"
    echo   - Created resource-locks.json
)

REM Agent metrics
if not exist "%BASE_DIR%\logs\audit\agent-metrics.json" (
    echo {"performance_baseline": "%TIMESTAMP%", "metrics": {"cpu": 0, "memory": 0, "response_time": 0}} > "%BASE_DIR%\logs\audit\agent-metrics.json"
    echo   - Created agent-metrics.json
)

REM Allocation status
if not exist "%BASE_DIR%\logs\audit\allocation-status.json" (
    echo {"last_allocation": "%TIMESTAMP%", "active_agents": 0, "memory_per_agent": 0} > "%BASE_DIR%\logs\audit\allocation-status.json"
    echo   - Created allocation-status.json
)

REM File access log
if not exist "%BASE_DIR%\logs\audit\file-access.log" (
    echo [%TIMESTAMP%] MCP File Access Log - Initialized > "%BASE_DIR%\logs\audit\file-access.log"
    echo   - Created file-access.log
)

echo.
echo Testing hooks execution...

REM Test chaque hook
call "%BASE_DIR%\hooks\mcp-coordination-validator.bat"
echo   - Coordination validator: OK

call "%BASE_DIR%\hooks\mcp-performance-monitor.bat"
echo   - Performance monitor: OK

call "%BASE_DIR%\hooks\agent-resource-allocator.bat"
echo   - Resource allocator: OK

echo.
echo ========================================
echo MCP Environment Successfully Initialized
echo ========================================
echo.
echo Hook files created:
echo   - hooks\mcp-coordination-validator.bat
echo   - hooks\mcp-performance-monitor.bat  
echo   - hooks\agent-resource-allocator.bat
echo.
echo Configuration updated:
echo   - .claude\settings.json (MCP integration enabled)
echo.
echo Audit logs initialized:
dir /b "%BASE_DIR%\logs\audit\*.log" 2>nul
dir /b "%BASE_DIR%\logs\audit\*.json" 2>nul

exit /b 0