@echo off
echo ==================================================
echo  Motion MCP Animation Integration Validation - BMAD
echo ==================================================
echo.

echo [1/6] Validating Motion MCP Server Installation...
call npx motion-ai --help >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo WARNING: Motion MCP server (motion-ai) not found
    echo This is normal - it will be installed automatically when needed
    echo Motion MCP server: npx motion-ai
) else (
    echo ✓ Motion MCP Server (motion-ai) accessible
)

echo.
echo [2/6] Checking project.mcp.json configuration...
if not exist "project.mcp.json" (
    echo ERROR: project.mcp.json not found
    pause
    exit /b 1
)

findstr /c:"motion-ai" project.mcp.json >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Motion MCP server not configured in project.mcp.json
    pause
    exit /b 1
)
echo ✓ Motion (motion-ai) configuration found in project.mcp.json

echo.
echo [3/6] Validating Motion+ token setup...
if not exist ".env" (
    echo INFO: .env file not found - creating .env.example
    echo MOTION_PLUS_TOKEN=your_motion_plus_token_here >> .env.example
    echo NOTE: Motion+ token is optional for basic Motion MCP features
) else (
    findstr /c:"MOTION_PLUS_TOKEN" .env >nul
    if %ERRORLEVEL% neq 0 (
        echo INFO: MOTION_PLUS_TOKEN not found in .env file
        echo This is optional - only needed for Motion+ exclusive features
    ) else (
        echo ✓ Motion+ token configuration found
    )
)

echo.
echo [4/6] Checking design agent integrations...
if exist ".claude\agents\Contains-Studio\Design\contains-design-ui.md" (
    findstr /c:"Motion Animation Integration" ".claude\agents\Contains-Studio\Design\contains-design-ui.md" >nul
    if %ERRORLEVEL% equ 0 (
        echo ✓ contains-design-ui Motion animation integration validated
    ) else (
        echo WARNING: Motion animation integration not found in contains-design-ui
    )
) else (
    echo WARNING: contains-design-ui agent not found
)

if exist ".claude\agents\Contains-Studio\Engineering\contains-eng-frontend.md" (
    findstr /c:"Motion Animation Implementation" ".claude\agents\Contains-Studio\Engineering\contains-eng-frontend.md" >nul
    if %ERRORLEVEL% equ 0 (
        echo ✓ contains-eng-frontend Motion implementation validated
    ) else (
        echo WARNING: Motion implementation not found in contains-eng-frontend
    )
) else (
    echo WARNING: contains-eng-frontend agent not found
)

echo.
echo [5/6] Checking animation workflow commands...
if exist ".claude\commands\BMad\motion-animation-system.md" (
    echo ✓ Motion animation system workflow found
) else (
    echo WARNING: motion-animation-system.md workflow not found
)

echo.
echo [6/6] Checking Motion MCP permissions...
findstr /c:"animation_generation" project.mcp.json >nul
if %ERRORLEVEL% equ 0 (
    echo ✓ Motion animation permissions configured
) else (
    echo WARNING: Motion animation permissions not found in permissions matrix
)

echo.
echo ==================================================
echo  Motion Animation Integration Validation Complete
echo ==================================================
echo.
echo Motion MCP Features Available:
echo - CSS spring generation via LLM commands
echo - Animation curve visualization in editor
echo - Latest Motion documentation as MCP resources  
echo - React/Vue/JavaScript animation support
echo.
echo Next Steps:
echo 1. Test Motion documentation access in Claude Code
echo 2. Try: "Create a bouncy spring animation for buttons"
echo 3. Use: /BMad/motion-animation-system for full animation workflows
echo 4. Explore Motion curve visualization features
echo.
echo For Motion+ features, visit: https://motion.dev/plus
echo Motion documentation: https://motion.dev/docs
echo.
pause