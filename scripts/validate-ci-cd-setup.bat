@echo off
REM BMAD+Contains Studio CI/CD Setup Validation Script for Windows
REM This script validates the complete CI/CD integration on Windows systems

echo 🚀 BMAD+Contains Studio CI/CD Setup Validation
echo ================================================

set "TESTS_PASSED=0"
set "TESTS_FAILED=0"
set "TOTAL_TESTS=0"

echo.
echo 📋 Validating CI/CD Integration...
echo.

REM Test 1: Check GitHub Workflows
set /a TOTAL_TESTS+=1
if exist ".github\workflows\bmad-ci.yml" (
    echo ✅ BMAD CI workflow found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ BMAD CI workflow missing
    set /a TESTS_FAILED+=1
)

set /a TOTAL_TESTS+=1
if exist ".github\workflows\claude-code-pr-review.yml" (
    echo ✅ Claude Code PR review workflow found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Claude Code PR review workflow missing
    set /a TESTS_FAILED+=1
)

set /a TOTAL_TESTS+=1
if exist ".github\workflows\mcp-validation.yml" (
    echo ✅ MCP validation workflow found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ MCP validation workflow missing
    set /a TESTS_FAILED+=1
)

set /a TOTAL_TESTS+=1
if exist ".github\workflows\weekly-reports.yml" (
    echo ✅ Weekly reports workflow found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Weekly reports workflow missing
    set /a TESTS_FAILED+=1
)

REM Test 2: Check Claude Code Configuration
set /a TOTAL_TESTS+=1
if exist "CLAUDE.md" (
    echo ✅ Claude Code configuration found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Claude Code configuration missing
    set /a TESTS_FAILED+=1
)

REM Test 3: Check MCP Configuration
set /a TOTAL_TESTS+=1
if exist "project.mcp.json" (
    echo ✅ MCP configuration found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ MCP configuration missing
    set /a TESTS_FAILED+=1
)

REM Test 4: Check Documentation
set /a TOTAL_TESTS+=1
if exist "docs\ci-cd-integration-guide.md" (
    echo ✅ CI/CD integration guide found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ CI/CD integration guide missing
    set /a TESTS_FAILED+=1
)

set /a TOTAL_TESTS+=1
if exist ".github\workflows\README.md" (
    echo ✅ Workflows documentation found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Workflows documentation missing
    set /a TESTS_FAILED+=1
)

REM Test 5: Check Integration Scripts
set /a TOTAL_TESTS+=1
if exist "scripts\test-workflows.sh" (
    echo ✅ Integration test script found
    set /a TESTS_PASSED+=1
) else (
    echo ❌ Integration test script missing
    set /a TESTS_FAILED+=1
)

REM Test 6: Validate JSON Configuration (if node is available)
where node >nul 2>nul
if %errorlevel% equ 0 (
    set /a TOTAL_TESTS+=1
    node -e "try { JSON.parse(require('fs').readFileSync('project.mcp.json', 'utf8')); console.log('✅ MCP JSON configuration valid'); process.exit(0); } catch(e) { console.log('❌ MCP JSON configuration invalid'); process.exit(1); }"
    if %errorlevel% equ 0 (
        set /a TESTS_PASSED+=1
    ) else (
        set /a TESTS_FAILED+=1
    )
) else (
    echo ⚠️  Node.js not found - skipping JSON validation
)

echo.
echo 📊 Validation Summary:
echo ======================
echo Total Tests: %TOTAL_TESTS%
echo Passed: %TESTS_PASSED%
echo Failed: %TESTS_FAILED%

REM Calculate success rate
set /a SUCCESS_RATE=%TESTS_PASSED% * 100 / %TOTAL_TESTS%
echo Success Rate: %SUCCESS_RATE%%%

echo.
if %TESTS_FAILED% equ 0 (
    echo 🎉 All validations passed!
    echo ✅ BMAD+Contains Studio CI/CD integration is complete and ready
    echo.
    echo 🚀 Next Steps:
    echo 1. Commit and push your changes
    echo 2. Create a pull request to test the automation
    echo 3. Monitor the GitHub Actions workflows
    echo 4. Review weekly reports for system health
    echo.
    exit /b 0
) else (
    echo ❌ Some validations failed
    echo Please review the failed items above and ensure all files are present
    echo.
    echo 📚 Helpful Resources:
    echo - Documentation: docs\ci-cd-integration-guide.md
    echo - Workflows Guide: .github\workflows\README.md
    echo - Claude Config: CLAUDE.md
    echo.
    exit /b 1
)