@echo off
echo ==============================================
echo    BMAD Template - Configuration MCP
echo ==============================================
echo.

echo 📋 Configuration des serveurs MCP...
node "%~dp0setup-mcp-config.js"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Configuration MCP terminée avec succès !
    echo.
    echo 📋 Étapes suivantes :
    echo    1. Configurez vos tokens dans .env
    echo    2. Redémarrez Claude Code
    echo    3. Utilisez /mcp pour vérifier
    echo.
    echo 📖 Guide complet : MCP-SETUP-GUIDE.md
    echo.
) else (
    echo.
    echo ❌ Erreur lors de la configuration MCP
    echo 💡 Vérifiez que Node.js est installé
    echo.
)

pause