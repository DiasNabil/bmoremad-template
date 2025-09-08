@echo off
REM MCP Optimization Validator - Windows Batch Script
REM Validates all enhanced MCP server optimizations

echo.
echo ========================================
echo 🚀 MCP OPTIMIZATION VALIDATOR
echo ========================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ Python not found! Please install Python 3.8+ 
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "project.mcp.json" (
    echo ❌ project.mcp.json not found!
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Run the validation
echo 🔍 Running MCP optimization validation...
echo.

python scripts\mcp-optimization-validator.py

if %ERRORLEVEL% equ 0 (
    echo.
    echo ✅ VALIDATION SUCCESSFUL!
    echo 🎉 All MCP optimizations are working correctly
    echo.
) else (
    echo.
    echo ❌ VALIDATION FAILED!
    echo ⚠️  Some optimizations need attention
    echo.
    echo 💡 Check the detailed report above for specific issues
    echo.
)

echo Press any key to continue...
pause >nul