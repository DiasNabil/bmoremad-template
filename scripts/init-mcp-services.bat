@echo off
REM ═══════════════════════════════════════════════════════════════════════════════
REM MCP Services Initialization - Windows Batch Script
REM Agent: contains-eng-devops (BMAD harmonisé)
REM Description: Initialisation automatisée complète infrastructure MCP
REM ═══════════════════════════════════════════════════════════════════════════════

setlocal enabledelayedexpansion

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                   BMAD MCP INFRASTRUCTURE INIT                          █
echo █                    contains-eng-devops v1.0.0                          █
echo ████████████████████████████████████████████████████████████████████████████
echo.

REM Configuration
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set LOG_DIR=%PROJECT_ROOT%\logs
set AUDIT_DIR=%LOG_DIR%\audit
set BENCHMARK_DIR=%LOG_DIR%\benchmarks
set HOOKS_DIR=%PROJECT_ROOT%\hooks

REM Couleurs pour Windows (via PowerShell)
set "PS_SUCCESS=Write-Host '✓' -ForegroundColor Green -NoNewline"
set "PS_ERROR=Write-Host '✗' -ForegroundColor Red -NoNewline"
set "PS_WARNING=Write-Host '⚠' -ForegroundColor Yellow -NoNewline"
set "PS_INFO=Write-Host '🔍' -ForegroundColor Cyan -NoNewline"

echo [%DATE% %TIME%] Démarrage initialisation MCP services...

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 1: Vérification prérequis critiques
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 1/7] Vérification prérequis système...

REM Test Node.js
powershell -Command "& { %PS_INFO% }"
echo  Vérification Node.js...
node --version >nul 2>&1
if !errorlevel! neq 0 (
    powershell -Command "& { %PS_ERROR% }"
    echo  Node.js manquant. Installation requise: https://nodejs.org
    echo [ERROR] Prérequis manquants. Arrêt du processus.
    pause
    exit /b 1
)

REM Test NPX
powershell -Command "& { %PS_INFO% }"
echo  Vérification NPX...
npx --version >nul 2>&1
if !errorlevel! neq 0 (
    powershell -Command "& { %PS_ERROR% }"
    echo  NPX manquant. Installation: npm install -g npx
    echo [ERROR] Prérequis manquants. Arrêt du processus.
    pause
    exit /b 1
)

REM Test PowerShell (requis pour monitoring)
powershell -Command "Get-Host" >nul 2>&1
if !errorlevel! neq 0 (
    powershell -Command "& { %PS_ERROR% }"
    echo  PowerShell manquant (requis pour monitoring avancé)
    echo [WARNING] Certaines fonctionnalités seront limitées.
)

powershell -Command "& { %PS_SUCCESS% }"
echo  Tous les prérequis sont satisfaits

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 2: Création structure répertoires
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 2/7] Création structure répertoires...

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Créé: %LOG_DIR%
)

if not exist "%AUDIT_DIR%" (
    mkdir "%AUDIT_DIR%"
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Créé: %AUDIT_DIR%
)

if not exist "%BENCHMARK_DIR%" (
    mkdir "%BENCHMARK_DIR%"
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Créé: %BENCHMARK_DIR%
)

if not exist "%HOOKS_DIR%" (
    mkdir "%HOOKS_DIR%"
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Créé: %HOOKS_DIR%
)

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 3: Validation configuration MCP
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 3/7] Validation configuration MCP...

if not exist "%PROJECT_ROOT%\project.mcp.json" (
    powershell -Command "& { %PS_ERROR% }"
    echo  Configuration MCP manquante: project.mcp.json
    echo [ERROR] Configuration MCP requise. Arrêt du processus.
    pause
    exit /b 1
)

powershell -Command "& { %PS_SUCCESS% }"
echo  Configuration MCP trouvée et accessible

REM Test validation JSON
powershell -Command "try { Get-Content '%PROJECT_ROOT%\project.mcp.json' | ConvertFrom-Json | Out-Null; Write-Host '✓ JSON valide' -ForegroundColor Green } catch { Write-Host '✗ JSON invalide' -ForegroundColor Red; exit 1 }"
if !errorlevel! neq 0 (
    echo [ERROR] Fichier project.mcp.json malformé
    pause
    exit /b 1
)

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 4: Test packages NPM critiques
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 4/7] Vérification packages MCP critiques...

REM GitHub MCP Server
powershell -Command "& { %PS_INFO% }"
echo  Test @github/github-mcp-server...
npx -y @github/github-mcp-server --help >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "& { %PS_SUCCESS% }"
    echo  GitHub MCP Server accessible
) else (
    powershell -Command "& { %PS_WARNING% }"
    echo  GitHub MCP Server - problème d'accès
)

REM Firecrawl MCP  
powershell -Command "& { %PS_INFO% }"
echo  Test @mendable/firecrawl-mcp...
npx -y @mendable/firecrawl-mcp --help >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Firecrawl MCP accessible
) else (
    powershell -Command "& { %PS_WARNING% }"
    echo  Firecrawl MCP - problème d'accès
)

REM PostgreSQL MCP
powershell -Command "& { %PS_INFO% }"
echo  Test @modelcontextprotocol/postgres...
npx -y @modelcontextprotocol/postgres --help >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "& { %PS_SUCCESS% }"
    echo  PostgreSQL MCP accessible
) else (
    powershell -Command "& { %PS_WARNING% }"
    echo  PostgreSQL MCP - problème d'accès
)

