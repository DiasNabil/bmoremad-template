@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM MCP Connectivity Test Script - Production Ready
REM Tests connectivity for critical MCP servers: GitHub, Redis, PostgreSQL, Firecrawl
REM Compatible with bmad-parallel-orchestrator coordination
REM ============================================================================

set "SCRIPT_NAME=MCP-Connectivity-Test"
set "LOG_FILE=logs\mcp-validation\connectivity-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "RETRY_COUNT=3"
set "TIMEOUT_SECONDS=30"
set "CRITICAL_SERVERS=github,firecrawl"
set "HIGH_PRIORITY_SERVERS=postgres,redis"

REM Create log directory
if not exist "logs\mcp-validation" mkdir "logs\mcp-validation"

echo [%time%] %SCRIPT_NAME% - Starting MCP connectivity validation >> %LOG_FILE%
echo.
echo ============================================================================
echo  MCP CONNECTIVITY VALIDATION - BMAD TEMPLATE
echo ============================================================================
echo.

REM Initialize results
set "TEST_RESULTS="
set "CRITICAL_FAILURES=0"
set "HIGH_PRIORITY_FAILURES=0"
set "TOTAL_TESTS=0"
set "PASSED_TESTS=0"

REM ============================================================================
REM FUNCTION: Test Service Connection
REM ============================================================================
:test_connection
set "service=%~1"
set "priority=%~2"
set "host=%~3"
set "port=%~4"
set "test_command=%~5"

echo [%time%] Testing %service% connectivity (%priority% priority)...
echo [%time%] Testing %service% connectivity (%priority% priority)... >> %LOG_FILE%

set /a TOTAL_TESTS+=1
set "connection_success=false"

for /l %%i in (1,1,%RETRY_COUNT%) do (
    if "!connection_success!"=="false" (
        echo   Attempt %%i/%RETRY_COUNT%...
        
        REM Test based on service type
        if /i "%service%"=="github" (
            call :test_github_connection
        ) else if /i "%service%"=="redis" (
            call :test_redis_connection
        ) else if /i "%service%"=="postgres" (
            call :test_postgres_connection  
        ) else if /i "%service%"=="firecrawl" (
            call :test_firecrawl_connection
        )
        
        if "!connection_success!"=="true" (
            echo   ✓ %service% connection successful
            echo [%time%] SUCCESS: %service% connection established >> %LOG_FILE%
            set /a PASSED_TESTS+=1
            goto :test_connection_end
        ) else (
            echo   ✗ %service% connection failed, retrying in 5 seconds...
            timeout /t 5 /nobreak >nul 2>&1
        )
    )
)

REM If we reach here, all retries failed
echo   ✗ %service% connection FAILED after %RETRY_COUNT% attempts
echo [%time%] FAILURE: %service% connection failed after %RETRY_COUNT% attempts >> %LOG_FILE%

if /i "%priority%"=="Critical" (
    set /a CRITICAL_FAILURES+=1
) else if /i "%priority%"=="High" (
    set /a HIGH_PRIORITY_FAILURES+=1
)

:test_connection_end
echo.
goto :eof

REM ============================================================================
REM GitHub API Connection Test
REM ============================================================================
:test_github_connection
echo     Testing GitHub API accessibility...
powershell -Command "try { $response = Invoke-RestMethod -Uri 'https://api.github.com/rate_limit' -TimeoutSec %TIMEOUT_SECONDS% -ErrorAction Stop; if ($response.rate.limit -gt 0) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 (
    set "connection_success=true"
    echo     ✓ GitHub API accessible
) else (
    echo     ✗ GitHub API not accessible
)
goto :eof

