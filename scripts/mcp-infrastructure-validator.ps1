#Requires -Version 5.1
<#
.SYNOPSIS
    MCP Infrastructure Validation Suite - Production-Ready DevOps
.DESCRIPTION
    Suite complète de validation pour serveurs MCP critiques avec monitoring temps réel,
    benchmarks performance, et coordination agents BMAD.
    
    Serveurs critiques analysés : GitHub, Firecrawl, PostgreSQL, Redis + 4 serveurs medium priority
.AUTHOR
    contains-eng-devops (BMAD harmonisé)
.VERSION
    1.0.0 - Production Ready
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Quick", "Full", "Benchmark", "Monitor")]
    [string]$ValidationMode = "Full",
    
    [Parameter(Mandatory=$false)]
    [int]$TimeoutSeconds = 30,
    
    [Parameter(Mandatory=$false)]
    [int]$RetryAttempts = 3,
    
    [Parameter(Mandatory=$false)]
    [switch]$ContinuousMonitoring,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFormat = "Console" # Console, JSON, CSV
)

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION & CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

$Script:Config = @{
    ProjectRoot = $PSScriptRoot | Split-Path -Parent
    LogsPath = Join-Path $PSScriptRoot "..\logs\mcp-validation"
    BenchmarkPath = Join-Path $PSScriptRoot "..\logs\benchmarks"
    AuditPath = Join-Path $PSScriptRoot "..\logs\audit"
    
    # Serveurs MCP critiques identifiés
    CriticalServers = @("github", "firecrawl", "postgres", "redis")
    HighPriorityServers = @("postgres", "redis") 
    MediumPriorityServers = @("notion", "shadcn", "filesystem", "memory")
    
    # Seuils performance critiques
    PerformanceThresholds = @{
        ConnectionLatency = 1000  # ms
        ResponseTime = 5000       # ms  
        MemoryUsage = 512         # MB
        CPUUsage = 80            # %
    }
    
    # Configuration monitoring
    MonitoringInterval = 10      # secondes
    AlertThreshold = 3          # échecs consécutifs
}

# Couleurs pour output
$Script:Colors = @{
    Success = "Green"
    Warning = "Yellow" 
    Error = "Red"
    Info = "Cyan"
    Critical = "Magenta"
}

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITAIRES DE BASE
# ═══════════════════════════════════════════════════════════════════════════════

function Write-ColoredOutput {
    param([string]$Message, [string]$Color = "White", [switch]$NoNewline)
    
    $params = @{
        Object = $Message
        ForegroundColor = $Color
    }
    if ($NoNewline) { $params.NoNewline = $true }
    
    Write-Host @params
}

function Initialize-Directories {
    $Script:Config.LogsPath, $Script:Config.BenchmarkPath, $Script:Config.AuditPath | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -Path $_ -ItemType Directory -Force | Out-Null
            Write-ColoredOutput "✓ Créé répertoire : $_" $Script:Colors.Info
        }
    }
}

