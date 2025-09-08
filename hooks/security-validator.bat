@echo off
REM =====================================================
REM BMAD+Contains Studio Security Validator Hook
REM Validates security constraints before tool execution
REM Compliant with Anthropic Claude Code standards
REM =====================================================

setlocal EnableDelayedExpansion

REM Configuration
set "AUDIT_LOG=%CLAUDE_PROJECT_DIR%\logs\audit\security-validator.log"
set "BLOCKED_COMMANDS_FILE=%CLAUDE_PROJECT_DIR%\.claude\blocked-commands.txt"
set "SECURITY_CONFIG=%CLAUDE_PROJECT_DIR%\.claude\settings-optimized.json"
set "TIMESTAMP=%date% %time%"

REM Ensure audit directory exists
if not exist "%CLAUDE_PROJECT_DIR%\logs\audit" mkdir "%CLAUDE_PROJECT_DIR%\logs\audit"

REM Initialize log entry
echo [%TIMESTAMP%] Security validation started >> "%AUDIT_LOG%"

REM Parse tool information from environment
set "TOOL_NAME=%CLAUDE_TOOL_NAME%"
set "TOOL_ARGS=%CLAUDE_TOOL_ARGS%"
set "FILE_PATH=%CLAUDE_FILE_PATH%"

REM Validate tool name
if "%TOOL_NAME%"=="" (
    echo [%TIMESTAMP%] ERROR: No tool name provided >> "%AUDIT_LOG%"
    echo Security validation failed: No tool specified
    exit /b 1
)

REM Log tool execution attempt
echo [%TIMESTAMP%] Validating tool: %TOOL_NAME% >> "%AUDIT_LOG%"
if not "%FILE_PATH%"=="" echo [%TIMESTAMP%] Target file: %FILE_PATH% >> "%AUDIT_LOG%"

REM Check for blocked commands in tool arguments
if not "%TOOL_ARGS%"=="" (
    call :CheckBlockedCommands "%TOOL_ARGS%"
    if !errorlevel! neq 0 (
        echo [%TIMESTAMP%] BLOCKED: Dangerous command detected in arguments >> "%AUDIT_LOG%"
        echo Security validation failed: Blocked command detected
        exit /b 1
    )
)

REM Validate file path if provided
if not "%FILE_PATH%"=="" (
    call :ValidateFilePath "%FILE_PATH%"
    if !errorlevel! neq 0 (
        echo [%TIMESTAMP%] BLOCKED: Invalid file path >> "%AUDIT_LOG%"
        echo Security validation failed: Invalid file path
        exit /b 1
    )
)

REM Tool-specific validations
call :ValidateToolSpecific "%TOOL_NAME%" "%TOOL_ARGS%"
if !errorlevel! neq 0 (
    echo [%TIMESTAMP%] BLOCKED: Tool-specific validation failed >> "%AUDIT_LOG%"
    echo Security validation failed: Tool validation failed
    exit /b 1
)

REM Check system resource availability
call :CheckSystemResources
if !errorlevel! neq 0 (
    echo [%TIMESTAMP%] WARNING: High system resource usage >> "%AUDIT_LOG%"
    echo Security validation warning: High resource usage
)

REM Validation successful
echo [%TIMESTAMP%] Security validation passed for %TOOL_NAME% >> "%AUDIT_LOG%"
echo Security validation successful
exit /b 0

REM =====================================================
REM Function: Check for blocked commands
REM =====================================================
:CheckBlockedCommands
set "ARGS=%~1"

REM List of critical blocked patterns
set "BLOCKED[0]=rm -rf"
set "BLOCKED[1]=sudo "
set "BLOCKED[2]=chmod 777"
set "BLOCKED[3]=mv /"
set "BLOCKED[4]=dd if="
set "BLOCKED[5]=format C:"
set "BLOCKED[6]=> /dev/"
set "BLOCKED[7]=wget "
set "BLOCKED[8]=curl -X POST"
set "BLOCKED[9]=nc -l"
set "BLOCKED[10]=eval "
set "BLOCKED[11]=exec("
set "BLOCKED[12]=powershell -EncodedCommand"
set "BLOCKED[13]=net user"
set "BLOCKED[14]=reg add"
set "BLOCKED[15]=sc create"

for /L %%i in (0,1,15) do (
    if defined BLOCKED[%%i] (
        echo "!ARGS!" | findstr /C:"!BLOCKED[%%i]!" >nul
        if !errorlevel! equ 0 (
            echo [%TIMESTAMP%] BLOCKED COMMAND: !BLOCKED[%%i]! >> "%AUDIT_LOG%"
            exit /b 1
        )
    )
)

exit /b 0

REM =====================================================
REM Function: Validate file path
REM =====================================================
:ValidateFilePath
set "PATH_TO_CHECK=%~1"

