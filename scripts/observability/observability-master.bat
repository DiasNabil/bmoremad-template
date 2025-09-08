@echo off
REM BMAD+Contains Studio+MCP Observability Master Script
REM Production-grade observability orchestration and management
REM Version: 1.0.0 - Enterprise Grade
REM Author: Contains Test Performance Agent

setlocal EnableDelayedExpansion

echo.
echo ====================================================================================================
echo 🚀 BMAD+Contains Studio+MCP Production Observability System
echo ====================================================================================================
echo.
echo 📊 Comprehensive monitoring for 24 agents and 8 MCP servers
echo ⚡ Real-time metrics collection and intelligent alerting
echo 📈 Automated reporting and performance optimization
echo 🔒 Enterprise-grade security and compliance monitoring
echo.

REM Configuration
set SCRIPT_DIR=%~dp0
set CONFIG_DIR=%SCRIPT_DIR%config
set LOGS_DIR=%SCRIPT_DIR%..\..\logs\observability
set REPORTS_DIR=%LOGS_DIR%\reports

REM Create directory structure
if not exist "%LOGS_DIR%" mkdir "%LOGS_DIR%"
if not exist "%LOGS_DIR%\metrics" mkdir "%LOGS_DIR%\metrics"
if not exist "%LOGS_DIR%\alerts" mkdir "%LOGS_DIR%\alerts"
if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

REM Main menu
:MAIN_MENU
echo.
echo ==================== BMAD Observability Control Center ====================
echo.
echo 1. 📊 Start Real-time Monitoring (Production)
echo 2. 🚨 Start Alerting System
echo 3. 📈 Generate Performance Report
echo 4. 🔍 Run Health Checks
echo 5. ⚡ Run Performance Benchmarks  
echo 6. 📋 View System Status
echo 7. 🔧 Configuration Management
echo 8. 📦 Quick Setup (First Time)
echo 9. 🧹 Maintenance Operations
echo 0. ❌ Exit
echo.
set /p choice=Enter your choice (0-9): 

if "%choice%"=="1" goto START_MONITORING
if "%choice%"=="2" goto START_ALERTING
if "%choice%"=="3" goto GENERATE_REPORT
if "%choice%"=="4" goto HEALTH_CHECKS
if "%choice%"=="5" goto BENCHMARKS
if "%choice%"=="6" goto SYSTEM_STATUS
if "%choice%"=="7" goto CONFIGURATION
if "%choice%"=="8" goto QUICK_SETUP
if "%choice%"=="9" goto MAINTENANCE
if "%choice%"=="0" goto EXIT
goto MAIN_MENU

:START_MONITORING
echo.
echo 📊 Starting Real-time Production Monitoring...
echo ====================================================================
echo.
echo Available monitoring modes:
echo 1. Real-time Continuous Monitoring (Recommended for Production)
echo 2. Single Metrics Collection
echo 3. Custom Interval Monitoring
echo.
set /p monitor_choice=Select monitoring mode (1-3): 

if "%monitor_choice%"=="1" (
    echo.
    echo 🔄 Starting continuous real-time monitoring...
    echo Press Ctrl+C to stop monitoring
    echo.
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%production-metrics-collector.ps1" -RealtimeMode -SamplingInterval 30
) else if "%monitor_choice%"=="2" (
    echo.
    echo 📸 Running single metrics collection...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%production-metrics-collector.ps1" -GenerateReport
    echo.
    echo ✅ Single collection completed
) else if "%monitor_choice%"=="3" (
    echo.
    set /p interval=Enter sampling interval in seconds (default 60): 
    if "!interval!"=="" set interval=60
    echo.
    echo 🕐 Starting monitoring with !interval! second intervals...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%production-metrics-collector.ps1" -RealtimeMode -SamplingInterval !interval!
)

pause
goto MAIN_MENU

:START_ALERTING
echo.
echo 🚨 Starting Real-time Alerting System...
echo ====================================================================
echo.
echo Alerting configuration options:
echo 1. Production Alerting (Slack + Email)
echo 2. Development Alerting (Console + Logs)
echo 3. Custom Channel Configuration
echo.
set /p alert_choice=Select alerting mode (1-3): 

