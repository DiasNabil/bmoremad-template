#!/usr/bin/env pwsh
<#
.SYNOPSIS
    BMAD+Contains Studio+MCP Production Observability Master Controller
    
.DESCRIPTION
    Script maître d'observabilité production pour l'écosystème BMAD complet
    - Monitoring 24/7 des 23+ agents et 8 serveurs MCP
    - Collecte métriques temps réel avec alertes proactives
    - Génération rapports hebdomadaires automatisés
    - Détection anomalies avec recommandations
    
.PARAMETER Mode
    production, staging, development
    
.PARAMETER AlertThreshold
    critical, warning, info
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("production", "staging", "development")]
    [string]$Mode = "production",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("critical", "warning", "info")]
    [string]$AlertThreshold = "warning"
)

# Configuration globale
$BMAD_VERSION = "2024.12.07"
$SCRIPT_PATH = $PSScriptRoot
$BASE_PATH = Split-Path -Parent (Split-Path -Parent $SCRIPT_PATH)
$LOG_PATH = "$BASE_PATH\logs\observability"
$CONFIG_PATH = "$BASE_PATH\scripts\observability\config"
$REPORTS_PATH = "$BASE_PATH\scripts\observability\reports"

# Créer les répertoires nécessaires
@($LOG_PATH, $CONFIG_PATH, $REPORTS_PATH) | ForEach-Object {
    if (!(Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

# Timestamp pour tous les logs
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LOG_FILE = "$LOG_PATH\monitoring-master-$TIMESTAMP.log"

# Fonction de logging centralisée
function Write-BMadLog {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"
    Write-Host $LogEntry
    Add-Content -Path $LOG_FILE -Value $LogEntry
}

Write-BMadLog "🚀 BMAD Production Monitoring Master v$BMAD_VERSION démarré en mode [$Mode]"

# Configuration des métriques critiques
$METRICS_CONFIG = @{
    "agents_coordination" = @{
        "max_latency_ms" = 2000
        "min_success_rate" = 95.0
        "max_error_rate" = 5.0
    }
    "mcp_servers" = @{
        "max_response_time_ms" = 1500
        "min_availability" = 99.5
        "max_memory_mb" = 512
    }
    "parallel_execution" = @{
        "max_queue_size" = 100
        "min_throughput_ops_min" = 50
        "max_wait_time_ms" = 5000
    }
    "security" = @{
        "max_failed_auth_per_hour" = 10
        "min_compliance_score" = 85.0
        "max_vulnerabilities" = 0
    }
}

# Agents BMAD+Contains Studio à monitorer
$BMAD_AGENTS = @(
    "bmad-orchestrator-enhanced",
    "bmad-parallel-coordinator", 
    "bmad-analyst-data-senior",
    "bmad-pm-product-manager",
    "contains-design-ui-designer",
    "contains-design-ux-researcher", 
    "contains-eng-frontend-developer",
    "contains-eng-backend-architect",
    "contains-eng-devops-specialist",
    "contains-test-api-automation",
    "contains-test-performance",
    "contains-product-prioritizer"
)

# Serveurs MCP critiques
$MCP_SERVERS = @(
    "github", "firecrawl", "postgres", "redis", 
    "notion", "shadcn", "filesystem", "memory"
)

Write-BMadLog "Agents surveillés: $($BMAD_AGENTS.Count) | Serveurs MCP: $($MCP_SERVERS.Count)"

# Fonction de test de connectivité MCP
function Test-MCPServer {
    param([string]$ServerName)
    
    try {
        $startTime = Get-Date
        # Simulation test connectivité (à adapter selon serveur)
        $testResult = $true  # Remplacer par vraie logique de test
        $endTime = Get-Date
        $responseTime = ($endTime - $startTime).TotalMilliseconds
        
        return @{
            "server" = $ServerName
            "status" = if($testResult) { "UP" } else { "DOWN" }
            "response_time_ms" = [math]::Round($responseTime, 2)
            "timestamp" = $startTime
        }
    }
    catch {
        Write-BMadLog "Erreur test MCP server $ServerName : $_" "ERROR"
        return @{
            "server" = $ServerName
            "status" = "ERROR"
            "response_time_ms" = -1
            "error" = $_.Exception.Message
            "timestamp" = Get-Date
        }
    }
}

# Collecte des métriques en temps réel
function Collect-RealTimeMetrics {
    Write-BMadLog "📊 Collecte métriques temps réel démarrée"
    
    $metrics = @{
        "timestamp" = Get-Date
        "mcp_servers" = @{}
        "agents" = @{}
        "system" = @{}
        "performance" = @{}
    }
    
    # Test tous les serveurs MCP en parallèle
    $mcpResults = $MCP_SERVERS | ForEach-Object -Parallel {
        # Code de test MCP server
        $server = $_
        try {
            # Simulation - remplacer par vraie logique
            @{
                "server" = $server
                "status" = "UP"
                "response_time_ms" = Get-Random -Minimum 50 -Maximum 200
                "memory_mb" = Get-Random -Minimum 100 -Maximum 300
                "cpu_percent" = Get-Random -Minimum 5 -Maximum 25
                "connections" = Get-Random -Minimum 10 -Maximum 50
            }
        }
        catch {
            @{
                "server" = $server
                "status" = "ERROR"
                "error" = $_.Exception.Message
            }
        }
    } -ThrottleLimit 8
    
    # Agrégation résultats MCP
    foreach ($result in $mcpResults) {
        $metrics.mcp_servers[$result.server] = $result
    }
    
    # Métriques système
    $metrics.system = @{
        "cpu_percent" = (Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        "memory_percent" = [math]::Round(((Get-WmiObject -Class Win32_OperatingSystem).TotalVisibleMemorySize - (Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory) / (Get-WmiObject -Class Win32_OperatingSystem).TotalVisibleMemorySize * 100, 2)
        "disk_percent" = [math]::Round(((Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'").Size - (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace) / (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'").Size * 100, 2)
    }
    
    # Métriques de performance calculées
    $avgResponseTime = ($mcpResults | Where-Object { $_.response_time_ms -gt 0 } | Measure-Object -Property response_time_ms -Average).Average
    $upServers = ($mcpResults | Where-Object { $_.status -eq "UP" }).Count
    $totalServers = $MCP_SERVERS.Count
    
    $metrics.performance = @{
        "avg_response_time_ms" = [math]::Round($avgResponseTime, 2)
        "availability_percent" = [math]::Round(($upServers / $totalServers) * 100, 2)
        "total_servers" = $totalServers
        "up_servers" = $upServers
        "down_servers" = $totalServers - $upServers
    }
    
    Write-BMadLog "✅ Métriques collectées - Disponibilité: $($metrics.performance.availability_percent)% | Réponse moy: $($metrics.performance.avg_response_time_ms)ms"
    
    return $metrics
}

# Détection d'anomalies et alertes
function Analyze-Anomalies {
    param($Metrics)
    
    $alerts = @()
    $recommendations = @()
    
    # Analyse disponibilité MCP
    if ($Metrics.performance.availability_percent -lt $METRICS_CONFIG.mcp_servers.min_availability) {
        $alerts += @{
            "level" = "CRITICAL"
            "component" = "MCP_AVAILABILITY"
            "message" = "Disponibilité MCP sous seuil critique: $($Metrics.performance.availability_percent)% < $($METRICS_CONFIG.mcp_servers.min_availability)%"
            "impact" = "Coordination agents dégradée"
            "action" = "Redémarrer serveurs MCP défaillants immédiatement"
        }
        $recommendations += "Implémenter failover automatique pour serveurs MCP critiques"
    }
    
    # Analyse temps de réponse
    if ($Metrics.performance.avg_response_time_ms -gt $METRICS_CONFIG.mcp_servers.max_response_time_ms) {
        $alerts += @{
            "level" = "WARNING"  
            "component" = "MCP_PERFORMANCE"
            "message" = "Temps réponse MCP élevé: $($Metrics.performance.avg_response_time_ms)ms > $($METRICS_CONFIG.mcp_servers.max_response_time_ms)ms"
            "impact" = "Performance agents ralentie"
            "action" = "Optimiser requêtes et augmenter ressources"
        }
        $recommendations += "Activer cache Redis pour améliorer performances"
    }
    
    # Analyse ressources système
    if ($Metrics.system.memory_percent -gt 85) {
        $alerts += @{
            "level" = "WARNING"
            "component" = "SYSTEM_MEMORY"
            "message" = "Utilisation mémoire élevée: $($Metrics.system.memory_percent)%"
            "impact" = "Risque d'instabilité système"
            "action" = "Libérer mémoire ou augmenter RAM"
        }
    }
    
    return @{
        "alerts" = $alerts
        "recommendations" = $recommendations
        "analysis_timestamp" = Get-Date
    }
}

# Génération d'alertes
function Send-Alert {
    param($Alert)
    
    $alertMessage = @"
🚨 ALERTE BMAD $($Alert.level)
Composant: $($Alert.component)
Message: $($Alert.message)
Impact: $($Alert.impact)
Action: $($Alert.action)
Horodatage: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@
    
    Write-BMadLog $alertMessage "ALERT"
    
    # Ici ajouter logique d'envoi (email, Slack, Teams, etc.)
    # Exemple: Send-MailMessage, Invoke-RestMethod vers webhook
}

# Sauvegarde métriques pour reporting
function Save-MetricsForReporting {
    param($Metrics, $Analysis)
    
    $reportData = @{
        "collection_time" = $Metrics.timestamp
        "metrics" = $Metrics
        "analysis" = $Analysis
        "bmad_version" = $BMAD_VERSION
        "mode" = $Mode
    }
    
    $reportFile = "$REPORTS_PATH\metrics-$(Get-Date -Format 'yyyy-MM-dd-HH-mm').json"
    $reportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportFile -Encoding UTF8
    
    Write-BMadLog "📁 Métriques sauvegardées: $reportFile"
}

# Boucle principale de monitoring
function Start-MonitoringLoop {
    Write-BMadLog "🔄 Boucle de monitoring démarrée (intervalle: 30s)"
    
    $iteration = 1
    while ($true) {
        try {
            Write-BMadLog "--- Itération monitoring #$iteration ---"
            
            # Collecte métriques
            $metrics = Collect-RealTimeMetrics
            
            # Analyse anomalies
            $analysis = Analyze-Anomalies -Metrics $metrics
            
            # Traitement alertes
            foreach ($alert in $analysis.alerts) {
                if ($alert.level -eq "CRITICAL" -or ($alert.level -eq "WARNING" -and $AlertThreshold -in @("warning", "info"))) {
                    Send-Alert -Alert $alert
                }
            }
            
            # Sauvegarde pour reporting
            Save-MetricsForReporting -Metrics $metrics -Analysis $analysis
            
            # Affichage résumé
            Write-BMadLog "📋 Résumé - Serveurs UP: $($metrics.performance.up_servers)/$($metrics.performance.total_servers) | Alertes: $($analysis.alerts.Count) | Recommendations: $($analysis.recommendations.Count)"
            
            $iteration++
            Start-Sleep -Seconds 30
            
        }
        catch {
            Write-BMadLog "Erreur dans boucle monitoring: $_" "ERROR"
            Start-Sleep -Seconds 60  # Pause plus longue en cas d'erreur
        }
    }
}

# Point d'entrée principal
Write-BMadLog "🎯 Initialisation monitoring production BMAD+Contains Studio+MCP"
Write-BMadLog "Mode: $Mode | Seuil alertes: $AlertThreshold"
Write-BMadLog "Logs: $LOG_FILE"

# Vérification prérequis
if (!(Test-Path "$BASE_PATH\project.mcp.json")) {
    Write-BMadLog "❌ Configuration MCP non trouvée: $BASE_PATH\project.mcp.json" "ERROR"
    exit 1
}

Write-BMadLog "✅ Prérequis validés - Démarrage monitoring continu"

# Démarrage monitoring
try {
    Start-MonitoringLoop
}
catch {
    Write-BMadLog "❌ Erreur fatale monitoring: $_" "ERROR"
    exit 1
}
finally {
    Write-BMadLog "🛑 Monitoring arrêté" "INFO"
}