@echo off
REM =====================================================
REM BMAD+Contains Studio Performance Monitor Hook
REM Monitors system performance after tool usage
REM Compliant with Anthropic Claude Code standards
REM =====================================================

setlocal EnableDelayedExpansion

REM Configuration
set "PERFORMANCE_LOG=%CLAUDE_PROJECT_DIR%\logs\audit\performance-monitor.log"
set "METRICS_FILE=%CLAUDE_PROJECT_DIR%\logs\audit\performance-metrics.json"
set "ALERT_THRESHOLD_CPU=80"
set "ALERT_THRESHOLD_MEMORY=75"
set "TIMESTAMP=%date% %time%"

REM Ensure log directories exist
if not exist "%CLAUDE_PROJECT_DIR%\logs\audit" mkdir "%CLAUDE_PROJECT_DIR%\logs\audit"

REM Get tool execution information
set "TOOL_NAME=%CLAUDE_TOOL_NAME%"
set "EXECUTION_TIME=%CLAUDE_TOOL_EXECUTION_TIME%"
set "TOOL_STATUS=%CLAUDE_TOOL_STATUS%"

REM Initialize performance monitoring
echo [%TIMESTAMP%] Performance monitoring started for %TOOL_NAME% >> "%PERFORMANCE_LOG%"

REM Collect system metrics
call :CollectSystemMetrics
call :CollectProcessMetrics
call :CollectMemoryMetrics
call :CollectDiskMetrics

REM Analyze performance
call :AnalyzePerformance

REM Generate metrics JSON
call :GenerateMetricsJSON

REM Check for performance alerts
call :CheckPerformanceAlerts

echo [%TIMESTAMP%] Performance monitoring completed >> "%PERFORMANCE_LOG%"
exit /b 0

REM =====================================================
REM Function: Collect system metrics
REM =====================================================
:CollectSystemMetrics
echo [%TIMESTAMP%] Collecting system metrics >> "%PERFORMANCE_LOG%"

REM Get CPU usage
for /f "tokens=2 delims==" %%a in ('wmic cpu get loadpercentage /value ^| find "="') do set "CPU_USAGE=%%a"

REM Get system uptime
for /f "tokens=2 delims==" %%a in ('wmic os get lastbootuptime /value ^| find "="') do set "BOOT_TIME=%%a"

REM Get number of processes
for /f %%a in ('tasklist /fo csv ^| find /c /v ""') do set "PROCESS_COUNT=%%a"

REM Get system load (approximation using process count)
set /a "SYSTEM_LOAD=%PROCESS_COUNT%/10"

echo CPU Usage: %CPU_USAGE%% >> "%PERFORMANCE_LOG%"
echo Process Count: %PROCESS_COUNT% >> "%PERFORMANCE_LOG%"
echo System Load: %SYSTEM_LOAD% >> "%PERFORMANCE_LOG%"

exit /b 0

REM =====================================================
REM Function: Collect process metrics
REM =====================================================
:CollectProcessMetrics
echo [%TIMESTAMP%] Collecting process metrics >> "%PERFORMANCE_LOG%"

REM Count Claude processes
for /f %%a in ('tasklist ^| find /c /i "claude"') do set "CLAUDE_PROCESSES=%%a"

REM Count Node.js processes (for MCP servers)
for /f %%a in ('tasklist ^| find /c /i "node"') do set "NODE_PROCESSES=%%a"

REM Count Python processes (potential MCP servers)
for /f %%a in ('tasklist ^| find /c /i "python"') do set "PYTHON_PROCESSES=%%a"

echo Claude Processes: %CLAUDE_PROCESSES% >> "%PERFORMANCE_LOG%"
echo Node Processes: %NODE_PROCESSES% >> "%PERFORMANCE_LOG%"
echo Python Processes: %PYTHON_PROCESSES% >> "%PERFORMANCE_LOG%"

exit /b 0

REM =====================================================
REM Function: Collect memory metrics
REM =====================================================
:CollectMemoryMetrics
echo [%TIMESTAMP%] Collecting memory metrics >> "%PERFORMANCE_LOG%"