REM ============================================================================
REM Redis Connection Test  
REM ============================================================================
:test_redis_connection
echo     Testing Redis server connection...
powershell -Command "try { $tcpClient = New-Object System.Net.Sockets.TcpClient; $tcpClient.ReceiveTimeout = %TIMEOUT_SECONDS%000; $tcpClient.SendTimeout = %TIMEOUT_SECONDS%000; $tcpClient.Connect('localhost', 6379); $tcpClient.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 (
    set "connection_success=true"
    echo     ✓ Redis server accessible on localhost:6379
) else (
    echo     ✗ Redis server not accessible on localhost:6379
)
goto :eof

REM ============================================================================
REM PostgreSQL Connection Test
REM ============================================================================
:test_postgres_connection
echo     Testing PostgreSQL database connection...
powershell -Command "try { $tcpClient = New-Object System.Net.Sockets.TcpClient; $tcpClient.ReceiveTimeout = %TIMEOUT_SECONDS%000; $tcpClient.SendTimeout = %TIMEOUT_SECONDS%000; $tcpClient.Connect('localhost', 5432); $tcpClient.Close(); exit 0 } catch { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 (
    set "connection_success=true"
    echo     ✓ PostgreSQL server accessible on localhost:5432
) else (
    echo     ✗ PostgreSQL server not accessible on localhost:5432
)
goto :eof

REM ============================================================================
REM Firecrawl API Connection Test
REM ============================================================================
:test_firecrawl_connection
echo     Testing Firecrawl API accessibility...
powershell -Command "try { $response = Invoke-WebRequest -Uri 'https://api.firecrawl.dev/health' -TimeoutSec %TIMEOUT_SECONDS% -ErrorAction Stop; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
if !errorlevel! equ 0 (
    set "connection_success=true"
    echo     ✓ Firecrawl API accessible
) else (
    echo     ✗ Firecrawl API not accessible
)
goto :eof

REM ============================================================================
REM MAIN EXECUTION
REM ============================================================================

echo Starting connectivity tests for MCP servers...
echo.

REM Test Critical Priority Servers
echo === CRITICAL PRIORITY SERVERS ===
call :test_connection "github" "Critical" "api.github.com" "443" ""
call :test_connection "firecrawl" "Critical" "api.firecrawl.dev" "443" ""

echo === HIGH PRIORITY SERVERS ===  
call :test_connection "postgres" "High" "localhost" "5432" ""
call :test_connection "redis" "High" "localhost" "6379" ""

REM ============================================================================
REM RESULTS SUMMARY
REM ============================================================================
echo.
echo ============================================================================
echo  CONNECTIVITY TEST RESULTS SUMMARY
echo ============================================================================
echo.
echo Tests Passed: %PASSED_TESTS%/%TOTAL_TESTS%
echo Critical Failures: %CRITICAL_FAILURES%
echo High Priority Failures: %HIGH_PRIORITY_FAILURES%
echo.

REM Write summary to log
echo [%time%] SUMMARY: Tests Passed: %PASSED_TESTS%/%TOTAL_TESTS% >> %LOG_FILE%
echo [%time%] SUMMARY: Critical Failures: %CRITICAL_FAILURES% >> %LOG_FILE%
echo [%time%] SUMMARY: High Priority Failures: %HIGH_PRIORITY_FAILURES% >> %LOG_FILE%

REM Determine exit status
if %CRITICAL_FAILURES% gtr 0 (
    echo STATUS: CRITICAL FAILURE - Cannot proceed with MCP initialization
    echo [%time%] STATUS: CRITICAL FAILURE - Cannot proceed with MCP initialization >> %LOG_FILE%
    exit /b 2
) else if %HIGH_PRIORITY_FAILURES% gtr 0 (
    echo STATUS: WARNING - Some high-priority services unavailable
    echo [%time%] STATUS: WARNING - Some high-priority services unavailable >> %LOG_FILE%
    exit /b 1
) else (
    echo STATUS: SUCCESS - All connectivity tests passed
    echo [%time%] STATUS: SUCCESS - All connectivity tests passed >> %LOG_FILE%
    exit /b 0
)