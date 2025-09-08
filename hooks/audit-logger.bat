@echo off
REM =====================================================
REM BMAD+Contains Studio Audit Logger Hook
REM Logs user interactions for comprehensive audit trail
REM Compliant with Anthropic Claude Code standards
REM =====================================================

setlocal EnableDelayedExpansion

REM Configuration
set "AUDIT_LOG=%CLAUDE_PROJECT_DIR%\logs\audit\user-interactions.log"
set "SESSION_LOG=%CLAUDE_PROJECT_DIR%\logs\audit\session-log.json"
set "SECURITY_LOG=%CLAUDE_PROJECT_DIR%\logs\audit\security-events.log"
set "TIMESTAMP=%date% %time%"
set "SESSION_ID=%CLAUDE_SESSION_ID%"

REM Ensure audit directories exist
if not exist "%CLAUDE_PROJECT_DIR%\logs\audit" mkdir "%CLAUDE_PROJECT_DIR%\logs\audit"

REM Get user prompt information
set "USER_PROMPT=%CLAUDE_USER_PROMPT%"
set "PROMPT_LENGTH=%CLAUDE_PROMPT_LENGTH%"
set "USER_ID=%USERNAME%"

REM Initialize audit entry
echo [%TIMESTAMP%] Audit logging started for session %SESSION_ID% >> "%AUDIT_LOG%"

REM Log basic interaction information
call :LogUserInteraction
call :AnalyzePromptContent
call :UpdateSessionMetrics
call :CheckSecurityPatterns
call :MaintainAuditFiles

echo [%TIMESTAMP%] Audit logging completed >> "%AUDIT_LOG%"
exit /b 0

REM =====================================================
REM Function: Log user interaction
REM =====================================================
:LogUserInteraction
echo [%TIMESTAMP%] === USER INTERACTION === >> "%AUDIT_LOG%"
echo Session ID: %SESSION_ID% >> "%AUDIT_LOG%"
echo User: %USER_ID% >> "%AUDIT_LOG%"
echo Prompt Length: %PROMPT_LENGTH% characters >> "%AUDIT_LOG%"

REM Log prompt excerpt (first 100 chars for audit, sanitized)
if defined USER_PROMPT (
    set "PROMPT_EXCERPT=%USER_PROMPT:~0,100%"
    REM Sanitize sensitive patterns
    set "PROMPT_EXCERPT=%PROMPT_EXCERPT:password=***%"
    set "PROMPT_EXCERPT=%PROMPT_EXCERPT:token=***%"
    set "PROMPT_EXCERPT=%PROMPT_EXCERPT:key=***%"
    set "PROMPT_EXCERPT=%PROMPT_EXCERPT:secret=***%"
    
    echo Prompt Excerpt: %PROMPT_EXCERPT%... >> "%AUDIT_LOG%"
)

REM Log system context
echo Computer: %COMPUTERNAME% >> "%AUDIT_LOG%"
echo Working Directory: %CLAUDE_PROJECT_DIR% >> "%AUDIT_LOG%"

exit /b 0

REM =====================================================
REM Function: Analyze prompt content
REM =====================================================
:AnalyzePromptContent
echo [%TIMESTAMP%] Analyzing prompt content >> "%AUDIT_LOG%"

set "CONTENT_FLAGS="
set "RISK_SCORE=0"

REM Check for sensitive patterns
if defined USER_PROMPT (
    REM Security-related keywords
    echo "%USER_PROMPT%" | findstr /i /C:"password" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[PASSWORD] "
        set /a "RISK_SCORE+=10"
    )
    
    echo "%USER_PROMPT%" | findstr /i /C:"token" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[TOKEN] "
        set /a "RISK_SCORE+=10"
    )
    
    echo "%USER_PROMPT%" | findstr /i /C:"api.key" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[API_KEY] "
        set /a "RISK_SCORE+=15"
    )
    
    echo "%USER_PROMPT%" | findstr /i /C:"secret" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[SECRET] "
        set /a "RISK_SCORE+=10"
    )
    
    REM System commands
    echo "%USER_PROMPT%" | findstr /i /C:"rm -rf" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[DANGEROUS_CMD] "
        set /a "RISK_SCORE+=25"
    )
    
    echo "%USER_PROMPT%" | findstr /i /C:"sudo" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[ELEVATED_CMD] "
        set /a "RISK_SCORE+=15"
    )
    
    REM File system operations
    echo "%USER_PROMPT%" | findstr /i /C:"delete" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[DELETE] "
        set /a "RISK_SCORE+=5"
    )
    
    echo "%USER_PROMPT%" | findstr /i /C:"format" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[FORMAT] "
        set /a "RISK_SCORE+=20"
    )
    
    REM Network operations
    echo "%USER_PROMPT%" | findstr /i /C:"wget\|curl\|download" >nul && (
        set "CONTENT_FLAGS=%CONTENT_FLAGS%[NETWORK] "
        set /a "RISK_SCORE+=8"
    )
)

