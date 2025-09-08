@echo off
REM =====================================================
REM BMAD+Contains Studio 48h Performance Monitor Setup
REM Phase 1 deployment monitoring system
REM =====================================================

setlocal EnableDelayedExpansion

set "PROJECT_DIR=%~dp0.."
set "MONITOR_LOG=%PROJECT_DIR%\logs\monitoring\48h-performance.log"
set "TIMESTAMP=%date% %time%"

REM Create monitoring directory
if not exist "%PROJECT_DIR%\logs\monitoring" mkdir "%PROJECT_DIR%\logs\monitoring"

REM Create monitoring startup log
echo [%TIMESTAMP%] 48h Performance monitoring initiated >> "%MONITOR_LOG%"
echo [%TIMESTAMP%] Phase 1 hooks deployment monitoring active >> "%MONITOR_LOG%"
echo [%TIMESTAMP%] Monitoring will run for 48 hours from %TIMESTAMP% >> "%MONITOR_LOG%"

REM Create monitoring configuration
echo {> "%PROJECT_DIR%\logs\monitoring\monitor-config.json"
echo   "start_time": "%TIMESTAMP%",>> "%PROJECT_DIR%\logs\monitoring\monitor-config.json"
echo   "duration_hours": 48,>> "%PROJECT_DIR%\logs\monitoring\monitor-config.json"
echo   "monitoring_active": true,>> "%PROJECT_DIR%\logs\monitoring\monitor-config.json"
echo   "phase": "Phase 1 - Hooks Deployment">> "%PROJECT_DIR%\logs\monitoring\monitor-config.json"
echo }>> "%PROJECT_DIR%\logs\monitoring\monitor-config.json"

echo [%TIMESTAMP%] Performance monitoring setup completed >> "%MONITOR_LOG%"
echo Phase 1 monitoring setup completed successfully!
echo Monitoring logs will be written to: %MONITOR_LOG%
echo Monitor configuration: %PROJECT_DIR%\logs\monitoring\monitor-config.json

exit /b 0