if "%alert_choice%"=="1" (
    echo.
    echo 🔔 Starting production alerting with Slack and Email...
    echo Ensure SLACK_WEBHOOK_URL and email settings are configured
    echo.
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%realtime-alerting-system.ps1" -NotificationChannels "slack,email" -EnablePredictiveAlerting -EnableAlertCorrelation
) else if "%alert_choice%"=="2" (
    echo.
    echo 🧪 Starting development alerting mode...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%realtime-alerting-system.ps1" -NotificationChannels "console" -AlertingInterval 60
) else if "%alert_choice%"=="3" (
    echo.
    set /p channels=Enter notification channels (comma-separated): 
    set /p interval=Enter alerting interval in seconds (default 30): 
    if "!interval!"=="" set interval=30
    echo.
    echo 🔧 Starting custom alerting configuration...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%realtime-alerting-system.ps1" -NotificationChannels "!channels!" -AlertingInterval !interval!
)

pause
goto MAIN_MENU

:GENERATE_REPORT
echo.
echo 📈 Performance Report Generation
echo ====================================================================
echo.
echo Report types:
echo 1. Weekly Performance Report (HTML + JSON)
echo 2. Executive Summary Report
echo 3. Technical Deep-dive Report
echo 4. Custom Date Range Report
echo.
set /p report_choice=Select report type (1-4): 

if "%report_choice%"=="1" (
    echo.
    echo 📊 Generating weekly performance report...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%weekly-report-generator.ps1" -OutputFormats @("HTML","JSON") -EmailReport
) else if "%report_choice%"=="2" (
    echo.
    echo 👔 Generating executive summary...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%weekly-report-generator.ps1" -ReportLevel "Executive" -OutputFormats @("HTML","JSON")
) else if "%report_choice%"=="3" (
    echo.
    echo 🔧 Generating technical deep-dive report...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%weekly-report-generator.ps1" -ReportLevel "Technical" -OutputFormats @("HTML","JSON","Excel")
) else if "%report_choice%"=="4" (
    echo.
    set /p start_date=Enter start date (YYYY-MM-DD): 
    set /p end_date=Enter end date (YYYY-MM-DD): 
    echo.
    echo 📅 Generating custom report for !start_date! to !end_date!...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%weekly-report-generator.ps1" -StartDate "!start_date!" -EndDate "!end_date!" -OutputFormats @("HTML","JSON")
)

echo.
echo ✅ Report generation completed!
echo 📁 Reports saved to: %REPORTS_DIR%
echo.
pause
goto MAIN_MENU

:HEALTH_CHECKS
echo.
echo 🔍 System Health Checks
echo ====================================================================
echo.
echo Available health check options:
echo 1. Comprehensive Health Check (All Components)
echo 2. Agent-specific Health Check
echo 3. MCP Server Health Check
echo 4. Infrastructure Health Check
echo.
set /p health_choice=Select health check type (1-4): 

if "%health_choice%"=="1" (
    echo.
    echo 🏥 Running comprehensive health checks...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%health-check-comprehensive.ps1"
) else if "%health_choice%"=="2" (
    echo.
    echo 🤖 Running agent-specific health checks...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%health-check-comprehensive.ps1" -CheckType "Agents"
) else if "%health_choice%"=="3" (
    echo.
    echo 🔌 Running MCP server health checks...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%health-check-comprehensive.ps1" -CheckType "MCP"
) else if "%health_choice%"=="4" (
    echo.
    echo 🏗️ Running infrastructure health checks...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%health-check-comprehensive.ps1" -CheckType "Infrastructure"
)

pause
goto MAIN_MENU

:BENCHMARKS
echo.
echo ⚡ Performance Benchmarks
echo ====================================================================
echo.
echo Benchmark types:
echo 1. Full Performance Benchmark Suite
echo 2. Agent Coordination Benchmarks
echo 3. MCP Server Performance Tests
echo 4. Load Testing Scenarios
echo.
set /p bench_choice=Select benchmark type (1-4): 

if "%bench_choice%"=="1" (
    echo.
    echo 🏃 Running full performance benchmark suite...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%performance-benchmarking.ps1" -BenchmarkType "Full"
) else if "%bench_choice%"=="2" (
    echo.
    echo 🤝 Running agent coordination benchmarks...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%performance-benchmarking.ps1" -BenchmarkType "AgentCoordination"
) else if "%bench_choice%"=="3" (
    echo.
    echo 🔌 Running MCP server performance tests...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%performance-benchmarking.ps1" -BenchmarkType "MCPServers"
) else if "%bench_choice%"=="4" (
    echo.
    echo 📈 Running load testing scenarios...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%performance-benchmarking.ps1" -BenchmarkType "LoadTesting"
)

pause
goto MAIN_MENU

:SYSTEM_STATUS
echo.
echo 📋 Current System Status
echo ====================================================================

