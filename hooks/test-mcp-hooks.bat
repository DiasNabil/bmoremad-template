@echo off
REM Test script pour valider les hooks MCP

echo ========================================
echo Testing MCP Hooks Integration
echo ========================================

set "BASE_DIR=C:\Users\NABIL\Desktop\projet perso\projets\bmoremad-template"

echo.
echo 1. Testing mcp-coordination-validator.bat...
call "%BASE_DIR%\hooks\mcp-coordination-validator.bat"
if !errorlevel! neq 0 (
    echo   ERROR: Coordination validator failed
    exit /b 1
) else (
    echo   SUCCESS: Coordination validator executed
)

echo.
echo 2. Testing mcp-performance-monitor.bat...
call "%BASE_DIR%\hooks\mcp-performance-monitor.bat"
if !errorlevel! neq 0 (
    echo   ERROR: Performance monitor failed
    exit /b 1
) else (
    echo   SUCCESS: Performance monitor executed
)

echo.
echo 3. Testing agent-resource-allocator.bat...
call "%BASE_DIR%\hooks\agent-resource-allocator.bat"
if !errorlevel! neq 0 (
    echo   ERROR: Resource allocator failed
    exit /b 1
) else (
    echo   SUCCESS: Resource allocator executed
)

echo.
echo 4. Checking audit logs...
if exist "%BASE_DIR%\logs\audit\mcp-coordination.log" (
    echo   SUCCESS: Coordination log created
) else (
    echo   WARNING: Coordination log not found
)

if exist "%BASE_DIR%\logs\audit\mcp-performance.log" (
    echo   SUCCESS: Performance log created
) else (
    echo   WARNING: Performance log not found
)

if exist "%BASE_DIR%\logs\audit\resource-allocation.log" (
    echo   SUCCESS: Resource allocation log created
) else (
    echo   WARNING: Resource allocation log not found
)

echo.
echo ========================================
echo MCP Hooks Integration Test Complete
echo ========================================

exit /b 0