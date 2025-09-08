#Requires -Version 5.1
<#
.SYNOPSIS
    MCP Performance Analyzer - Analyse détaillée et comparaisons
.DESCRIPTION
    Outil spécialisé d'analyse performance pour infrastructure MCP avec:
    - Comparaisons avant/après déploiement
    - Détection anomalies automatique
    - Rapports HTML interactifs
    - Recommandations optimisation
    
.AUTHOR
    contains-eng-devops (BMAD harmonisé)
.VERSION  
    1.0.0 - Production Ready
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Analyze", "Compare", "Report", "Optimize")]
    [string]$Mode = "Analyze",
    
    [Parameter(Mandatory=$false)]
    [string]$BaselinePath,
    
    [Parameter(Mandatory=$false)] 
    [string]$ComparisonPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "logs\performance-reports",
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateHTML
)

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

$Script:Config = @{
    ProjectRoot = $PSScriptRoot | Split-Path -Parent
    BenchmarkPath = Join-Path $PSScriptRoot "..\logs\benchmarks"
    ReportsPath = Join-Path $PSScriptRoot "..\logs\performance-reports"
    
    # Seuils de performance critiques
    PerformanceThresholds = @{
        ConnectionLatency = @{ Good = 500; Warning = 1000; Critical = 2000 }    # ms
        ResponseTime = @{ Good = 2000; Warning = 5000; Critical = 10000 }       # ms
        MemoryUsage = @{ Good = 256; Warning = 512; Critical = 1024 }           # MB
        CPUUsage = @{ Good = 50; Warning = 80; Critical = 95 }                  # %
        DiskUsage = @{ Good = 70; Warning = 85; Critical = 95 }                 # %
    }
    
    # Poids importance serveurs pour scoring global
    ServerWeights = @{
        github = 1.0      # Critique
        firecrawl = 1.0   # Critique  
        postgres = 0.9    # High
        redis = 0.9       # High
        notion = 0.6      # Medium
        shadcn = 0.5      # Medium
        filesystem = 0.7  # Medium
        memory = 0.6      # Medium
    }
}

$Script:Colors = @{
    Excellent = "Green"
    Good = "DarkGreen" 
    Warning = "Yellow"
    Critical = "Red"
    Info = "Cyan"
    Header = "Magenta"
}

# ═══════════════════════════════════════════════════════════════════════════════
# UTILITAIRES
# ═══════════════════════════════════════════════════════════════════════════════

function Write-PerformanceOutput {
    param([string]$Message, [string]$Level = "Info", [switch]$NoNewline)
    
    $color = switch ($Level) {
        "Excellent" { $Script:Colors.Excellent }
        "Good" { $Script:Colors.Good }
        "Warning" { $Script:Colors.Warning }
        "Critical" { $Script:Colors.Critical }
        "Header" { $Script:Colors.Header }
        default { $Script:Colors.Info }
    }
    
    $params = @{
        Object = $Message
        ForegroundColor = $color
    }
    if ($NoNewline) { $params.NoNewline = $true }
    
    Write-Host @params
}

function Initialize-PerformanceDirectories {
    if (-not (Test-Path $Script:Config.ReportsPath)) {
        New-Item -Path $Script:Config.ReportsPath -ItemType Directory -Force | Out-Null
        Write-PerformanceOutput "✓ Créé répertoire rapports : $($Script:Config.ReportsPath)" "Good"
    }
}