REM Remove quotes if present
set "PATH_TO_CHECK=%PATH_TO_CHECK:"=%"

REM Check for blocked directories
echo "%PATH_TO_CHECK%" | findstr /C:".env" >nul && exit /b 1
echo "%PATH_TO_CHECK%" | findstr /C:".git\" >nul && exit /b 1  
echo "%PATH_TO_CHECK%" | findstr /C:"\etc\" >nul && exit /b 1
echo "%PATH_TO_CHECK%" | findstr /C:"\Windows\" >nul && exit /b 1
echo "%PATH_TO_CHECK%" | findstr /C:"Program Files" >nul && exit /b 1
echo "%PATH_TO_CHECK%" | findstr /C:".ssh" >nul && exit /b 1
echo "%PATH_TO_CHECK%" | findstr /C:".aws" >nul && exit /b 1

REM Check for path traversal attempts
echo "%PATH_TO_CHECK%" | findstr /C:".." >nul && exit /b 1
echo "%PATH_TO_CHECK%" | findstr /C:"~/" >nul && exit /b 1

REM Validate allowed directories
set "ALLOWED=false"
set "ALLOWED_DIRS[0]=docs\"
set "ALLOWED_DIRS[1]=.claude\"
set "ALLOWED_DIRS[2]=src\"
set "ALLOWED_DIRS[3]=tests\"
set "ALLOWED_DIRS[4]=logs\"
set "ALLOWED_DIRS[5]=scripts\"
set "ALLOWED_DIRS[6]=hooks\"
set "ALLOWED_DIRS[7]=.bmad-core\"
set "ALLOWED_DIRS[8]=agents-harmonization-pack\"

for /L %%i in (0,1,8) do (
    if defined ALLOWED_DIRS[%%i] (
        echo "%PATH_TO_CHECK%" | findstr /C:"!ALLOWED_DIRS[%%i]!" >nul
        if !errorlevel! equ 0 set "ALLOWED=true"
    )
)

REM Also allow files in project root
if "%PATH_TO_CHECK:~1,1%"==":" set "ALLOWED=true"
if "%PATH_TO_CHECK:~0,1%"=="." set "ALLOWED=true"

if "%ALLOWED%"=="false" (
    echo [%TIMESTAMP%] BLOCKED PATH: %PATH_TO_CHECK% >> "%AUDIT_LOG%"
    exit /b 1
)

exit /b 0

REM =====================================================
REM Function: Tool-specific validation
REM =====================================================
:ValidateToolSpecific
set "TOOL=%~1"
set "ARGS=%~2"

REM Bash tool specific checks
if /i "%TOOL%"=="Bash" (
    echo "%ARGS%" | findstr /C:"rm -rf" >nul && exit /b 1
    echo "%ARGS%" | findstr /C:"sudo" >nul && exit /b 1
    echo "%ARGS%" | findstr /C:"chmod 777" >nul && exit /b 1
)

REM Write tool specific checks  
if /i "%TOOL%"=="Write" (
    REM Check file size limits (simplified check)
    if not "%FILE_PATH%"=="" (
        if exist "%FILE_PATH%" (
            for %%F in ("%FILE_PATH%") do (
                if %%~zF gtr 10485760 (
                    echo [%TIMESTAMP%] BLOCKED: File too large (>10MB) >> "%AUDIT_LOG%"
                    exit /b 1
                )
            )
        )
    )
)

REM Task tool specific checks
if /i "%TOOL%"=="Task" (
    REM Validate subagent type if provided
    echo "%ARGS%" | findstr /C:"subagent_type" >nul
    if !errorlevel! equ 0 (
        echo [%TIMESTAMP%] Task tool with subagent detected >> "%AUDIT_LOG%"
    )
)

exit /b 0

REM =====================================================
REM Function: Check system resources
REM =====================================================
:CheckSystemResources
REM Check CPU usage (simplified)
for /f "tokens=2 delims==" %%a in ('wmic cpu get loadpercentage /value ^| find "="') do set "CPU_USAGE=%%a"

if %CPU_USAGE% gtr 90 (
    echo [%TIMESTAMP%] HIGH CPU USAGE: %CPU_USAGE%% >> "%AUDIT_LOG%"
    exit /b 1
)

REM Check available memory (simplified)
for /f "tokens=2 delims==" %%a in ('wmic OS get FreePhysicalMemory /value ^| find "="') do set "FREE_MEM=%%a"

REM Convert KB to MB
set /a FREE_MEM_MB=%FREE_MEM%/1024

if %FREE_MEM_MB% lss 500 (
    echo [%TIMESTAMP%] LOW MEMORY: %FREE_MEM_MB%MB available >> "%AUDIT_LOG%"
    exit /b 1
)

exit /b 0

REM =====================================================
REM End of script
REM =====================================================