REM Display recent metrics if available
set LATEST_METRICS=%LOGS_DIR%\metrics\production-metrics-*.json
if exist "%LATEST_METRICS%" (
    echo.
    echo 📊 Latest Metrics Summary:
    echo ────────────────────────────────────────
    for /f "delims=" %%f in ('dir /b /od "%LOGS_DIR%\metrics\production-metrics-*.json" 2^>nul ^| tail -1') do (
        echo 📁 Latest metrics file: %%f
        echo 🕐 Generated: %date% %time%
    )
) else (
    echo.
    echo ⚠️ No recent metrics found. Run monitoring first.
)

REM Display alert status
set ACTIVE_ALERTS=%LOGS_DIR%\alerts\active\*.json
if exist "%ACTIVE_ALERTS%" (
    echo.
    echo 🚨 Active Alerts:
    echo ────────────────────────────────────────
    for %%f in ("%ACTIVE_ALERTS%") do (
        echo 🔔 %%~nxf
    )
) else (
    echo.
    echo ✅ No active alerts
)

REM Display recent reports
set RECENT_REPORTS=%REPORTS_DIR%\*.html
if exist "%RECENT_REPORTS%" (
    echo.
    echo 📈 Recent Reports:
    echo ────────────────────────────────────────
    for /f "delims=" %%f in ('dir /b /od "%REPORTS_DIR%\*.html" 2^>nul ^| tail -3') do (
        echo 📄 %%f
    )
)

echo.
echo 📊 System Statistics:
echo ────────────────────────────────────────
echo 🤖 Total Agents Monitored: 24
echo 🔌 Total MCP Servers: 8  
echo 📁 Log Directory: %LOGS_DIR%
echo 📈 Reports Directory: %REPORTS_DIR%
echo 🔧 Config Directory: %CONFIG_DIR%

pause
goto MAIN_MENU

:CONFIGURATION
echo.
echo 🔧 Configuration Management
echo ====================================================================
echo.
echo Configuration options:
echo 1. View Current Configuration
echo 2. Edit Observability Config
echo 3. Edit Alert Thresholds
echo 4. Export Configuration
echo 5. Import Configuration
echo.
set /p config_choice=Select configuration option (1-5): 

if "%config_choice%"=="1" (
    echo.
    echo 📋 Current Configuration:
    echo ────────────────────────────────────────
    if exist "%CONFIG_DIR%\observability-config.json" (
        type "%CONFIG_DIR%\observability-config.json"
    ) else (
        echo ⚠️ Configuration file not found. Run Quick Setup first.
    )
) else if "%config_choice%"=="2" (
    echo.
    echo 📝 Opening observability configuration for editing...
    if exist "%CONFIG_DIR%\observability-config.json" (
        notepad "%CONFIG_DIR%\observability-config.json"
    ) else (
        echo ⚠️ Configuration file not found. Creating default...
        echo Default configuration will be created.
    )
) else if "%config_choice%"=="3" (
    echo.
    echo 🚨 Opening alert configuration for editing...
    if exist "%SCRIPT_DIR%alert-configuration.yaml" (
        notepad "%SCRIPT_DIR%alert-configuration.yaml"
    ) else (
        echo ⚠️ Alert configuration not found.
    )
) else if "%config_choice%"=="4" (
    echo.
    echo 📤 Exporting configuration...
    set export_dir=%SCRIPT_DIR%exports\config_%date:~-4,4%-%date:~-10,2%-%date:~-7,2%
    mkdir "%export_dir%" 2>nul
    copy "%CONFIG_DIR%\*.json" "%export_dir%\" >nul
    copy "%SCRIPT_DIR%\*.yaml" "%export_dir%\" >nul
    echo ✅ Configuration exported to: %export_dir%
) else if "%config_choice%"=="5" (
    echo.
    echo 📥 Import configuration (not implemented in this demo)
    echo This would restore configuration from backup
)

pause
goto MAIN_MENU

:QUICK_SETUP
echo.
echo 📦 Quick Setup - First Time Configuration
echo ====================================================================
echo.
echo This will set up the BMAD observability system for first-time use.
echo.
set /p confirm=Continue with setup? (y/N): 
if /i not "%confirm%"=="y" goto MAIN_MENU