REM Get total physical memory
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value ^| find "="') do set "TOTAL_MEMORY=%%a"

REM Get available memory
for /f "tokens=2 delims==" %%a in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set "FREE_MEMORY=%%a"

REM Calculate memory usage percentage
set /a "TOTAL_MEMORY_MB=%TOTAL_MEMORY%/1048576"
set /a "FREE_MEMORY_MB=%FREE_MEMORY%/1024"
set /a "USED_MEMORY_MB=%TOTAL_MEMORY_MB%-%FREE_MEMORY_MB%"
set /a "MEMORY_USAGE_PERCENT=(%USED_MEMORY_MB%*100)/%TOTAL_MEMORY_MB%"

echo Total Memory: %TOTAL_MEMORY_MB%MB >> "%PERFORMANCE_LOG%"
echo Used Memory: %USED_MEMORY_MB%MB >> "%PERFORMANCE_LOG%"
echo Free Memory: %FREE_MEMORY_MB%MB >> "%PERFORMANCE_LOG%"
echo Memory Usage: %MEMORY_USAGE_PERCENT%%% >> "%PERFORMANCE_LOG%"

exit /b 0

REM =====================================================
REM Function: Collect disk metrics
REM =====================================================
:CollectDiskMetrics
echo [%TIMESTAMP%] Collecting disk metrics >> "%PERFORMANCE_LOG%"

REM Get disk space for C: drive
for /f "tokens=3" %%a in ('dir C:\ ^| find "bytes free"') do set "FREE_SPACE=%%a"

REM Log file sizes
if exist "%CLAUDE_PROJECT_DIR%\logs\" (
    for /f "tokens=3" %%a in ('dir "%CLAUDE_PROJECT_DIR%\logs" /s ^| find "File(s)"') do set "LOG_SIZE=%%a"
    echo Log Directory Size: %LOG_SIZE% bytes >> "%PERFORMANCE_LOG%"
)

echo Disk Free Space: %FREE_SPACE% >> "%PERFORMANCE_LOG%"

exit /b 0

REM =====================================================
REM Function: Analyze performance
REM =====================================================
:AnalyzePerformance
echo [%TIMESTAMP%] Analyzing performance data >> "%PERFORMANCE_LOG%"

REM Calculate performance score (0-100)
set /a "PERFORMANCE_SCORE=100-%CPU_USAGE%/2-%MEMORY_USAGE_PERCENT%/2"
if %PERFORMANCE_SCORE% lss 0 set "PERFORMANCE_SCORE=0"

REM Determine performance grade
set "PERFORMANCE_GRADE=F"
if %PERFORMANCE_SCORE% geq 90 set "PERFORMANCE_GRADE=A"
if %PERFORMANCE_SCORE% geq 80 if %PERFORMANCE_SCORE% lss 90 set "PERFORMANCE_GRADE=B"
if %PERFORMANCE_SCORE% geq 70 if %PERFORMANCE_SCORE% lss 80 set "PERFORMANCE_GRADE=C"
if %PERFORMANCE_SCORE% geq 60 if %PERFORMANCE_SCORE% lss 70 set "PERFORMANCE_GRADE=D"

echo Performance Score: %PERFORMANCE_SCORE%/100 >> "%PERFORMANCE_LOG%"
echo Performance Grade: %PERFORMANCE_GRADE% >> "%PERFORMANCE_LOG%"

REM Check for resource contention
if %CLAUDE_PROCESSES% gtr 5 (
    echo WARNING: Multiple Claude processes detected >> "%PERFORMANCE_LOG%"
)

if %NODE_PROCESSES% gtr 8 (
    echo WARNING: High number of Node.js processes >> "%PERFORMANCE_LOG%"
)

exit /b 0

REM =====================================================
REM Function: Generate metrics JSON
REM =====================================================
:GenerateMetricsJSON
echo Generating performance metrics JSON >> "%PERFORMANCE_LOG%"

