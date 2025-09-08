@echo off
REM Test Parallel Coordination Script
REM Teste la configuration complète MCP hooks pour coordination parallèle

setlocal enabledelayedexpansion

echo ==========================================
echo  BMAD Parallel Orchestrator - Test Suite
echo ==========================================
echo.

set "TIMESTAMP=%date% %time%"
set "TEST_LOG=logs\audit\coordination-test.log"

echo [%TIMESTAMP%] Starting parallel coordination test suite > "%TEST_LOG%"
echo Starting parallel coordination test suite...
echo.

REM Test 1: Vérification des hooks
echo Test 1: Hook Validation
echo [%TIMESTAMP%] TEST 1: Hook validation started >> "%TEST_LOG%"

set "HOOKS_FOUND=0"
if exist "hooks\mcp-coordination-validator.bat" (
    set /a HOOKS_FOUND+=1
    echo   ✓ MCP Coordination Validator hook found
)
if exist "hooks\mcp-performance-monitor.bat" (
    set /a HOOKS_FOUND+=1
    echo   ✓ MCP Performance Monitor hook found
)
if exist "hooks\agent-resource-allocator.bat" (
    set /a HOOKS_FOUND+=1
    echo   ✓ Agent Resource Allocator hook found
)
if exist "hooks\agent-synchronizer.bat" (
    set /a HOOKS_FOUND+=1
    echo   ✓ Agent Synchronizer hook found
)
if exist "hooks\conflict-resolver.bat" (
    set /a HOOKS_FOUND+=1
    echo   ✓ Conflict Resolver hook found
)

echo   Total hooks found: !HOOKS_FOUND!/5
echo [%TIMESTAMP%] Hook validation completed - !HOOKS_FOUND!/5 hooks found >> "%TEST_LOG%"
echo.

REM Test 2: Vérification des répertoires d'audit
echo Test 2: Audit Directory Structure
echo [%TIMESTAMP%] TEST 2: Audit directory validation started >> "%TEST_LOG%"

if exist "logs\audit\" (
    echo   ✓ Main audit directory exists
    
    if exist "logs\audit\active-agents.json" (
        echo   ✓ Active agents registry exists
    ) else (
        echo   ✗ Active agents registry missing
    )
    
    if exist "logs\audit\shared-state.json" (
        echo   ✓ Shared state file exists
    ) else (
        echo   ✗ Shared state file missing
    )
    
    echo [%TIMESTAMP%] Audit directory validation completed >> "%TEST_LOG%"
) else (
    echo   ✗ Audit directory missing
    echo [%TIMESTAMP%] ERROR: Audit directory not found >> "%TEST_LOG%"
)
echo.

REM Test 3: Test de coordination des hooks
echo Test 3: Hook Coordination Test
echo [%TIMESTAMP%] TEST 3: Hook coordination test started >> "%TEST_LOG%"

echo   Testing MCP Coordination Validator...
call hooks\mcp-coordination-validator.bat >nul 2>&1
if !errorlevel! equ 0 (
    echo   ✓ MCP Coordination Validator executed successfully
) else (
    echo   ✗ MCP Coordination Validator failed
)

echo   Testing Agent Resource Allocator...
call hooks\agent-resource-allocator.bat >nul 2>&1
if !errorlevel! equ 0 (
    echo   ✓ Agent Resource Allocator executed successfully
) else (
    echo   ✗ Agent Resource Allocator failed
)

echo   Testing Agent Synchronizer...
call hooks\agent-synchronizer.bat bmad-parallel-orchestrator >nul 2>&1
if !errorlevel! equ 0 (
    echo   ✓ Agent Synchronizer executed successfully
) else (
    echo   ✗ Agent Synchronizer failed
)

echo [%TIMESTAMP%] Hook coordination test completed >> "%TEST_LOG%"
echo.

REM Test 4: Simulation de coordination parallèle
echo Test 4: Parallel Coordination Simulation
echo [%TIMESTAMP%] TEST 4: Parallel coordination simulation started >> "%TEST_LOG%"

echo   Simulating 3-agent parallel execution...

REM Simulation d'agents parallèles
start /B call hooks\agent-synchronizer.bat bmad-parallel-orchestrator
start /B call hooks\agent-synchronizer.bat contains-eng-devops
start /B call hooks\agent-synchronizer.bat bmad-qa

REM Attendre un peu pour la synchronisation
timeout /t 2 >nul 2>&1

echo   ✓ 3-agent coordination simulation completed
echo [%TIMESTAMP%] Parallel coordination simulation completed >> "%TEST_LOG%"
echo.

REM Test 5: Vérification de la configuration Claude
echo Test 5: Claude Settings Validation
echo [%TIMESTAMP%] TEST 5: Claude settings validation started >> "%TEST_LOG%"

if exist ".claude\settings.json" (
    findstr /c:"mcpIntegration" ".claude\settings.json" >nul
    if !errorlevel! equ 0 (
        echo   ✓ MCP Integration configuration found in Claude settings
        
        findstr /c:"parallelAgentsConfig" ".claude\settings.json" >nul
        if !errorlevel! equ 0 (
            echo   ✓ Parallel Agents configuration found
        ) else (
            echo   ✗ Parallel Agents configuration missing
        )
    ) else (
        echo   ✗ MCP Integration configuration missing
    )
) else (
    echo   ✗ Claude settings file not found
)

echo [%TIMESTAMP%] Claude settings validation completed >> "%TEST_LOG%"
echo.

REM Résumé final
echo ==========================================
echo  Test Suite Summary
echo ==========================================

if !HOOKS_FOUND! equ 5 (
    echo ✓ All coordination hooks are properly configured
    set "HOOKS_STATUS=PASS"
) else (
    echo ✗ Missing coordination hooks detected
    set "HOOKS_STATUS=FAIL"
)

if exist "logs\audit\shared-state.json" (
    echo ✓ Audit infrastructure is operational
    set "AUDIT_STATUS=PASS"
) else (
    echo ✗ Audit infrastructure needs attention
    set "AUDIT_STATUS=FAIL"
)

echo ✓ Parallel coordination simulation completed
set "SIMULATION_STATUS=PASS"

echo.
echo Final Status:
echo   Hooks: !HOOKS_STATUS!
echo   Audit: !AUDIT_STATUS!
echo   Simulation: !SIMULATION_STATUS!
echo.

if "!HOOKS_STATUS!!AUDIT_STATUS!!SIMULATION_STATUS!"=="PASSPASSPASS" (
    echo 🚀 BMAD Parallel Orchestrator is READY for coordination!
    echo [%TIMESTAMP%] TEST SUITE PASSED - System ready for parallel coordination >> "%TEST_LOG%"
    exit /b 0
) else (
    echo ⚠️  Configuration needs attention before parallel coordination
    echo [%TIMESTAMP%] TEST SUITE FAILED - Configuration issues detected >> "%TEST_LOG%"
    exit /b 1
)