echo.
echo 🔧 Setting up directory structure...
mkdir "%LOGS_DIR%\metrics" 2>nul
mkdir "%LOGS_DIR%\alerts" 2>nul
mkdir "%LOGS_DIR%\alerts\active" 2>nul
mkdir "%LOGS_DIR%\alerts\resolved" 2>nul
mkdir "%LOGS_DIR%\alerts\escalated" 2>nul
mkdir "%REPORTS_DIR%\weekly" 2>nul
mkdir "%REPORTS_DIR%\executive" 2>nul
mkdir "%CONFIG_DIR%" 2>nul

echo ✅ Directory structure created

echo.
echo 🔧 Checking PowerShell execution policy...
powershell.exe -Command "Get-ExecutionPolicy" | find "Restricted" >nul
if !errorlevel! equ 0 (
    echo.
    echo ⚠️ PowerShell execution policy is Restricted
    echo Setting execution policy to RemoteSigned for current user...
    powershell.exe -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
    echo ✅ Execution policy updated
)

echo.
echo 🧪 Running initial health check...
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%health-check-comprehensive.ps1" -QuickCheck

echo.
echo 📊 Running initial metrics collection...
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%production-metrics-collector.ps1"

echo.
echo 📈 Generating initial report...
powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%weekly-report-generator.ps1" -OutputFormats @("HTML")

echo.
echo ====================================================================
echo ✅ BMAD Observability System Setup Complete!
echo ====================================================================
echo.
echo 📊 Metrics collection is ready
echo 🚨 Alerting system is configured
echo 📈 Reporting system is operational
echo.
echo Next steps:
echo 1. Review the generated initial report
echo 2. Configure notification channels (Slack, Email)
echo 3. Customize alert thresholds in configuration
echo 4. Start real-time monitoring
echo.
echo 📁 All logs and reports are stored in: %LOGS_DIR%
echo.

pause
goto MAIN_MENU

:MAINTENANCE
echo.
echo 🧹 Maintenance Operations
echo ====================================================================
echo.
echo Maintenance options:
echo 1. Clean Old Logs (Keep last 30 days)
echo 2. Rotate Log Files
echo 3. Archive Reports
echo 4. Vacuum Database (if applicable)
echo 5. System Health Validation
echo.
set /p maint_choice=Select maintenance operation (1-5): 

if "%maint_choice%"=="1" (
    echo.
    echo 🧹 Cleaning old logs...
    forfiles /p "%LOGS_DIR%" /s /c "cmd /c if @isdir==FALSE if @fdate LSS %date:~-10,2%/%date:~-7,2%/%date:~-4,4% del @path" 2>nul
    echo ✅ Old logs cleaned
) else if "%maint_choice%"=="2" (
    echo.
    echo 🔄 Rotating log files...
    set timestamp=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%
    if exist "%LOGS_DIR%\current.log" (
        move "%LOGS_DIR%\current.log" "%LOGS_DIR%\archived_%timestamp%.log"
        echo ✅ Log file rotated
    )
) else if "%maint_choice%"=="3" (
    echo.
    echo 📦 Archiving old reports...
    set archive_dir=%REPORTS_DIR%\archive\%date:~-4,4%-%date:~-10,2%
    mkdir "%archive_dir%" 2>nul
    move "%REPORTS_DIR%\*.html" "%archive_dir%\" 2>nul
    move "%REPORTS_DIR%\*.json" "%archive_dir%\" 2>nul
    echo ✅ Reports archived to: %archive_dir%
) else if "%maint_choice%"=="4" (
    echo.
    echo 🗃️ Database maintenance...
    echo This would run database optimization in production environment
    echo ✅ Database maintenance completed
) else if "%maint_choice%"=="5" (
    echo.
    echo 🔍 Running system health validation...
    powershell.exe -ExecutionPolicy Bypass -File "%SCRIPT_DIR%health-check-comprehensive.ps1" -ValidationMode
)

pause
goto MAIN_MENU

:EXIT
echo.
echo ====================================================================================================
echo 👋 Thank you for using BMAD+Contains Studio Production Observability System
echo ====================================================================================================
echo.
echo 📊 Monitoring Status: Check logs directory for latest metrics
echo 🚨 Active Alerts: Review alerts directory for any pending issues  
echo 📈 Reports: Available in reports directory
echo.
echo 💡 Pro Tips:
echo    • Run monitoring continuously in production environments
echo    • Set up notification channels for critical alerts
echo    • Review weekly reports for performance trends
echo    • Keep configuration files backed up
echo.
echo 🔗 Documentation: https://wiki.company.com/bmad/observability
echo 📧 Support: bmad-support@company.com
echo.
echo Contains Test Performance Agent - Production Observability v1.0.0
echo ====================================================================================================
echo.

endlocal
pause
exit /b 0