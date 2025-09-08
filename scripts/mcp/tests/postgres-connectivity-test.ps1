# ==================================================================================
# BMAD MCP PostgreSQL Connectivity Test Script
# Objectif : Test de connectivité robuste pour le serveur MCP PostgreSQL
# Compatible : Windows PowerShell 5.1+ / PowerShell Core 7+
# ==================================================================================

param(
    [string]$LogPath = "scripts\logs\audit\postgres-mcp-test.log",
    [int]$RetryCount = 3,
    [int]$TimeoutSeconds = 30,
    [string]$PgHost = "localhost",
    [string]$PgUser = "bmad_coordinator", 
    [string]$PgDatabase = "bmad_coordination",
    [string]$PgPort = "5432",
    [switch]$Verbose
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

# Fonctions utilitaires
function Write-AuditLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [POSTGRES-MCP] $Message"
    
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

function Test-PostgreSQLService {
    try {
        # Test service PostgreSQL Windows
        $pgService = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
        if ($pgService) {
            $serviceStatus = $pgService.Status -eq "Running"
            Write-AuditLog "Service PostgreSQL : $($pgService.Status)" $(if($serviceStatus) {'SUCCESS'} else {'ERROR'})
            return $serviceStatus
        } else {
            Write-AuditLog "Service PostgreSQL non trouvé - Test ignoré" "WARN"
            return $null
        }
    }
    catch {
        Write-AuditLog "Erreur lors du test du service : $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-PostgreSQLConnectivity {
    param(
        [string]$Host,
        [string]$Port,
        [string]$Database,
        [string]$User,
        [string]$Password
    )
    
    try {
        # Test connectivité TCP
        $tcpTest = Test-NetConnection -ComputerName $Host -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
        if (-not $tcpTest) {
            return @{
                Success = $false
                Error = "Connexion TCP échouée vers $Host`:$Port"
                Stage = "TCP"
            }
        }
        
        # Test connexion PostgreSQL avec psql si disponible
        $psqlPath = where.exe psql 2>$null
        if ($psqlPath) {
            $env:PGPASSWORD = $Password
            $connectionString = "host=$Host port=$Port dbname=$Database user=$User"
            
            $testQuery = "SELECT version(), current_timestamp;"
            $psqlArgs = @("-h", $Host, "-p", $Port, "-d", $Database, "-U", $User, "-c", $testQuery, "-t", "-A")
            
            $process = Start-Process -FilePath "psql" -ArgumentList $psqlArgs -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "temp_psql_output.txt" -RedirectStandardError "temp_psql_error.txt"
            
            if ($process.ExitCode -eq 0) {
                $output = Get-Content "temp_psql_output.txt" -Raw
                Remove-Item "temp_psql_output.txt", "temp_psql_error.txt" -ErrorAction SilentlyContinue
                
                return @{
                    Success = $true
                    Version = $output.Split('|')[0]
                    Timestamp = $output.Split('|')[1]
                    Stage = "FULL"
                }
            } else {
                $error = Get-Content "temp_psql_error.txt" -Raw
                Remove-Item "temp_psql_output.txt", "temp_psql_error.txt" -ErrorAction SilentlyContinue
                
                return @{
                    Success = $false
                    Error = $error
                    Stage = "AUTH"
                }
            }
        } else {
            # Test basique sans psql - utilisation .NET
            try {
                Add-Type -AssemblyName System.Data
                $connectionString = "Host=$Host;Port=$Port;Database=$Database;Username=$User"
                if ($Password) { $connectionString += ";Password=$Password" }
                
                $connection = New-Object System.Data.Common.DbConnection
                # Note: Cette méthode nécessite Npgsql, alternative basique pour test TCP uniquement
                return @{
                    Success = $true
                    Message = "Connectivité TCP confirmée, test complet nécessite psql ou Npgsql"
                    Stage = "TCP_ONLY"
                }
            }
            catch {
                return @{
                    Success = $false
                    Error = $_.Exception.Message
                    Stage = "NET"
                }
            }
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            Stage = "EXCEPTION"
        }
    }
    finally {
        Remove-Variable -Name "PGPASSWORD" -Scope Script -ErrorAction SilentlyContinue
    }
}

function Test-MCPPostgreSQLServer {
    try {
        # Test installation du serveur MCP PostgreSQL
        $testArgs = @("-y", "@modelcontextprotocol/postgres", "--help")
        $process = Start-Process -FilePath "npx" -ArgumentList $testArgs -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "temp_mcp_output.txt" -RedirectStandardError "temp_mcp_error.txt"
        
        $success = $process.ExitCode -eq 0
        $output = if (Test-Path "temp_mcp_output.txt") { Get-Content "temp_mcp_output.txt" -Raw } else { "" }
        $error = if (Test-Path "temp_mcp_error.txt") { Get-Content "temp_mcp_error.txt" -Raw } else { "" }
        
        Remove-Item "temp_mcp_output.txt", "temp_mcp_error.txt" -ErrorAction SilentlyContinue
        
        return @{
            Success = $success
            Output = $output
            Error = $error
        }
    }
    catch {
        Write-AuditLog "Erreur lors du test du serveur MCP PostgreSQL: $($_.Exception.Message)" "ERROR"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-DatabasePermissions {
    param([string]$Host, [string]$Port, [string]$Database, [string]$User, [string]$Password)
    
    try {
        $psqlPath = where.exe psql 2>$null
        if (-not $psqlPath) {
            return @{
                Success = $null
                Message = "psql non disponible pour test permissions"
            }
        }
        
        $env:PGPASSWORD = $Password
        $permissionTests = @(
            "SELECT 1;",  # Test lecture basique
            "CREATE TEMP TABLE test_temp (id int);",  # Test création temporaire
            "SELECT current_user, session_user;"  # Test utilisateur actuel
        )
        
        $results = @{}
        foreach ($test in $permissionTests) {
            $psqlArgs = @("-h", $Host, "-p", $Port, "-d", $Database, "-U", $User, "-c", $test, "-t")
            $process = Start-Process -FilePath "psql" -ArgumentList $psqlArgs -PassThru -Wait -WindowStyle Hidden -RedirectStandardOutput "temp_perm_output.txt" -RedirectStandardError "temp_perm_error.txt"
            
            $results[$test] = $process.ExitCode -eq 0
        }
        
        Remove-Item "temp_perm_output.txt", "temp_perm_error.txt" -ErrorAction SilentlyContinue
        
        return @{
            Success = $true
            Results = $results
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
    finally {
        Remove-Variable -Name "PGPASSWORD" -Scope Script -ErrorAction SilentlyContinue
    }
}

# Script principal
function Start-PostgreSQLMCPTest {
    Write-AuditLog "===== DÉBUT TEST CONNECTIVITÉ POSTGRESQL MCP ====="
    
    $testResults = @{
        ServiceStatus = $null
        DatabaseConnectivity = $null
        MCPServer = $null
        Permissions = $null
        OverallStatus = $false
        StartTime = Get-Date
        EndTime = $null
        Duration = $null
    }
    
    # Variables d'environnement
    $pgPassword = $env:PGPASSWORD
    if (-not $pgPassword) {
        Write-AuditLog "AVERTISSEMENT : Variable PGPASSWORD non définie" "WARN"
    }
    
    # 1. Test service PostgreSQL
    Write-AuditLog "1. Vérification du service PostgreSQL..."
    $testResults.ServiceStatus = Test-PostgreSQLService
    
    # 2. Test connectivité base de données
    Write-AuditLog "2. Test de connectivité à la base de données..."
    $dbResult = Test-PostgreSQLConnectivity -Host $PgHost -Port $PgPort -Database $PgDatabase -User $PgUser -Password $pgPassword
    $testResults.DatabaseConnectivity = $dbResult
    
    if ($dbResult.Success) {
        Write-AuditLog "SUCCÈS : Connectivité PostgreSQL OK - Stage: $($dbResult.Stage)" "SUCCESS"
        if ($dbResult.Version) {
            Write-AuditLog "Version PostgreSQL : $($dbResult.Version)" "SUCCESS"
        }
    } else {
        Write-AuditLog "ÉCHEC : Connectivité PostgreSQL échouée - $($dbResult.Error) (Stage: $($dbResult.Stage))" "ERROR"
    }
    
    # 3. Test serveur MCP PostgreSQL
    Write-AuditLog "3. Test du serveur MCP PostgreSQL..."
    $mcpResult = Test-MCPPostgreSQLServer
    $testResults.MCPServer = $mcpResult
    
    if ($mcpResult.Success) {
        Write-AuditLog "SUCCÈS : Serveur MCP PostgreSQL opérationnel" "SUCCESS"
    } else {
        Write-AuditLog "ÉCHEC : Problème avec le serveur MCP PostgreSQL - $($mcpResult.Error)" "ERROR"
    }
    
    # 4. Test permissions (si connectivité OK)
    if ($dbResult.Success -and $dbResult.Stage -eq "FULL") {
        Write-AuditLog "4. Test des permissions de base de données..."
        $permResult = Test-DatabasePermissions -Host $PgHost -Port $PgPort -Database $PgDatabase -User $PgUser -Password $pgPassword
        $testResults.Permissions = $permResult
        
        if ($permResult.Success -and $permResult.Results) {
            $successfulPerms = ($permResult.Results.Values | Where-Object { $_ -eq $true }).Count
            $totalPerms = $permResult.Results.Count
            Write-AuditLog "PERMISSIONS : $successfulPerms/$totalPerms tests réussis" "SUCCESS"
        }
    }
    
    # 5. Évaluation globale
    $testResults.EndTime = Get-Date
    $testResults.Duration = ($testResults.EndTime - $testResults.StartTime).TotalSeconds
    
    $successfulTests = 0
    $totalTests = 0
    
    # Service (optionnel)
    if ($testResults.ServiceStatus -eq $true) { $successfulTests++ }
    if ($testResults.ServiceStatus -ne $null) { $totalTests++ }
    
    # Connectivité (critique)
    if ($testResults.DatabaseConnectivity.Success) { $successfulTests++ }; $totalTests++
    
    # Serveur MCP (critique)  
    if ($testResults.MCPServer.Success) { $successfulTests++ }; $totalTests++
    
    # Permissions (si testé)
    if ($testResults.Permissions -and $testResults.Permissions.Success) { $successfulTests++ }
    if ($testResults.Permissions -ne $null) { $totalTests++ }
    
    $successRate = if ($totalTests -gt 0) { [math]::Round(($successfulTests / $totalTests) * 100, 2) } else { 0 }
    $testResults.OverallStatus = $successRate -ge 75
    
    if ($testResults.OverallStatus) {
        Write-AuditLog "===== RÉSULTAT GLOBAL : SUCCÈS ($successRate% - $successfulTests/$totalTests tests réussis) =====" "SUCCESS"
    } else {
        Write-AuditLog "===== RÉSULTAT GLOBAL : ÉCHEC ($successRate% - $successfulTests/$totalTests tests réussis) =====" "ERROR"
    }
    
    Write-AuditLog "Durée totale du test : $($testResults.Duration) secondes"
    Write-AuditLog "===== FIN TEST CONNECTIVITÉ POSTGRESQL MCP ====="
    
    return $testResults
}

# Point d'entrée principal avec retry logic
$attemptCount = 0
$lastResult = $null

do {
    $attemptCount++
    Write-AuditLog "Tentative $attemptCount/$RetryCount"
    
    try {
        $lastResult = Start-PostgreSQLMCPTest
        
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