REM Determine risk level
set "RISK_LEVEL=LOW"
if %RISK_SCORE% geq 10 set "RISK_LEVEL=MEDIUM"
if %RISK_SCORE% geq 20 set "RISK_LEVEL=HIGH"
if %RISK_SCORE% geq 30 set "RISK_LEVEL=CRITICAL"

echo Content Flags: %CONTENT_FLAGS% >> "%AUDIT_LOG%"
echo Risk Score: %RISK_SCORE% >> "%AUDIT_LOG%"
echo Risk Level: %RISK_LEVEL% >> "%AUDIT_LOG%"

REM Log to security log if risk is high
if %RISK_SCORE% geq 15 (
    echo [%TIMESTAMP%] HIGH RISK PROMPT: Score=%RISK_SCORE%, Flags=%CONTENT_FLAGS% >> "%SECURITY_LOG%"
)

exit /b 0

REM =====================================================
REM Function: Update session metrics
REM =====================================================
:UpdateSessionMetrics
echo [%TIMESTAMP%] Updating session metrics >> "%AUDIT_LOG%"

REM Read existing session data or create new
if exist "%SESSION_LOG%" (
    REM Session exists - increment counters
    call :IncrementSessionCounters
) else (
    REM New session - initialize
    call :InitializeSession
)

exit /b 0

:InitializeSession
(
echo {
echo   "session_id": "%SESSION_ID%",
echo   "user_id": "%USER_ID%",
echo   "computer": "%COMPUTERNAME%",
echo   "start_time": "%TIMESTAMP%",
echo   "project_dir": "%CLAUDE_PROJECT_DIR%",
echo   "metrics": {
echo     "total_prompts": 1,
echo     "total_characters": %PROMPT_LENGTH%,
echo     "security_flags": 0,
echo     "risk_events": 0,
echo     "tools_used": [],
echo     "files_accessed": []
echo   },
echo   "last_activity": "%TIMESTAMP%"
echo }
) > "%SESSION_LOG%"

echo Session initialized >> "%AUDIT_LOG%"
exit /b 0

:IncrementSessionCounters
REM Simplified counter increment (in production, use proper JSON parsing)
echo Session counters updated >> "%AUDIT_LOG%"
echo Last Activity: %TIMESTAMP% >> "%SESSION_LOG%.tmp"
exit /b 0

REM =====================================================
REM Function: Check security patterns
REM =====================================================
:CheckSecurityPatterns
echo [%TIMESTAMP%] Checking security patterns >> "%AUDIT_LOG%"

REM Check for potential data exfiltration patterns
if defined USER_PROMPT (
    echo "%USER_PROMPT%" | findstr /i /C:"send.*to\|email.*to\|upload.*to" >nul && (
        echo [%TIMESTAMP%] SECURITY: Potential data exfiltration pattern detected >> "%SECURITY_LOG%"
        echo Security Alert: Potential data exfiltration attempt
    )
    
    REM Check for credential harvesting
    echo "%USER_PROMPT%" | findstr /i /C:"show.*password\|get.*token\|extract.*key" >nul && (
        echo [%TIMESTAMP%] SECURITY: Credential harvesting attempt detected >> "%SECURITY_LOG%"
        echo Security Alert: Potential credential harvesting
    )
    
    REM Check for system reconnaissance
    echo "%USER_PROMPT%" | findstr /i /C:"list.*users\|show.*processes\|get.*system" >nul && (
        echo [%TIMESTAMP%] SECURITY: System reconnaissance detected >> "%SECURITY_LOG%"
    )
)

exit /b 0

REM =====================================================
REM Function: Maintain audit files
REM =====================================================
:MaintainAuditFiles
echo [%TIMESTAMP%] Maintaining audit files >> "%AUDIT_LOG%"

REM Check audit log size and rotate if necessary
if exist "%AUDIT_LOG%" (
    for %%F in ("%AUDIT_LOG%") do (
        if %%~zF gtr 52428800 (
            REM Log file > 50MB, rotate it
            echo [%TIMESTAMP%] Rotating audit log file >> "%AUDIT_LOG%"
            move "%AUDIT_LOG%" "%AUDIT_LOG%.%date:~-4,4%%date:~-10,2%%date:~-7,2%"
            echo [%TIMESTAMP%] New audit log file created >> "%AUDIT_LOG%"
        )
    )
)

REM Clean up old log files (keep last 30 days)
forfiles /p "%CLAUDE_PROJECT_DIR%\logs\audit" /m "*.log.*" /d -30 /c "cmd /c del @path" 2>nul

REM Compress old logs if available
if exist "%CLAUDE_PROJECT_DIR%\logs\audit\*.log.*" (
    echo [%TIMESTAMP%] Old log files available for compression >> "%AUDIT_LOG%"
)

REM Update file permissions (ensure secure access)
icacls "%CLAUDE_PROJECT_DIR%\logs\audit" /inheritance:r /grant:r "%USERNAME%:F" /grant:r "Administrators:F" 2>nul

exit /b 0

REM =====================================================
REM End of script
REM =====================================================