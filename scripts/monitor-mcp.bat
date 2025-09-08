@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM MCP Real-Time Monitoring - Windows Batch Script
REM Agent: contains-eng-devops (BMAD harmonisé)  
REM Description: Monitoring temps réel avec alerting automatique
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                     MCP REAL-TIME MONITORING                            █
echo █                   Surveillance continue + Alerting                      █  
echo ████████████████████████████████████████████████████████████████████████████
echo.

set SCRIPT_DIR=%~dp0

echo 📡 MONITORING MCP INFRASTRUCTURE
echo.
echo Modes disponibles:
echo   [1] Monitoring court (1 heure, intervalle 10s)
echo   [2] Monitoring étendu (8 heures, intervalle 30s) 
echo   [3] Monitoring continu (24h+, intervalle 60s)
echo   [4] Monitoring custom
echo.

choice /c 1234 /n /m "Sélectionnez un mode [1-4]: "
set MONITORING_MODE=!errorlevel!

echo.

if !MONITORING_MODE! equ 1 (
    echo 🕐 Mode court sélectionné: 1h, refresh 10s
    echo [%TIME%] Lancement monitoring PowerShell...
    echo.
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Monitor" -ContinuousMonitoring:$false
) else if !MONITORING_MODE! equ 2 (
    echo 🕐 Mode étendu sélectionné: 8h, refresh 30s  
    echo [%TIME%] Lancement monitoring PowerShell...
    echo.
    echo ⚠️  ATTENTION: Monitoring de 8 heures en cours...
    echo    - Utilisez Ctrl+C pour arrêter
    echo    - Logs en temps réel dans logs\monitoring\
    echo    - Alertes automatiques si problèmes détectés
    echo.
    powershell -ExecutionPolicy Bypass -Command "& { & '%SCRIPT_DIR%mcp-infrastructure-validator.ps1' -ValidationMode 'Monitor' -ContinuousMonitoring:$false; $interval = 30; $duration = 480; Write-Host 'Monitoring étendu: ${duration} min, intervalle ${interval}s'; Start-RealTimeMonitoring -IntervalSeconds $interval -DurationMinutes $duration }"
) else if !MONITORING_MODE! equ 3 (
    echo 🕐 Mode continu sélectionné: 24h+, refresh 60s
    echo [%TIME%] Lancement monitoring PowerShell...  
    echo.
    echo ⚠️  ATTENTION: Monitoring continu 24h+ en cours...
    echo    - Processus en arrière-plan
    echo    - Utilisez Gestionnaire des tâches pour arrêter
    echo    - Logs détaillés + alertes automatiques
    echo    - Status visible dans logs\monitoring\dashboard.html
    echo.
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Monitor" -ContinuousMonitoring:$true
) else (
    echo 🕐 Mode custom sélectionné
    echo.
    set /p CUSTOM_DURATION="Durée en minutes (défaut 60): "
    set /p CUSTOM_INTERVAL="Intervalle en secondes (défaut 15): "
    
    if "!CUSTOM_DURATION!"=="" set CUSTOM_DURATION=60
    if "!CUSTOM_INTERVAL!"=="" set CUSTOM_INTERVAL=15
    
    echo Configuration custom: !CUSTOM_DURATION! min, refresh !CUSTOM_INTERVAL!s
    echo [%TIME%] Lancement monitoring PowerShell...
    echo.
    
    powershell -ExecutionPolicy Bypass -Command "& { & '%SCRIPT_DIR%mcp-infrastructure-validator.ps1' -ValidationMode 'Monitor'; $interval = !CUSTOM_INTERVAL!; $duration = !CUSTOM_DURATION!; Start-RealTimeMonitoring -IntervalSeconds $interval -DurationMinutes $duration }"
)

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                      MONITORING TERMINÉ                                 █
echo ████████████████████████████████████████████████████████████████████████████
echo.

if !errorlevel! equ 0 (
    echo ✅ Monitoring terminé normalement
) else (
    echo ⚠️  Monitoring interrompu - Vérifier les logs
)

echo.
echo 📊 RÉSULTATS MONITORING:
echo   • Logs temps réel: logs\mcp-validation\monitoring-*.json
echo   • Alertes: logs\audit\alerts-*.json  
echo   • Métriques: logs\benchmarks\
echo   • Status coordination: hooks\bmad-coordination-events.json
echo.

echo 🔧 ACTIONS POST-MONITORING:
echo   • Validation rapide: %SCRIPT_DIR%validate-mcp-quick.bat
echo   • Nouveau monitoring: %SCRIPT_DIR%monitor-mcp.bat
echo   • Analyse benchmarks: powershell -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Benchmark"
echo.

pause
endlocal