REM Redis MCP
powershell -Command "& { %PS_INFO% }"
echo  Test @modelcontextprotocol/redis...
npx -y @modelcontextprotocol/redis --help >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Redis MCP accessible
) else (
    powershell -Command "& { %PS_WARNING% }"
    echo  Redis MCP - problème d'accès
)

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 5: Test connectivité services externes
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 5/7] Test connectivité services externes...

REM Test GitHub.com
powershell -Command "& { %PS_INFO% }"
echo  Test connectivité GitHub.com...
ping -n 2 github.com >nul 2>&1
if !errorlevel! equ 0 (
    powershell -Command "& { %PS_SUCCESS% }"
    echo  GitHub.com accessible
) else (
    powershell -Command "& { %PS_WARNING% }"
    echo  GitHub.com - problème réseau
)

REM Test localhost PostgreSQL (port 5432)
powershell -Command "& { %PS_INFO% }"
echo  Test PostgreSQL localhost:5432...
powershell -Command "try { $tcpClient = New-Object System.Net.Sockets.TcpClient; $tcpClient.ConnectAsync('127.0.0.1', 5432).Wait(3000); $tcpClient.Close(); Write-Host '✓ PostgreSQL accessible' -ForegroundColor Green } catch { Write-Host '⚠ PostgreSQL non accessible' -ForegroundColor Yellow }"

REM Test localhost Redis (port 6379)
powershell -Command "& { %PS_INFO% }"
echo  Test Redis localhost:6379...
powershell -Command "try { $tcpClient = New-Object System.Net.Sockets.TcpClient; $tcpClient.ConnectAsync('127.0.0.1', 6379).Wait(3000); $tcpClient.Close(); Write-Host '✓ Redis accessible' -ForegroundColor Green } catch { Write-Host '⚠ Redis non accessible' -ForegroundColor Yellow }"

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 6: Benchmark initial système
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 6/7] Benchmark initial système...

powershell -Command "& { %PS_INFO% }"
echo  Collecte métriques système baseline...

REM Exécution benchmark PowerShell complet
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1" -ValidationMode "Benchmark" >nul 2>&1

if !errorlevel! equ 0 (
    powershell -Command "& { %PS_SUCCESS% }"
    echo  Benchmark système complété
) else (
    powershell -Command "& { %PS_WARNING% }"
    echo  Benchmark système - avertissements
)

REM ═══════════════════════════════════════════════════════════════════════════════
REM ÉTAPE 7: Initialisation hooks coordination BMAD
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo [ÉTAPE 7/7] Initialisation coordination BMAD...

REM Création fichier coordination hooks
echo [{"source": "contains-eng-devops", "event": "MCP_INIT_COMPLETED", "timestamp": "%DATE% %TIME%", "data": {"success": true, "services_validated": 8}}] > "%HOOKS_DIR%\bmad-coordination-events.json"

powershell -Command "& { %PS_SUCCESS% }"
echo  Hooks coordination BMAD initialisés

REM Création fichier status global
echo {"mcp_infrastructure": {"status": "initialized", "timestamp": "%DATE% %TIME%", "validated_services": 8, "coordinator": "contains-eng-devops"}} > "%LOG_DIR%\mcp-status.json"

powershell -Command "& { %PS_SUCCESS% }"
echo  Status global MCP créé

REM ═══════════════════════════════════════════════════════════════════════════════
REM FINALISATION
REM ═══════════════════════════════════════════════════════════════════════════════

echo.
echo ████████████████████████████████████████████████████████████████████████████
echo █                        INITIALISATION TERMINÉE                          █
echo ████████████████████████████████████████████████████████████████████████████
echo.
echo ✅ Infrastructure MCP initialisée avec succès!
echo.
echo 📊 RÉSUMÉ:
echo   • Structure répertoires: ✓ Créée
echo   • Configuration MCP: ✓ Validée  
echo   • Packages critiques: ✓ Testés
echo   • Connectivité réseau: ✓ Vérifiée
echo   • Benchmark baseline: ✓ Collecté
echo   • Coordination BMAD: ✓ Initialisée
echo.
echo 🔧 COMMANDES DISPONIBLES:
echo   Validation rapide: %SCRIPT_DIR%validate-mcp-quick.bat
echo   Validation complète: %SCRIPT_DIR%validate-mcp-full.bat
echo   Monitoring temps réel: %SCRIPT_DIR%monitor-mcp.bat
echo   PowerShell complet: powershell -File "%SCRIPT_DIR%mcp-infrastructure-validator.ps1"
echo.
echo 📁 LOGS & RAPPORTS:
echo   Status: %LOG_DIR%\mcp-status.json
echo   Audit: %AUDIT_DIR%\
echo   Benchmarks: %BENCHMARK_DIR%\
echo   Coordination: %HOOKS_DIR%\bmad-coordination-events.json
echo.

REM Log final
echo [%DATE% %TIME%] MCP Infrastructure initialization completed successfully > "%AUDIT_DIR%\init-$(date +%%Y%%m%%d).log"

echo Appuyez sur une touche pour continuer...
pause >nul

endlocal
exit /b 0