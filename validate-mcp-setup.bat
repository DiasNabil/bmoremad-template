@echo off
REM Validation rapide configuration MCP Parallel Orchestrator

echo =====================================
echo BMAD Parallel Orchestrator Validator
echo =====================================
echo.

set "SUCCESS=0"

REM Check hooks
if exist "hooks\mcp-coordination-validator.bat" set /a SUCCESS+=1
if exist "hooks\mcp-performance-monitor.bat" set /a SUCCESS+=1  
if exist "hooks\agent-resource-allocator.bat" set /a SUCCESS+=1
if exist "hooks\agent-synchronizer.bat" set /a SUCCESS+=1
if exist "hooks\conflict-resolver.bat" set /a SUCCESS+=1

REM Check audit structure
if exist "logs\audit\active-agents.json" set /a SUCCESS+=1
if exist "logs\audit\shared-state.json" set /a SUCCESS+=1

REM Check configuration
if exist ".claude\settings.json" set /a SUCCESS+=1

echo Validation Results:
if %SUCCESS% geq 8 (
    echo ✓ Configuration COMPLETE: %SUCCESS%/8 checks passed
    echo ✓ Ready for parallel coordination!
) else (
    echo ✗ Configuration INCOMPLETE: %SUCCESS%/8 checks passed  
    echo ✗ Some components missing
)

echo.
echo Available coordination patterns:
echo - Contains Studio Integration (3 agents)
echo - Fullstack Development (4 agents)  
echo - Quality Assurance (3 agents)
echo.
echo Ready to coordinate with:
echo - bmad-parallel-orchestrator (priority 1)
echo - contains-eng-devops (priority 2)
echo - bmad-qa (priority 2)
echo.

exit /b 0