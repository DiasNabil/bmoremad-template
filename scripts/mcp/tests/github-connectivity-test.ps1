# ==================================================================================
# BMAD MCP GitHub Connectivity Test Script
# Objectif : Test de connectivité robuste pour le serveur MCP GitHub
# Compatible : Windows PowerShell 5.1+ / PowerShell Core 7+
# ==================================================================================

param(
    [string]$LogPath = "scripts\logs\audit\github-mcp-test.log",
    [int]$RetryCount = 3,
    [int]$TimeoutSeconds = 30,
    [switch]$Verbose
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# Fonctions utilitaires
function Write-AuditLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [GITHUB-MCP] $Message"
    
    # Console output avec couleurs
    switch ($Level) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "WARN"  { Write-Host $logEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry -ForegroundColor White }
    }
    
    # Log file
    $logEntry | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

function Test-GitHubAPIAccess {
    param([string]$Token)
    
    try {
        $headers = @{
            "Authorization" = "token $Token"
            "User-Agent" = "BMAD-MCP-Test/1.0"
        }
        
        $response = Invoke-RestMethod -Uri "https://api.github.com/user" -Headers $headers -TimeoutSec $TimeoutSeconds
        return @{
            Success = $true
            User = $response.login
            RateLimit = $response.headers["X-RateLimit-Remaining"]
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-MCPServerProcess {
    try {
        $mcpProcess = Start-Process -FilePath "npx" -ArgumentList "-y", "@github/github-mcp-server", "--version" -PassThru -Wait -WindowStyle Hidden
        return $mcpProcess.ExitCode -eq 0
    }
    catch {
        Write-AuditLog "Erreur lors du test du processus MCP: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-NetworkConnectivity {
    $endpoints = @(
        "api.github.com",
        "github.com",
        "raw.githubusercontent.com"
    )
    
    $results = @{}
    foreach ($endpoint in $endpoints) {
        try {
            $ping = Test-NetConnection -ComputerName $endpoint -Port 443 -InformationLevel Quiet
            $results[$endpoint] = $ping
            Write-AuditLog "Connectivité $endpoint : $(if($ping) {'OK'} else {'FAILED'})" $(if($ping) {'SUCCESS'} else {'ERROR'})
        }
        catch {
            $results[$endpoint] = $false
            Write-AuditLog "Erreur test connectivité $endpoint : $($_.Exception.Message)" "ERROR"
        }
    }
    return $results
}

# Script principal
function Start-GitHubMCPTest {
    Write-AuditLog "===== DÉBUT TEST CONNECTIVITÉ GITHUB MCP ====="
    
    $testResults = @{
        NetworkConnectivity = $null
        APIAccess = $null
        MCPProcess = $null
        OverallStatus = $false
        StartTime = Get-Date
        EndTime = $null
        Duration = $null
    }
    
    # 1. Test connectivité réseau
    Write-AuditLog "1. Test de connectivité réseau GitHub..."
    $testResults.NetworkConnectivity = Test-NetworkConnectivity
    $networkOK = ($testResults.NetworkConnectivity.Values | Where-Object { $_ -eq $false }).Count -eq 0
    
    if (-not $networkOK) {
        Write-AuditLog "ÉCHEC : Problème de connectivité réseau détecté" "ERROR"
    } else {
        Write-AuditLog "SUCCÈS : Connectivité réseau GitHub OK" "SUCCESS"
    }
    
    # 2. Test API GitHub (si token disponible)
    Write-AuditLog "2. Test d'accès API GitHub..."
    $githubToken = $env:GITHUB_TOKEN
    if ($githubToken) {
        $apiResult = Test-GitHubAPIAccess -Token $githubToken
        $testResults.APIAccess = $apiResult
        
        if ($apiResult.Success) {
            Write-AuditLog "SUCCÈS : API GitHub accessible - Utilisateur: $($apiResult.User)" "SUCCESS"
        } else {
            Write-AuditLog "ÉCHEC : API GitHub inaccessible - $($apiResult.Error)" "ERROR"
        }
    } else {
        Write-AuditLog "AVERTISSEMENT : Variable GITHUB_TOKEN non définie - Test API ignoré" "WARN"
        $testResults.APIAccess = @{ Success = $null; Message = "Token non disponible" }
    }
    
    # 3. Test processus MCP
    Write-AuditLog "3. Test du processus serveur MCP GitHub..."
    $mcpOK = Test-MCPServerProcess
    $testResults.MCPProcess = $mcpOK
    
    if ($mcpOK) {
        Write-AuditLog "SUCCÈS : Serveur MCP GitHub opérationnel" "SUCCESS"
    } else {
        Write-AuditLog "ÉCHEC : Problème avec le serveur MCP GitHub" "ERROR"
    }
    
    # 4. Évaluation globale
    $testResults.EndTime = Get-Date
    $testResults.Duration = ($testResults.EndTime - $testResults.StartTime).TotalSeconds
    
    $successfulTests = 0
    $totalTests = 0
    
    if ($networkOK) { $successfulTests++ }; $totalTests++
    if ($testResults.APIAccess.Success -eq $true) { $successfulTests++ }
    if ($testResults.APIAccess.Success -ne $null) { $totalTests++ }
    if ($mcpOK) { $successfulTests++ }; $totalTests++
    
    $successRate = [math]::Round(($successfulTests / $totalTests) * 100, 2)
    $testResults.OverallStatus = $successRate -ge 75
    
    if ($testResults.OverallStatus) {
        Write-AuditLog "===== RÉSULTAT GLOBAL : SUCCÈS ($successRate% - $successfulTests/$totalTests tests réussis) =====" "SUCCESS"
    } else {
        Write-AuditLog "===== RÉSULTAT GLOBAL : ÉCHEC ($successRate% - $successfulTests/$totalTests tests réussis) =====" "ERROR"
    }
    
    Write-AuditLog "Durée totale du test : $($testResults.Duration) secondes"
    Write-AuditLog "===== FIN TEST CONNECTIVITÉ GITHUB MCP ====="
    
    return $testResults
}

# Point d'entrée principal avec retry logic
$attemptCount = 0
$lastResult = $null

do {
    $attemptCount++
    Write-AuditLog "Tentative $attemptCount/$RetryCount"
    
    try {
        $lastResult = Start-GitHubMCPTest
        
        if ($lastResult.OverallStatus) {
            break
        } elseif ($attemptCount -lt $RetryCount) {
            Write-AuditLog "Tentative échouée, nouvelle tentative dans 5 secondes..." "WARN"
            Start-Sleep -Seconds 5
        }
    }
    catch {
        Write-AuditLog "Erreur critique lors du test : $($_.Exception.Message)" "ERROR"
        if ($attemptCount -lt $RetryCount) {
            Start-Sleep -Seconds 5
        }
    }
} while ($attemptCount -lt $RetryCount -and (-not $lastResult.OverallStatus))

# Code de sortie pour intégration CI/CD
if ($lastResult -and $lastResult.OverallStatus) {
    exit 0  # Succès
} else {
    exit 1  # Échec
}