function Get-Timestamp {
    return (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
}

function Write-AuditLog {
    param([string]$Action, [string]$Result, [hashtable]$Details = @{})
    
    $auditEntry = @{
        Timestamp = Get-Timestamp
        Action = $Action  
        Result = $Result
        Details = $Details
        ProcessId = $PID
        User = $env:USERNAME
    } | ConvertTo-Json -Compress
    
    $auditFile = Join-Path $Script:Config.AuditPath "mcp-validation-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $auditFile -Value $auditEntry
}

# ═══════════════════════════════════════════════════════════════════════════════
# VALIDATION SERVEURS MCP
# ═══════════════════════════════════════════════════════════════════════════════

function Test-MCPServerConnectivity {
    param(
        [string]$ServerName,
        [hashtable]$ServerConfig,
        [int]$TimeoutMs = 30000,
        [int]$RetryCount = 3
    )
    
    $startTime = Get-Date
    $results = @{
        ServerName = $ServerName
        Status = "Unknown"
        ResponseTime = 0
        Attempts = 0
        LastError = $null
        ConnectionDetails = @{}
    }
    
    Write-ColoredOutput "🔍 Test connectivité $ServerName..." $Script:Colors.Info
    
    for ($attempt = 1; $attempt -le $RetryCount; $attempt++) {
        $results.Attempts = $attempt
        $attemptStart = Get-Date
        
        try {
            # Test spécifique par type de serveur
            switch ($ServerName) {
                "github" {
                    $testResult = Test-GitHubMCPConnection -Config $ServerConfig -TimeoutMs $TimeoutMs
                }
                "postgres" {
                    $testResult = Test-PostgreSQLConnection -Config $ServerConfig -TimeoutMs $TimeoutMs  
                }
                "redis" {
                    $testResult = Test-RedisConnection -Config $ServerConfig -TimeoutMs $TimeoutMs
                }
                "firecrawl" {
                    $testResult = Test-FirecrawlConnection -Config $ServerConfig -TimeoutMs $TimeoutMs
                }
                default {
                    $testResult = Test-GenericMCPConnection -ServerName $ServerName -Config $ServerConfig -TimeoutMs $TimeoutMs
                }
            }
            
            $results.Status = $testResult.Status
            $results.ResponseTime = ((Get-Date) - $attemptStart).TotalMilliseconds
            $results.ConnectionDetails = $testResult.Details
            
            if ($testResult.Status -eq "Success") {
                Write-ColoredOutput "  ✓ Connexion réussie (tentative $attempt)" $Script:Colors.Success
                break
            }
            
        } catch {
            $results.LastError = $_.Exception.Message
            Write-ColoredOutput "  ✗ Échec tentative $attempt : $($_.Exception.Message)" $Script:Colors.Warning
            
            if ($attempt -lt $RetryCount) {
                Start-Sleep -Seconds 2
            }
        }
    }
    
    # Audit logging
    Write-AuditLog -Action "MCP_SERVER_TEST" -Result $results.Status -Details @{
        Server = $ServerName
        Attempts = $results.Attempts
        ResponseTime = $results.ResponseTime
        Error = $results.LastError
    }
    
    return $results
}

function Test-GitHubMCPConnection {
    param([hashtable]$Config, [int]$TimeoutMs)
    
    # Vérification présence npx et GitHub MCP server
    $npxPath = (Get-Command npx -ErrorAction SilentlyContinue)?.Source
    if (-not $npxPath) {
        throw "npx non trouvé. Node.js requis pour serveurs MCP."
    }
    
    # Test installation du package GitHub MCP
    $testProcess = Start-Process -FilePath "npx" -ArgumentList @("-y", "@github/github-mcp-server", "--help") -NoNewWindow -Wait -PassThru -RedirectStandardError "NUL"
    
    if ($testProcess.ExitCode -eq 0) {
        return @{
            Status = "Success"
            Details = @{
                NPXPath = $npxPath
                PackageInstalled = $true
                Command = "npx -y @github/github-mcp-server"
            }
        }
    } else {
        throw "Package @github/github-mcp-server non accessible"
    }
}

function Test-PostgreSQLConnection {
    param([hashtable]$Config, [int]$TimeoutMs)
    
    $connectionString = "Host=$($Config.env.PGHOST);Database=$($Config.env.PGDATABASE);Username=$($Config.env.PGUSER)"
    
    # Test basique de connectivité TCP
    $host = $Config.env.PGHOST -replace "localhost", "127.0.0.1"
    $port = 5432
    
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connectTask = $tcpClient.ConnectAsync($host, $port)
    
    if ($connectTask.Wait($TimeoutMs)) {
        $tcpClient.Close()
        return @{
            Status = "Success"  
            Details = @{
                Host = $host
                Port = $port
                Database = $Config.env.PGDATABASE
                User = $Config.env.PGUSER
                ConnectionType = "TCP"
            }
        }
    } else {
        throw "Timeout connexion PostgreSQL $host`:$port"
    }
}

function Test-RedisConnection {
    param([hashtable]$Config, [int]$TimeoutMs)
    
    $redisUrl = $Config.env.REDIS_URL
    if ($redisUrl -match "redis://([^:]+):(\d+)") {
        $host = $matches[1] -replace "localhost", "127.0.0.1" 
        $port = [int]$matches[2]
    } else {
        throw "Format REDIS_URL invalide : $redisUrl"
    }
    
    # Test connectivité TCP Redis
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $connectTask = $tcpClient.ConnectAsync($host, $port)
    
    if ($connectTask.Wait($TimeoutMs)) {
        $tcpClient.Close()
        return @{
            Status = "Success"
            Details = @{
                Host = $host  
                Port = $port
                Database = $Config.env.REDIS_DB
                URL = $redisUrl
                ConnectionType = "TCP"
            }
        }
    } else {
        throw "Timeout connexion Redis $host`:$port"
    }
}

function Test-FirecrawlConnection {
    param([hashtable]$Config, [int]$TimeoutMs)
    
    # Vérification package Firecrawl MCP
    $testProcess = Start-Process -FilePath "npx" -ArgumentList @("-y", "@mendable/firecrawl-mcp", "--help") -NoNewWindow -Wait -PassThru -RedirectStandardError "NUL"
    
    if ($testProcess.ExitCode -eq 0) {
        return @{
            Status = "Success"
            Details = @{
                PackageInstalled = $true
                Command = "npx -y @mendable/firecrawl-mcp"
                Service = "Web Scraping Intelligence"
            }
        }
    } else {
        throw "Package @mendable/firecrawl-mcp non accessible"
    }
}

function Test-GenericMCPConnection {
    param([string]$ServerName, [hashtable]$Config, [int]$TimeoutMs)
    
    $command = $Config.command
    $args = $Config.args -join " "
    
    # Test générique d'accessibilité du package
    $testArgs = @($Config.args) + @("--help")
    $testProcess = Start-Process -FilePath $command -ArgumentList $testArgs -NoNewWindow -Wait -PassThru -RedirectStandardError "NUL"
    
    if ($testProcess.ExitCode -eq 0) {
        return @{
            Status = "Success" 
            Details = @{
                Command = "$command $args"
                PackageAccessible = $true
                ServerType = $ServerName
            }
        }
    } else {
        throw "Package $args non accessible via $command"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# BENCHMARKS PERFORMANCE
# ═══════════════════════════════════════════════════════════════════════════════

function Start-PerformanceBenchmark {
    param([string]$Phase = "Baseline") # Baseline, Post-MCP, Comparison
    
    Write-ColoredOutput "🚀 Démarrage benchmark performance ($Phase)..." $Script:Colors.Info
    
    $benchmarkResults = @{
        Timestamp = Get-Timestamp
        Phase = $Phase
        SystemMetrics = Get-SystemMetrics
        MCPServerMetrics = @{}
        NetworkLatency = @{}
        ProcessMetrics = @{}
    }
    
    # Métriques système globales
    $benchmarkResults.SystemMetrics = Get-SystemMetrics
    
    # Test latence réseau vers services externes
    $benchmarkResults.NetworkLatency = Test-NetworkLatency
    
    # Métriques processus NPX/Node
    $benchmarkResults.ProcessMetrics = Get-NodeProcessMetrics
    
    # Sauvegarde results
    $benchmarkFile = Join-Path $Script:Config.BenchmarkPath "benchmark-$Phase-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $benchmarkResults | ConvertTo-Json -Depth 5 | Set-Content -Path $benchmarkFile
    
    Write-ColoredOutput "✓ Benchmark $Phase sauvegardé : $benchmarkFile" $Script:Colors.Success
    
    return $benchmarkResults
}

function Get-SystemMetrics {
    $cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average
    $memory = Get-WmiObject Win32_OperatingSystem
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
    
    return @{
        CPU = @{
            Usage = [math]::Round($cpu.Average, 2)
            Cores = $env:NUMBER_OF_PROCESSORS
        }
        Memory = @{
            TotalGB = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
            FreeGB = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
            UsagePercent = [math]::Round((($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / $memory.TotalVisibleMemorySize) * 100, 2)
        }
        Disk = $disk | ForEach-Object {
            @{
                Drive = $_.DeviceID
                SizeGB = [math]::Round($_.Size / 1GB, 2)  
                FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
                UsagePercent = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 2)
            }
        }
    }
}

function Test-NetworkLatency {
    $targets = @{
        GitHub = "github.com"
        PostgreSQL = "127.0.0.1"
        Redis = "127.0.0.1"
        DNS = "8.8.8.8"
    }
    
    $results = @{}
    
    foreach ($name in $targets.Keys) {
        $target = $targets[$name]
        try {
            $ping = Test-Connection -ComputerName $target -Count 3 -Quiet -ErrorAction SilentlyContinue
            if ($ping) {
                $pingResult = Test-Connection -ComputerName $target -Count 3
                $avgLatency = ($pingResult | Measure-Object -Property ResponseTime -Average).Average
                $results[$name] = [math]::Round($avgLatency, 2)
            } else {
                $results[$name] = "Unreachable"
            }
        } catch {
            $results[$name] = "Error: $($_.Exception.Message)"
        }
    }
    
    return $results
}

function Get-NodeProcessMetrics {
    $nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue
    $npxProcesses = Get-Process -Name "npx" -ErrorAction SilentlyContinue
    
    $allProcesses = @($nodeProcesses) + @($npxProcesses)
    
    if ($allProcesses.Count -eq 0) {
        return @{
            ProcessCount = 0
            TotalMemoryMB = 0
            TotalCPUPercent = 0
        }
    }
    
    $totalMemory = ($allProcesses | Measure-Object -Property WorkingSet64 -Sum).Sum / 1MB
    
    return @{
        ProcessCount = $allProcesses.Count
        TotalMemoryMB = [math]::Round($totalMemory, 2)
        Processes = $allProcesses | ForEach-Object {
            @{
                Name = $_.ProcessName
                PID = $_.Id
                MemoryMB = [math]::Round($_.WorkingSet64 / 1MB, 2)
                StartTime = $_.StartTime
            }
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# MONITORING TEMPS RÉEL
# ═══════════════════════════════════════════════════════════════════════════════

function Start-RealTimeMonitoring {
    param([int]$IntervalSeconds = 10, [int]$DurationMinutes = 60)
    
    Write-ColoredOutput "📊 Démarrage monitoring temps réel (${DurationMinutes}min, intervalle ${IntervalSeconds}s)..." $Script:Colors.Info
    
    $endTime = (Get-Date).AddMinutes($DurationMinutes)
    $alertCounts = @{}
    
    # Configuration alertes
    foreach ($server in $Script:Config.CriticalServers + $Script:Config.HighPriorityServers) {
        $alertCounts[$server] = 0
    }
    
    while ((Get-Date) -lt $endTime) {
        $monitoringResults = @{
            Timestamp = Get-Timestamp
            SystemHealth = Get-SystemMetrics
            MCPServerStatus = @{}
        }
        
        # Test rapide de chaque serveur critique
        foreach ($serverName in $Script:Config.CriticalServers) {
            try {
                $quickTest = Test-MCPServerConnectivity -ServerName $serverName -ServerConfig @{} -TimeoutMs 5000 -RetryCount 1
                $monitoringResults.MCPServerStatus[$serverName] = @{
                    Status = $quickTest.Status
                    ResponseTime = $quickTest.ResponseTime
                }
                
                # Reset alert counter si succès
                if ($quickTest.Status -eq "Success") {
                    $alertCounts[$serverName] = 0
                } else {
                    $alertCounts[$serverName]++
                    
                    # Déclenchement alerte si seuil atteint
                    if ($alertCounts[$serverName] -ge $Script:Config.AlertThreshold) {
                        Send-Alert -ServerName $serverName -Issue "Service indisponible" -ConsecutiveFailures $alertCounts[$serverName]
                    }
                }
                
            } catch {
                $monitoringResults.MCPServerStatus[$serverName] = @{
                    Status = "Error"
                    Error = $_.Exception.Message
                }
                $alertCounts[$serverName]++
            }
        }
        
        # Vérification seuils performance
        Test-PerformanceThresholds -Metrics $monitoringResults.SystemHealth
        
        # Affichage status console
        Show-MonitoringDashboard -Results $monitoringResults
        
        # Log monitoring
        $monitoringFile = Join-Path $Script:Config.LogsPath "monitoring-$(Get-Date -Format 'yyyyMMdd').json"
        $monitoringResults | ConvertTo-Json -Depth 3 | Add-Content -Path $monitoringFile
        
        Start-Sleep -Seconds $IntervalSeconds
    }
}

function Send-Alert {
    param([string]$ServerName, [string]$Issue, [int]$ConsecutiveFailures)
    
    $alert = @{
        Timestamp = Get-Timestamp
        Server = $ServerName
        Issue = $Issue
        ConsecutiveFailures = $ConsecutiveFailures
        Severity = if ($ServerName -in $Script:Config.CriticalServers) { "CRITICAL" } else { "HIGH" }
    }
    
    Write-ColoredOutput "🚨 ALERTE $($alert.Severity): $ServerName - $Issue (${ConsecutiveFailures}x)" $Script:Colors.Critical
    
    # Log alerte
    $alertFile = Join-Path $Script:Config.AuditPath "alerts-$(Get-Date -Format 'yyyyMMdd').json"
    $alert | ConvertTo-Json -Compress | Add-Content -Path $alertFile
    
    # Coordination avec bmad-parallel-orchestrator via hook
    Invoke-BMadCoordinationHook -Event "MCP_SERVER_ALERT" -Data $alert
}

function Test-PerformanceThresholds {
    param([hashtable]$Metrics)
    
    # Vérification CPU
    if ($Metrics.CPU.Usage -gt $Script:Config.PerformanceThresholds.CPUUsage) {
        Send-Alert -ServerName "SYSTEM" -Issue "CPU usage élevé: $($Metrics.CPU.Usage)%" -ConsecutiveFailures 1
    }
    
    # Vérification mémoire  
    if ($Metrics.Memory.UsagePercent -gt 90) {
        Send-Alert -ServerName "SYSTEM" -Issue "Mémoire critique: $($Metrics.Memory.UsagePercent)%" -ConsecutiveFailures 1
    }
}

function Show-MonitoringDashboard {
    param([hashtable]$Results)
    
    Clear-Host
    Write-ColoredOutput "═══════════════════════════════════════════════════════════════════" $Script:Colors.Info
    Write-ColoredOutput "🔧 BMAD MCP Infrastructure Monitor - $(Get-Timestamp)" $Script:Colors.Info  
    Write-ColoredOutput "═══════════════════════════════════════════════════════════════════" $Script:Colors.Info
    
    # Status serveurs MCP
    Write-ColoredOutput "`n📡 SERVEURS MCP CRITIQUES:" $Script:Colors.Info
    foreach ($server in $Results.MCPServerStatus.Keys) {
        $status = $Results.MCPServerStatus[$server]
        $color = if ($status.Status -eq "Success") { $Script:Colors.Success } else { $Script:Colors.Error }
        $responseTime = if ($status.ResponseTime) { " ($([math]::Round($status.ResponseTime, 0))ms)" } else { "" }
        Write-ColoredOutput "  $server`: $($status.Status)$responseTime" $color
    }
    
    # Métriques système
    $sys = $Results.SystemHealth
    Write-ColoredOutput "`n💻 MÉTRIQUES SYSTÈME:" $Script:Colors.Info
    Write-ColoredOutput "  CPU: $($sys.CPU.Usage)% ($($sys.CPU.Cores) cores)" $(if ($sys.CPU.Usage -gt 80) { $Script:Colors.Warning } else { $Script:Colors.Success })
    Write-ColoredOutput "  RAM: $($sys.Memory.UsagePercent)% ($($sys.Memory.FreeGB)GB libre)" $(if ($sys.Memory.UsagePercent -gt 90) { $Script:Colors.Error } else { $Script:Colors.Success })
    
    Write-ColoredOutput "`n⏱️  Prochain refresh dans $($Script:Config.MonitoringInterval)s..." $Script:Colors.Info
}

# ═══════════════════════════════════════════════════════════════════════════════
# COORDINATION BMAD
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-BMadCoordinationHook {
    param([string]$Event, [hashtable]$Data)
    
    # Hook vers bmad-parallel-orchestrator
    $hookData = @{
        Source = "contains-eng-devops"
        Event = $Event
        Timestamp = Get-Timestamp
        Data = $Data
    }
    
    $hookFile = Join-Path $Script:Config.ProjectRoot "hooks\bmad-coordination-events.json"
    
    if (Test-Path $hookFile) {
        $existingHooks = Get-Content $hookFile | ConvertFrom-Json
        $existingHooks += $hookData
    } else {
        $existingHooks = @($hookData)
    }
    
    $existingHooks | ConvertTo-Json -Depth 4 | Set-Content $hookFile
    
    Write-ColoredOutput "🔗 Hook BMAD envoyé: $Event" $Script:Colors.Info
}

function Initialize-BMadSecurityIntegration {
    Write-ColoredOutput "🔐 Initialisation intégration sécurité BMAD-QA..." $Script:Colors.Info
    
    # Vérification permissions matrix du project.mcp.json
    $mcpConfig = Get-Content (Join-Path $Script:Config.ProjectRoot "project.mcp.json") | ConvertFrom-Json
    
    $securityValidation = @{
        TLSEncryption = $mcpConfig.mcp_security.access_control.encrypted_connections -eq "TLS_1_3"
        AuditLogging = $mcpConfig.mcp_security.audit_logging.enabled -eq $true
        ResourceIsolation = $mcpConfig.mcp_security.access_control.resource_isolation -eq $true
        PermissionsMatrix = $mcpConfig.permissions_matrix -ne $null
    }
    
    $allSecure = $securityValidation.Values -notcontains $false
    
    if ($allSecure) {
        Write-ColoredOutput "✓ Configuration sécurité MCP validée" $Script:Colors.Success
    } else {
        Write-ColoredOutput "⚠️  Problèmes sécurité détectés:" $Script:Colors.Warning
        foreach ($check in $securityValidation.Keys) {
            if (-not $securityValidation[$check]) {
                Write-ColoredOutput "  ✗ $check" $Script:Colors.Error
            }
        }
    }
    
    return $securityValidation
}

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALISATION & SCRIPTS AUTOMATISÉS
# ═══════════════════════════════════════════════════════════════════════════════

function Initialize-MCPServices {
    Write-ColoredOutput "🚀 Initialisation automatisée services MCP..." $Script:Colors.Info
    
    # Vérification prérequis
    Test-Prerequisites
    
    # Création structure logs/audit
    Initialize-Directories
    
    # Vérification sécurité BMAD
    Initialize-BMadSecurityIntegration
    
    # Initialisation monitoring baseline
    Start-PerformanceBenchmark -Phase "Baseline"
    
    Write-ColoredOutput "✅ Services MCP initialisés avec succès!" $Script:Colors.Success
}

function Test-Prerequisites {
    Write-ColoredOutput "🔍 Vérification prérequis..." $Script:Colors.Info
    
    # Node.js / NPX
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        throw "Node.js requis pour serveurs MCP. Installation: https://nodejs.org"
    }
    
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
        throw "NPX requis pour serveurs MCP. Installation: npm install -g npx"
    }
    
    Write-ColoredOutput "✓ Node.js & NPX disponibles" $Script:Colors.Success
    
    # Vérification projet MCP
    $mcpConfigPath = Join-Path $Script:Config.ProjectRoot "project.mcp.json"
    if (-not (Test-Path $mcpConfigPath)) {
        throw "Configuration MCP manquante: $mcpConfigPath"
    }
    
    Write-ColoredOutput "✓ Configuration MCP trouvée" $Script:Colors.Success
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTERFACE PRINCIPALE & RAPPORTS
# ═══════════════════════════════════════════════════════════════════════════════

function Show-ValidationSummary {
    param([array]$Results, [hashtable]$Benchmarks = @{})
    
    Write-ColoredOutput "`n═══════════════════════════════════════════════════════════════════" $Script:Colors.Info
    Write-ColoredOutput "📊 RAPPORT VALIDATION MCP INFRASTRUCTURE" $Script:Colors.Info
    Write-ColoredOutput "═══════════════════════════════════════════════════════════════════" $Script:Colors.Info
    
    # Résumé par priorité
    $critical = $Results | Where-Object { $_.ServerName -in $Script:Config.CriticalServers }
    $high = $Results | Where-Object { $_.ServerName -in $Script:Config.HighPriorityServers -and $_.ServerName -notin $Script:Config.CriticalServers }
    $medium = $Results | Where-Object { $_.ServerName -in $Script:Config.MediumPriorityServers }
    
    Write-ColoredOutput "`n🔴 SERVEURS CRITIQUES:" $Script:Colors.Critical
    foreach ($result in $critical) {
        $status = if ($result.Status -eq "Success") { "✅ OK" } else { "❌ KO" }
        $color = if ($result.Status -eq "Success") { $Script:Colors.Success } else { $Script:Colors.Error }
        Write-ColoredOutput "  $($result.ServerName): $status ($([math]::Round($result.ResponseTime, 0))ms)" $color
    }
    
    Write-ColoredOutput "`n🟡 SERVEURS HAUTE PRIORITÉ:" $Script:Colors.Warning
    foreach ($result in $high) {
        $status = if ($result.Status -eq "Success") { "✅ OK" } else { "❌ KO" } 
        $color = if ($result.Status -eq "Success") { $Script:Colors.Success } else { $Script:Colors.Error }
        Write-ColoredOutput "  $($result.ServerName): $status ($([math]::Round($result.ResponseTime, 0))ms)" $color
    }
    
    # Statistiques globales
    $successCount = ($Results | Where-Object { $_.Status -eq "Success" }).Count
    $totalCount = $Results.Count
    $successRate = [math]::Round(($successCount / $totalCount) * 100, 1)
    
    Write-ColoredOutput "`n📈 STATISTIQUES GLOBALES:" $Script:Colors.Info
    Write-ColoredOutput "  Taux de succès: $successRate% ($successCount/$totalCount)" $(if ($successRate -ge 90) { $Script:Colors.Success } else { $Script:Colors.Warning })
    Write-ColoredOutput "  Temps moyen réponse: $([math]::Round(($Results | Measure-Object -Property ResponseTime -Average).Average, 0))ms" $Script:Colors.Info
    
    # Recommandations
    Write-ColoredOutput "`n💡 RECOMMANDATIONS:" $Script:Colors.Info
    if ($successRate -lt 100) {
        Write-ColoredOutput "  • Vérifier services en échec avant production" $Script:Colors.Warning
    }
    if (($Results | Measure-Object -Property ResponseTime -Average).Average -gt $Script:Config.PerformanceThresholds.ConnectionLatency) {
        Write-ColoredOutput "  • Optimiser performances réseau/serveurs" $Script:Colors.Warning  
    }
    Write-ColoredOutput "  • Monitoring continu recommandé pour production" $Script:Colors.Info
}

# ═══════════════════════════════════════════════════════════════════════════════
# POINT D'ENTRÉE PRINCIPAL
# ═══════════════════════════════════════════════════════════════════════════════

function Main {
    try {
        Write-ColoredOutput "🔧 BMAD MCP Infrastructure Validator - contains-eng-devops" $Script:Colors.Info
        Write-ColoredOutput "Mode: $ValidationMode | Timeout: ${TimeoutSeconds}s | Retry: $RetryAttempts" $Script:Colors.Info
        
        # Initialisation
        Initialize-Directories
        
        # Chargement configuration MCP
        $mcpConfigPath = Join-Path $Script:Config.ProjectRoot "project.mcp.json"
        $mcpConfig = Get-Content $mcpConfigPath | ConvertFrom-Json
        
        # Exécution selon mode choisi
        switch ($ValidationMode) {
            "Quick" {
                Write-ColoredOutput "`n🏃‍♂️ MODE RAPIDE - Serveurs critiques uniquement..." $Script:Colors.Info
                $results = @()
                foreach ($serverName in $Script:Config.CriticalServers) {
                    $serverConfig = $mcpConfig.mcpServers.$serverName
                    $results += Test-MCPServerConnectivity -ServerName $serverName -ServerConfig $serverConfig -TimeoutMs ($TimeoutSeconds * 1000) -RetryCount 1
                }
                Show-ValidationSummary -Results $results
            }
            
            "Full" {
                Write-ColoredOutput "`n🔍 MODE COMPLET - Tous serveurs + benchmarks..." $Script:Colors.Info
                
                # Benchmark baseline
                $baselineBenchmark = Start-PerformanceBenchmark -Phase "Baseline"
                
                # Tests tous serveurs
                $results = @()
                foreach ($serverName in $mcpConfig.mcpServers.PSObject.Properties.Name) {
                    $serverConfig = $mcpConfig.mcpServers.$serverName
                    $results += Test-MCPServerConnectivity -ServerName $serverName -ServerConfig $serverConfig -TimeoutMs ($TimeoutSeconds * 1000) -RetryCount $RetryAttempts
                }
                
                # Benchmark post-validation
                $postValidationBenchmark = Start-PerformanceBenchmark -Phase "Post-Validation"
                
                Show-ValidationSummary -Results $results -Benchmarks @{ Baseline = $baselineBenchmark; PostValidation = $postValidationBenchmark }
            }
            
            "Benchmark" {
                Write-ColoredOutput "`n📊 MODE BENCHMARK - Focus performance..." $Script:Colors.Info
                Start-PerformanceBenchmark -Phase "Standalone"
            }
            
            "Monitor" {
                Write-ColoredOutput "`n📡 MODE MONITORING - Surveillance temps réel..." $Script:Colors.Info
                if ($ContinuousMonitoring) {
                    Start-RealTimeMonitoring -DurationMinutes 1440 # 24h
                } else {
                    Start-RealTimeMonitoring -DurationMinutes 60   # 1h
                }
            }
        }
        
        # Coordination finale BMAD
        Invoke-BMadCoordinationHook -Event "MCP_VALIDATION_COMPLETED" -Data @{
            Mode = $ValidationMode
            Success = $true
            ResultsCount = if ($results) { $results.Count } else { 0 }
        }
        
        Write-ColoredOutput "`n✅ Validation MCP terminée avec succès!" $Script:Colors.Success
        
    } catch {
        Write-ColoredOutput "❌ ERREUR CRITIQUE: $($_.Exception.Message)" $Script:Colors.Error
        Write-AuditLog -Action "VALIDATION_FAILED" -Result "ERROR" -Details @{ Error = $_.Exception.Message }
        
        Invoke-BMadCoordinationHook -Event "MCP_VALIDATION_FAILED" -Data @{
            Error = $_.Exception.Message
            Mode = $ValidationMode  
        }
        
        exit 1
    }
}

# Exécution si script appelé directement
if ($MyInvocation.InvocationName -ne '.') {
    Main
}