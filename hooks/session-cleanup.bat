@echo off
REM =====================================================
REM BMAD+Contains Studio Session Cleanup Hook
REM Cleans up resources and generates session summary
REM Compliant with Anthropic Claude Code standards
REM =====================================================

setlocal EnableDelayedExpansion

REM Configuration
set "AUDIT_LOG=%CLAUDE_PROJECT_DIR%\logs\audit\session-cleanup.log"
set "TEMP_DIR=%CLAUDE_PROJECT_DIR%\logs\temp"
set "TIMESTAMP=%date% %time%"

REM Ensure audit directory exists
if not exist "%CLAUDE_PROJECT_DIR%\logs\audit" mkdir "%CLAUDE_PROJECT_DIR%\logs\audit"

REM Initialize cleanup log
echo [%TIMESTAMP%] Session cleanup started >> "%AUDIT_LOG%"

REM Clean temporary files
if exist "%TEMP_DIR%" (
    echo [%TIMESTAMP%] Cleaning temporary files in %TEMP_DIR% >> "%AUDIT_LOG%"
    del /q "%TEMP_DIR%\*" 2>nul
    echo [%TIMESTAMP%] Temporary files cleaned >> "%AUDIT_LOG%"
)

REM Generate session summary
set "SESSION_SUMMARY=%CLAUDE_PROJECT_DIR%\logs\audit\session-summary-%date:~-4,4%%date:~-7,2%%date:~-10,2%.log"
echo [%TIMESTAMP%] Generating session summary >> "%AUDIT_LOG%"
echo Session ended at %TIMESTAMP% > "%SESSION_SUMMARY%"

REM Log completion
echo [%TIMESTAMP%] Session cleanup completed successfully >> "%AUDIT_LOG%"

exit /b 0