REM Create JSON file with current metrics
(
echo {
echo   "timestamp": "%TIMESTAMP%",
echo   "tool_name": "%TOOL_NAME%",
echo   "system_metrics": {
echo     "cpu_usage_percent": %CPU_USAGE%,
echo     "memory_usage_percent": %MEMORY_USAGE_PERCENT%,
echo     "total_memory_mb": %TOTAL_MEMORY_MB%,
echo     "free_memory_mb": %FREE_MEMORY_MB%,
echo     "process_count": %PROCESS_COUNT%
echo   },
echo   "process_metrics": {
echo     "claude_processes": %CLAUDE_PROCESSES%,
echo     "node_processes": %NODE_PROCESSES%,
echo     "python_processes": %PYTHON_PROCESSES%
echo   },
echo   "performance_analysis": {
echo     "score": %PERFORMANCE_SCORE%,
echo     "grade": "%PERFORMANCE_GRADE%",
echo     "execution_time_ms": "%EXECUTION_TIME%",
echo     "tool_status": "%TOOL_STATUS%"
echo   }
echo }
) > "%METRICS_FILE%"

exit /b 0

REM =====================================================
REM Function: Check performance alerts
REM =====================================================
:CheckPerformanceAlerts
echo [%TIMESTAMP%] Checking performance alerts >> "%PERFORMANCE_LOG%"

set "ALERTS_TRIGGERED=false"

REM CPU usage alert
if %CPU_USAGE% geq %ALERT_THRESHOLD_CPU% (
    echo ALERT: High CPU usage detected: %CPU_USAGE%%% >> "%PERFORMANCE_LOG%"
    echo Performance Alert: High CPU usage (%CPU_USAGE%%%)
    set "ALERTS_TRIGGERED=true"
)

REM Memory usage alert  
if %MEMORY_USAGE_PERCENT% geq %ALERT_THRESHOLD_MEMORY% (
    echo ALERT: High memory usage detected: %MEMORY_USAGE_PERCENT%%% >> "%PERFORMANCE_LOG%"
    echo Performance Alert: High memory usage (%MEMORY_USAGE_PERCENT%%%)
    set "ALERTS_TRIGGERED=true"
)

REM Process count alert
if %CLAUDE_PROCESSES% geq 5 (
    echo ALERT: Too many Claude processes: %CLAUDE_PROCESSES% >> "%PERFORMANCE_LOG%"
    echo Performance Alert: Multiple Claude processes (%CLAUDE_PROCESSES%)
    set "ALERTS_TRIGGERED=true"
)

REM Performance grade alert
if "%PERFORMANCE_GRADE%"=="D" (
    echo ALERT: Poor performance grade: %PERFORMANCE_GRADE% >> "%PERFORMANCE_LOG%"
    echo Performance Alert: Poor system performance (Grade %PERFORMANCE_GRADE%)
    set "ALERTS_TRIGGERED=true"
)

if "%PERFORMANCE_GRADE%"=="F" (
    echo CRITICAL: Critical performance issues: %PERFORMANCE_GRADE% >> "%PERFORMANCE_LOG%"
    echo Critical Alert: System performance critical (Grade %PERFORMANCE_GRADE%)
    set "ALERTS_TRIGGERED=true"
)

if "%ALERTS_TRIGGERED%"=="false" (
    echo [%TIMESTAMP%] No performance alerts triggered >> "%PERFORMANCE_LOG%"
)

REM Cleanup old metrics files (keep last 10)
call :CleanupOldMetrics

exit /b 0

REM =====================================================
REM Function: Cleanup old metrics
REM =====================================================
:CleanupOldMetrics
set "METRICS_DIR=%CLAUDE_PROJECT_DIR%\logs\audit"

REM Count metrics files
set "FILE_COUNT=0"
for %%f in ("%METRICS_DIR%\performance-metrics-*.json") do set /a "FILE_COUNT+=1"

if %FILE_COUNT% gtr 10 (
    echo [%TIMESTAMP%] Cleaning up old performance metrics files >> "%PERFORMANCE_LOG%"
    REM Delete oldest files (simplified - could be improved with date sorting)
    forfiles /p "%METRICS_DIR%" /m "performance-metrics-*.json" /d -7 /c "cmd /c del @path" 2>nul
)

exit /b 0

REM =====================================================
REM End of script
REM =====================================================