function Get-PerformanceLevel {
    param([double]$Value, [hashtable]$Thresholds)
    
    if ($Value -le $Thresholds.Good) { return "Excellent" }
    elseif ($Value -le $Thresholds.Warning) { return "Good" }
    elseif ($Value -le $Thresholds.Critical) { return "Warning" }
    else { return "Critical" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# ANALYSE PERFORMANCE
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-PerformanceAnalysis {
    param([string]$BenchmarkFile)
    
    if (-not (Test-Path $BenchmarkFile)) {
        throw "Fichier benchmark introuvable : $BenchmarkFile"
    }
    
    Write-PerformanceOutput "🔍 Analyse performance : $BenchmarkFile" "Header"
    
    $benchmark = Get-Content $BenchmarkFile | ConvertFrom-Json
    $analysis = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Source = $BenchmarkFile
        Phase = $benchmark.Phase
        SystemAnalysis = Analyze-SystemPerformance -SystemMetrics $benchmark.SystemMetrics
        NetworkAnalysis = Analyze-NetworkPerformance -NetworkMetrics $benchmark.NetworkLatency  
        ProcessAnalysis = Analyze-ProcessPerformance -ProcessMetrics $benchmark.ProcessMetrics
        OverallScore = 0
        Recommendations = @()
    }
    
    # Calcul score global pondéré
    $systemScore = Get-ScoreFromLevel $analysis.SystemAnalysis.OverallLevel
    $networkScore = Get-ScoreFromLevel $analysis.NetworkAnalysis.OverallLevel  
    $processScore = Get-ScoreFromLevel $analysis.ProcessAnalysis.OverallLevel
    
    $analysis.OverallScore = [math]::Round(($systemScore * 0.4 + $networkScore * 0.3 + $processScore * 0.3), 1)
    $analysis.OverallLevel = Get-LevelFromScore $analysis.OverallScore
    
    # Génération recommandations
    $analysis.Recommendations = Generate-PerformanceRecommendations -Analysis $analysis
    
    return $analysis
}

function Analyze-SystemPerformance {
    param([hashtable]$SystemMetrics)
    
    $cpuLevel = Get-PerformanceLevel -Value $SystemMetrics.CPU.Usage -Thresholds $Script:Config.PerformanceThresholds.CPUUsage
    $memoryLevel = Get-PerformanceLevel -Value $SystemMetrics.Memory.UsagePercent -Thresholds $Script:Config.PerformanceThresholds.MemoryUsage
    
    # Analyse disques
    $diskAnalysis = @()
    $worstDiskLevel = "Excellent"
    
    foreach ($disk in $SystemMetrics.Disk) {
        $diskLevel = Get-PerformanceLevel -Value $disk.UsagePercent -Thresholds $Script:Config.PerformanceThresholds.DiskUsage
        $diskAnalysis += @{
            Drive = $disk.Drive
            Level = $diskLevel
            UsagePercent = $disk.UsagePercent
            FreeGB = $disk.FreeGB
        }
        
        if ((Get-ScoreFromLevel $diskLevel) < (Get-ScoreFromLevel $worstDiskLevel)) {
            $worstDiskLevel = $diskLevel
        }
    }
    
    # Niveau global système
    $systemScores = @(
        (Get-ScoreFromLevel $cpuLevel),
        (Get-ScoreFromLevel $memoryLevel),
        (Get-ScoreFromLevel $worstDiskLevel)
    )
    $avgSystemScore = ($systemScores | Measure-Object -Average).Average
    
    return @{
        CPU = @{ Level = $cpuLevel; Usage = $SystemMetrics.CPU.Usage; Cores = $SystemMetrics.CPU.Cores }
        Memory = @{ Level = $memoryLevel; Usage = $SystemMetrics.Memory.UsagePercent; FreeGB = $SystemMetrics.Memory.FreeGB }
        Disk = $diskAnalysis
        OverallLevel = Get-LevelFromScore $avgSystemScore
        OverallScore = [math]::Round($avgSystemScore, 1)
    }
}

function Analyze-NetworkPerformance {
    param([hashtable]$NetworkMetrics)
    
    $networkAnalysis = @{}
    $networkScores = @()
    
    foreach ($target in $NetworkMetrics.Keys) {
        $latency = $NetworkMetrics[$target]
        
        if ($latency -is [string]) {
            # Gestion cas "Unreachable" ou erreurs
            $level = "Critical"
            $score = 0
        } else {
            $level = Get-PerformanceLevel -Value $latency -Thresholds $Script:Config.PerformanceThresholds.ConnectionLatency
            $score = Get-ScoreFromLevel $level
        }
        
        $networkAnalysis[$target] = @{
            Latency = $latency
            Level = $level
            Score = $score
        }
        
        $networkScores += $score
    }
    
    $avgNetworkScore = if ($networkScores.Count -gt 0) { ($networkScores | Measure-Object -Average).Average } else { 0 }
    
    return @{
        Targets = $networkAnalysis
        OverallLevel = Get-LevelFromScore $avgNetworkScore
        OverallScore = [math]::Round($avgNetworkScore, 1)
    }
}

function Analyze-ProcessPerformance {
    param([hashtable]$ProcessMetrics)
    
    if ($ProcessMetrics.ProcessCount -eq 0) {
        return @{
            ProcessCount = 0
            MemoryUsage = 0
            OverallLevel = "Good"
            OverallScore = 8.0
            Message = "Aucun processus Node/NPX actif"
        }
    }
    
    # Analyse usage mémoire processus
    $memoryLevel = Get-PerformanceLevel -Value $ProcessMetrics.TotalMemoryMB -Thresholds $Script:Config.PerformanceThresholds.MemoryUsage
    
    # Analyse nombre de processus (trop = potentiel problème)
    $processCountLevel = if ($ProcessMetrics.ProcessCount -le 5) { "Excellent" }
                        elseif ($ProcessMetrics.ProcessCount -le 10) { "Good" }
                        elseif ($ProcessMetrics.ProcessCount -le 20) { "Warning" }
                        else { "Critical" }
    
    $overallScore = [math]::Round(((Get-ScoreFromLevel $memoryLevel) + (Get-ScoreFromLevel $processCountLevel)) / 2, 1)
    
    return @{
        ProcessCount = $ProcessMetrics.ProcessCount
        MemoryUsage = $ProcessMetrics.TotalMemoryMB
        MemoryLevel = $memoryLevel
        ProcessCountLevel = $processCountLevel  
        OverallLevel = Get-LevelFromScore $overallScore
        OverallScore = $overallScore
        Processes = $ProcessMetrics.Processes
    }
}

function Get-ScoreFromLevel {
    param([string]$Level)
    
    switch ($Level) {
        "Excellent" { return 10.0 }
        "Good" { return 7.5 }
        "Warning" { return 5.0 }
        "Critical" { return 2.5 }
        default { return 0.0 }
    }
}

function Get-LevelFromScore {
    param([double]$Score)
    
    if ($Score -ge 9.0) { return "Excellent" }
    elseif ($Score -ge 7.0) { return "Good" }
    elseif ($Score -ge 4.0) { return "Warning" }
    else { return "Critical" }
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMPARAISONS PERFORMANCE
# ═══════════════════════════════════════════════════════════════════════════════

function Compare-PerformanceBenchmarks {
    param([string]$BaselinePath, [string]$ComparisonPath)
    
    Write-PerformanceOutput "📊 Comparaison benchmarks" "Header"
    Write-PerformanceOutput "  Baseline : $BaselinePath" "Info"
    Write-PerformanceOutput "  Comparé  : $ComparisonPath" "Info"
    
    $baseline = Invoke-PerformanceAnalysis -BenchmarkFile $BaselinePath
    $comparison = Invoke-PerformanceAnalysis -BenchmarkFile $ComparisonPath
    
    $comparisonResult = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        BaselineFile = $BaselinePath
        ComparisonFile = $ComparisonPath
        BaselineAnalysis = $baseline
        ComparisonAnalysis = $comparison
        Deltas = Calculate-PerformanceDeltas -Baseline $baseline -Comparison $comparison
        Summary = @{
            OverallImprovement = $comparison.OverallScore - $baseline.OverallScore
            SystemImprovement = $comparison.SystemAnalysis.OverallScore - $baseline.SystemAnalysis.OverallScore  
            NetworkImprovement = $comparison.NetworkAnalysis.OverallScore - $baseline.NetworkAnalysis.OverallScore
            ProcessImprovement = $comparison.ProcessAnalysis.OverallScore - $baseline.ProcessAnalysis.OverallScore
        }
    }
    
    return $comparisonResult
}

function Calculate-PerformanceDeltas {
    param([hashtable]$Baseline, [hashtable]$Comparison)
    
    return @{
        System = @{
            CPU = @{
                Delta = $Comparison.SystemAnalysis.CPU.Usage - $Baseline.SystemAnalysis.CPU.Usage
                Direction = if ($Comparison.SystemAnalysis.CPU.Usage -lt $Baseline.SystemAnalysis.CPU.Usage) { "Improved" } else { "Degraded" }
            }
            Memory = @{
                Delta = $Comparison.SystemAnalysis.Memory.Usage - $Baseline.SystemAnalysis.Memory.Usage
                Direction = if ($Comparison.SystemAnalysis.Memory.Usage -lt $Baseline.SystemAnalysis.Memory.Usage) { "Improved" } else { "Degraded" }
            }
        }
        Network = Calculate-NetworkDeltas -BaselineNetwork $Baseline.NetworkAnalysis.Targets -ComparisonNetwork $Comparison.NetworkAnalysis.Targets
        Process = @{
            MemoryDelta = $Comparison.ProcessAnalysis.MemoryUsage - $Baseline.ProcessAnalysis.MemoryUsage
            ProcessCountDelta = $Comparison.ProcessAnalysis.ProcessCount - $Baseline.ProcessAnalysis.ProcessCount
        }
    }
}

function Calculate-NetworkDeltas {
    param([hashtable]$BaselineNetwork, [hashtable]$ComparisonNetwork)
    
    $networkDeltas = @{}
    
    foreach ($target in $BaselineNetwork.Keys) {
        if ($ComparisonNetwork.ContainsKey($target)) {
            $baseLatency = $BaselineNetwork[$target].Latency
            $compLatency = $ComparisonNetwork[$target].Latency
            
            if ($baseLatency -is [double] -and $compLatency -is [double]) {
                $delta = $compLatency - $baseLatency
                $networkDeltas[$target] = @{
                    Delta = $delta
                    Direction = if ($delta -lt 0) { "Improved" } else { "Degraded" }
                    PercentChange = if ($baseLatency -gt 0) { [math]::Round(($delta / $baseLatency) * 100, 1) } else { 0 }
                }
            }
        }
    }
    
    return $networkDeltas
}

# ═══════════════════════════════════════════════════════════════════════════════
# GÉNÉRATION RECOMMANDATIONS
# ═══════════════════════════════════════════════════════════════════════════════

function Generate-PerformanceRecommendations {
    param([hashtable]$Analysis)
    
    $recommendations = @()
    
    # Recommandations système
    if ($Analysis.SystemAnalysis.CPU.Level -in @("Warning", "Critical")) {
        $recommendations += @{
            Priority = "High"
            Category = "System"
            Issue = "CPU usage élevé ($($Analysis.SystemAnalysis.CPU.Usage)%)"
            Recommendation = "Réduire charge CPU : arrêter processus inutiles, optimiser scripts NPX"
            Impact = "Performance générale dégradée"
        }
    }
    
    if ($Analysis.SystemAnalysis.Memory.Level -in @("Warning", "Critical")) {
        $recommendations += @{
            Priority = "High" 
            Category = "System"
            Issue = "Mémoire insuffisante ($($Analysis.SystemAnalysis.Memory.Usage)%)"
            Recommendation = "Libérer mémoire : fermer applications, augmenter RAM si possible"
            Impact = "Risque swap disque, lenteurs MCP"
        }
    }
    
    # Recommandations réseau
    foreach ($target in $Analysis.NetworkAnalysis.Targets.Keys) {
        $networkTarget = $Analysis.NetworkAnalysis.Targets[$target]
        if ($networkTarget.Level -in @("Warning", "Critical")) {
            $recommendations += @{
                Priority = "Medium"
                Category = "Network"
                Issue = "Latence élevée $target ($($networkTarget.Latency)ms)"
                Recommendation = "Vérifier connectivité réseau, DNS, firewall"
                Impact = "Lenteurs serveurs MCP externes"
            }
        }
    }
    
    # Recommandations processus
    if ($Analysis.ProcessAnalysis.ProcessCountLevel -in @("Warning", "Critical")) {
        $recommendations += @{
            Priority = "Medium"
            Category = "Process"
            Issue = "Trop de processus Node/NPX actifs ($($Analysis.ProcessAnalysis.ProcessCount))"
            Recommendation = "Identifier et arrêter processus NPX orphelins"
            Impact = "Consommation ressources excessive"
        }
    }
    
    # Recommandations globales selon score
    if ($Analysis.OverallScore -lt 5.0) {
        $recommendations += @{
            Priority = "Critical"
            Category = "Global"
            Issue = "Performance infrastructure critique (score: $($Analysis.OverallScore)/10)"
            Recommendation = "Audit complet infrastructure, redémarrage services"
            Impact = "Fonctionnement MCP compromis"
        }
    }
    
    return $recommendations
}

# ═══════════════════════════════════════════════════════════════════════════════
# RAPPORTS & VISUALISATION
# ═══════════════════════════════════════════════════════════════════════════════

function Generate-PerformanceReport {
    param([hashtable]$Analysis, [string]$OutputFile, [switch]$HTML)
    
    Write-PerformanceOutput "📄 Génération rapport : $OutputFile" "Info"
    
    if ($HTML) {
        $htmlReport = Generate-HTMLReport -Analysis $Analysis
        $htmlReport | Set-Content -Path "$OutputFile.html" -Encoding UTF8
        Write-PerformanceOutput "✓ Rapport HTML généré : $OutputFile.html" "Good"
    }
    
    # Rapport JSON structuré
    $Analysis | ConvertTo-Json -Depth 8 | Set-Content -Path "$OutputFile.json" -Encoding UTF8
    Write-PerformanceOutput "✓ Rapport JSON généré : $OutputFile.json" "Good"
    
    # Rapport texte résumé
    $textReport = Generate-TextSummary -Analysis $Analysis
    $textReport | Set-Content -Path "$OutputFile.txt" -Encoding UTF8  
    Write-PerformanceOutput "✓ Résumé texte généré : $OutputFile.txt" "Good"
}

function Generate-HTMLReport {
    param([hashtable]$Analysis)
    
    $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MCP Performance Analysis Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 8px 8px 0 0; }
        .header h1 { margin: 0; font-size: 2.5em; }
        .header p { margin: 10px 0 0; opacity: 0.9; font-size: 1.1em; }
        .content { padding: 30px; }
        .score-section { text-align: center; margin: 30px 0; }
        .score-circle { display: inline-block; width: 150px; height: 150px; border-radius: 50%; line-height: 150px; font-size: 3em; font-weight: bold; color: white; margin: 20px; }
        .score-excellent { background: linear-gradient(135deg, #4CAF50, #45a049); }
        .score-good { background: linear-gradient(135deg, #8BC34A, #689F38); }
        .score-warning { background: linear-gradient(135deg, #FF9800, #F57C00); }
        .score-critical { background: linear-gradient(135deg, #F44336, #D32F2F); }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 30px 0; }
        .metric-card { background: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; border-radius: 5px; }
        .metric-card h3 { margin-top: 0; color: #333; }
        .level-excellent { color: #4CAF50; font-weight: bold; }
        .level-good { color: #8BC34A; font-weight: bold; }
        .level-warning { color: #FF9800; font-weight: bold; }
        .level-critical { color: #F44336; font-weight: bold; }
        .recommendations { margin: 30px 0; }
        .recommendation { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .recommendation.high { background: #f8d7da; border-color: #f5c6cb; }
        .recommendation.critical { background: #d1ecf1; border-color: #bee5eb; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; font-weight: bold; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 0.9em; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔧 MCP Performance Analysis</h1>
            <p>Infrastructure Validation Report - contains-eng-devops</p>
            <p>Généré le : $($Analysis.Timestamp) | Phase : $($Analysis.Phase)</p>
        </div>
        
        <div class="content">
            <div class="score-section">
                <h2>Score Global Performance</h2>
                <div class="score-circle score-$(($Analysis.OverallLevel).ToLower())">
                    $($Analysis.OverallScore)/10
                </div>
                <p><strong>Niveau : </strong><span class="level-$(($Analysis.OverallLevel).ToLower())">$($Analysis.OverallLevel)</span></p>
            </div>
            
            <div class="metrics-grid">
                <div class="metric-card">
                    <h3>💻 Système</h3>
                    <p><strong>Score :</strong> $($Analysis.SystemAnalysis.OverallScore)/10</p>
                    <p><strong>CPU :</strong> $($Analysis.SystemAnalysis.CPU.Usage)% <span class="level-$(($Analysis.SystemAnalysis.CPU.Level).ToLower())">($($Analysis.SystemAnalysis.CPU.Level))</span></p>
                    <p><strong>Mémoire :</strong> $($Analysis.SystemAnalysis.Memory.Usage)% <span class="level-$(($Analysis.SystemAnalysis.Memory.Level).ToLower())">($($Analysis.SystemAnalysis.Memory.Level))</span></p>
                </div>
                
                <div class="metric-card">
                    <h3>🌐 Réseau</h3>
                    <p><strong>Score :</strong> $($Analysis.NetworkAnalysis.OverallScore)/10</p>
"@

    # Ajout détails réseau
    foreach ($target in $Analysis.NetworkAnalysis.Targets.Keys) {
        $networkTarget = $Analysis.NetworkAnalysis.Targets[$target]
        $html += "<p><strong>$target :</strong> $($networkTarget.Latency)ms <span class=`"level-$(($networkTarget.Level).ToLower())`">($($networkTarget.Level))</span></p>`n"
    }

    $html += @"
                </div>
                
                <div class="metric-card">
                    <h3>⚙️ Processus</h3>
                    <p><strong>Score :</strong> $($Analysis.ProcessAnalysis.OverallScore)/10</p>
                    <p><strong>Processus actifs :</strong> $($Analysis.ProcessAnalysis.ProcessCount)</p>
                    <p><strong>Mémoire totale :</strong> $($Analysis.ProcessAnalysis.MemoryUsage) MB</p>
                </div>
            </div>
"@

    # Ajout recommandations si présentes
    if ($Analysis.Recommendations.Count -gt 0) {
        $html += "<div class='recommendations'><h2>💡 Recommandations</h2>"
        
        foreach ($rec in $Analysis.Recommendations) {
            $priorityClass = ($rec.Priority).ToLower()
            $html += @"
            <div class="recommendation $priorityClass">
                <h4>[$($rec.Priority)] $($rec.Category) - $($rec.Issue)</h4>
                <p><strong>Recommandation :</strong> $($rec.Recommendation)</p>
                <p><strong>Impact :</strong> $($rec.Impact)</p>
            </div>
"@
        }
        
        $html += "</div>"
    }

    $html += @"
        </div>
        
        <div class="footer">
            <p>Généré par contains-eng-devops | BMAD Infrastructure Automation</p>
            <p>Coordination avec bmad-parallel-orchestrator et bmad-qa</p>
        </div>
    </div>
</body>
</html>
"@

    return $html
}

function Generate-TextSummary {
    param([hashtable]$Analysis)
    
    $summary = @"
═══════════════════════════════════════════════════════════════════
MCP PERFORMANCE ANALYSIS SUMMARY
contains-eng-devops | BMAD Infrastructure Automation
═══════════════════════════════════════════════════════════════════

RAPPORT GÉNÉRÉ : $($Analysis.Timestamp)
PHASE ANALYSÉE : $($Analysis.Phase)
SOURCE : $($Analysis.Source)

SCORE GLOBAL : $($Analysis.OverallScore)/10 ($($Analysis.OverallLevel))

DÉTAIL PERFORMANCES :
├─ 💻 SYSTÈME : $($Analysis.SystemAnalysis.OverallScore)/10 ($($Analysis.SystemAnalysis.OverallLevel))
│  ├─ CPU : $($Analysis.SystemAnalysis.CPU.Usage)% ($($Analysis.SystemAnalysis.CPU.Level))
│  ├─ Mémoire : $($Analysis.SystemAnalysis.Memory.Usage)% ($($Analysis.SystemAnalysis.Memory.Level))
│  └─ Disques : 
"@

    foreach ($disk in $Analysis.SystemAnalysis.Disk) {
        $summary += "│      $($disk.Drive) : $($disk.UsagePercent)% ($($disk.Level))`n"
    }

    $summary += @"
├─ 🌐 RÉSEAU : $($Analysis.NetworkAnalysis.OverallScore)/10 ($($Analysis.NetworkAnalysis.OverallLevel))
"@

    foreach ($target in $Analysis.NetworkAnalysis.Targets.Keys) {
        $networkTarget = $Analysis.NetworkAnalysis.Targets[$target]
        $summary += "│  ├─ $target : $($networkTarget.Latency)ms ($($networkTarget.Level))`n"
    }

    $summary += @"
└─ ⚙️ PROCESSUS : $($Analysis.ProcessAnalysis.OverallScore)/10 ($($Analysis.ProcessAnalysis.OverallLevel))
   ├─ Processus actifs : $($Analysis.ProcessAnalysis.ProcessCount)
   └─ Mémoire totale : $($Analysis.ProcessAnalysis.MemoryUsage) MB

RECOMMANDATIONS ($($Analysis.Recommendations.Count)) :
"@

    for ($i = 0; $i -lt $Analysis.Recommendations.Count; $i++) {
        $rec = $Analysis.Recommendations[$i]
        $summary += @"
[$($i + 1)] [$($rec.Priority)] $($rec.Category)
    Problème : $($rec.Issue)
    Solution : $($rec.Recommendation)
    Impact : $($rec.Impact)

"@
    }

    $summary += @"
═══════════════════════════════════════════════════════════════════
Coordination BMAD active - hooks/bmad-coordination-events.json
Monitoring continu recommandé pour production
═══════════════════════════════════════════════════════════════════
"@

    return $summary
}

function Show-AnalysisSummary {
    param([hashtable]$Analysis)
    
    Write-PerformanceOutput "`n═══════════════════════════════════════════════════════════════════" "Header"
    Write-PerformanceOutput "📊 ANALYSE PERFORMANCE MCP - RÉSUMÉ" "Header"  
    Write-PerformanceOutput "═══════════════════════════════════════════════════════════════════" "Header"
    
    Write-PerformanceOutput "`n🎯 SCORE GLOBAL : $($Analysis.OverallScore)/10" "Info"
    Write-PerformanceOutput "   Niveau : $($Analysis.OverallLevel)" $Analysis.OverallLevel
    
    Write-PerformanceOutput "`n📈 DÉTAIL PERFORMANCES :" "Info"
    Write-PerformanceOutput "  💻 Système : $($Analysis.SystemAnalysis.OverallScore)/10 ($($Analysis.SystemAnalysis.OverallLevel))" $Analysis.SystemAnalysis.OverallLevel
    Write-PerformanceOutput "     CPU: $($Analysis.SystemAnalysis.CPU.Usage)% ($($Analysis.SystemAnalysis.CPU.Level))" $Analysis.SystemAnalysis.CPU.Level
    Write-PerformanceOutput "     RAM: $($Analysis.SystemAnalysis.Memory.Usage)% ($($Analysis.SystemAnalysis.Memory.Level))" $Analysis.SystemAnalysis.Memory.Level
    
    Write-PerformanceOutput "  🌐 Réseau : $($Analysis.NetworkAnalysis.OverallScore)/10 ($($Analysis.NetworkAnalysis.OverallLevel))" $Analysis.NetworkAnalysis.OverallLevel
    foreach ($target in $Analysis.NetworkAnalysis.Targets.Keys) {
        $net = $Analysis.NetworkAnalysis.Targets[$target]
        Write-PerformanceOutput "     $target`: $($net.Latency)ms ($($net.Level))" $net.Level
    }
    
    Write-PerformanceOutput "  ⚙️ Processus : $($Analysis.ProcessAnalysis.OverallScore)/10 ($($Analysis.ProcessAnalysis.OverallLevel))" $Analysis.ProcessAnalysis.OverallLevel
    Write-PerformanceOutput "     Actifs: $($Analysis.ProcessAnalysis.ProcessCount) | Mémoire: $($Analysis.ProcessAnalysis.MemoryUsage)MB" "Info"
    
    if ($Analysis.Recommendations.Count -gt 0) {
        Write-PerformanceOutput "`n💡 RECOMMANDATIONS ($($Analysis.Recommendations.Count)) :" "Info"
        foreach ($rec in $Analysis.Recommendations) {
            $level = switch ($rec.Priority) {
                "Critical" { "Critical" }
                "High" { "Warning" }
                default { "Info" }
            }
            Write-PerformanceOutput "  [$($rec.Priority)] $($rec.Issue)" $level
            Write-PerformanceOutput "     → $($rec.Recommendation)" "Info"
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTERFACE PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════════

function Main {
    try {
        Write-PerformanceOutput "🔧 MCP Performance Analyzer - contains-eng-devops" "Header"
        Write-PerformanceOutput "Mode: $Mode" "Info"
        
        Initialize-PerformanceDirectories
        
        switch ($Mode) {
            "Analyze" {
                if (-not $BaselinePath) {
                    # Recherche du benchmark le plus récent
                    $latestBenchmark = Get-ChildItem -Path $Script:Config.BenchmarkPath -Filter "benchmark-*.json" | 
                                     Sort-Object LastWriteTime -Descending | 
                                     Select-Object -First 1
                    
                    if (-not $latestBenchmark) {
                        throw "Aucun benchmark trouvé dans $($Script:Config.BenchmarkPath)"
                    }
                    
                    $BaselinePath = $latestBenchmark.FullName
                    Write-PerformanceOutput "📁 Benchmark détecté automatiquement : $BaselinePath" "Info"
                }
                
                $analysis = Invoke-PerformanceAnalysis -BenchmarkFile $BaselinePath
                Show-AnalysisSummary -Analysis $analysis
                
                $reportPath = Join-Path $Script:Config.ReportsPath "performance-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Generate-PerformanceReport -Analysis $analysis -OutputFile $reportPath -HTML:$GenerateHTML
            }
            
            "Compare" {
                if (-not $BaselinePath -or -not $ComparisonPath) {
                    throw "Mode Compare nécessite -BaselinePath et -ComparisonPath"
                }
                
                $comparison = Compare-PerformanceBenchmarks -BaselinePath $BaselinePath -ComparisonPath $ComparisonPath
                
                Write-PerformanceOutput "`n📊 COMPARAISON BENCHMARKS" "Header"
                Write-PerformanceOutput "Amélioration globale : $($comparison.Summary.OverallImprovement)" $(if ($comparison.Summary.OverallImprovement -gt 0) { "Good" } else { "Warning" })
                
                $reportPath = Join-Path $Script:Config.ReportsPath "performance-comparison-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                $comparison | ConvertTo-Json -Depth 10 | Set-Content -Path "$reportPath.json"
                Write-PerformanceOutput "✓ Rapport comparaison sauvegardé : $reportPath.json" "Good"
            }
            
            "Report" {
                Write-PerformanceOutput "📄 Génération rapports de tous les benchmarks..." "Info"
                
                $benchmarks = Get-ChildItem -Path $Script:Config.BenchmarkPath -Filter "benchmark-*.json"
                foreach ($benchmark in $benchmarks) {
                    $analysis = Invoke-PerformanceAnalysis -BenchmarkFile $benchmark.FullName
                    $reportName = "report-$($benchmark.BaseName)"
                    $reportPath = Join-Path $Script:Config.ReportsPath $reportName
                    Generate-PerformanceReport -Analysis $analysis -OutputFile $reportPath -HTML:$GenerateHTML
                }
                
                Write-PerformanceOutput "✅ $($benchmarks.Count) rapports générés dans $($Script:Config.ReportsPath)" "Good"
            }
            
            "Optimize" {
                Write-PerformanceOutput "⚡ Mode optimisation - Analyse + recommandations avancées..." "Info"
                # Mode futur pour suggestions d'optimisation automatiques
                Write-PerformanceOutput "Mode en développement - utiliser 'Analyze' pour recommandations actuelles" "Warning"
            }
        }
        
        Write-PerformanceOutput "`n✅ Analyse performance terminée avec succès!" "Good"
        
    } catch {
        Write-PerformanceOutput "❌ ERREUR: $($_.Exception.Message)" "Critical"
        exit 1
    }
}

# Exécution si script appelé directement
if ($MyInvocation.InvocationName -ne '.') {
    Main
}