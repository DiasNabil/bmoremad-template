#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Real-time Alerting System - BMAD+Contains Studio+MCP Ecosystem
.DESCRIPTION
    Advanced alerting system with:
    - Intelligent threshold management
    - Multi-channel notifications (Slack, Teams, Email, SMS)
    - Predictive alerting based on trends
    - Alert correlation and deduplication
    - Automated escalation procedures
.AUTHOR
    Contains Test Performance Agent - Production Observability
.VERSION
    1.0.0 - Enterprise Grade
#>

param(
    [string]$ConfigPath = ".\config\alerting-config.json",
    [string]$LogPath = ".\logs\observability\alerts",
    [switch]$EnablePredictiveAlerting = $true,
    [switch]$EnableAlertCorrelation = $true,
    [int]$AlertingInterval = 15,
    [string]$NotificationChannels = "slack,email"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Advanced alerting configuration
$script:AlertingConfig = @{
    Channels = @{
        Slack = @{
            WebhookUrl = $env:SLACK_WEBHOOK_URL
            DefaultChannel = "#bmad-alerts"
            CriticalChannel = "#bmad-critical"
            Enabled = $true
        }
        Teams = @{
            WebhookUrl = $env:TEAMS_WEBHOOK_URL
            Enabled = $false
        }
        Email = @{
            SMTPServer = $env:SMTP_SERVER
            From = $env:ALERT_FROM_EMAIL
            To = @($env:ALERT_TO_EMAILS -split ",")
            Enabled = $true
        }
        PagerDuty = @{
            IntegrationKey = $env:PAGERDUTY_KEY
            Enabled = $false
        }
    }
    
    ThresholdProfiles = @{
        Production = @{
            Critical = @{
                AgentLatency = 3000          # ms
                MCPResponseTime = 1500       # ms
                ErrorRate = 3                # %
                CPUUtilization = 85          # %
                MemoryUtilization = 80       # %
                DiskUtilization = 90         # %
                NetworkLatency = 200         # ms
                SecurityViolations = 1       # count
            }
            Warning = @{
                AgentLatency = 2000          # ms
                MCPResponseTime = 1000       # ms
                ErrorRate = 1                # %
                CPUUtilization = 70          # %
                MemoryUtilization = 65       # %
                DiskUtilization = 80         # %
                NetworkLatency = 150         # ms
            }
        }
        
        Development = @{
            Critical = @{
                AgentLatency = 5000
                MCPResponseTime = 3000
                ErrorRate = 10
                CPUUtilization = 95
                MemoryUtilization = 90
            }
            Warning = @{
                AgentLatency = 3000
                MCPResponseTime = 2000
                ErrorRate = 5
                CPUUtilization = 80
                MemoryUtilization = 75
            }
        }
    }
    
    EscalationRules = @{
        Level1 = @{ TimeMinutes = 5; Recipients = @("team-leads") }
        Level2 = @{ TimeMinutes = 15; Recipients = @("team-leads", "managers") }
        Level3 = @{ TimeMinutes = 30; Recipients = @("team-leads", "managers", "directors") }
        Level4 = @{ TimeMinutes = 60; Recipients = @("team-leads", "managers", "directors", "executives") }
    }
    
    AlertCorrelation = @{
        TimeWindow = 300          # seconds
        SimilarityThreshold = 0.8 # correlation coefficient
        MaxCorrelatedAlerts = 10
    }
    
    PredictiveSettings = @{
        TimeWindow = 1800         # seconds (30 minutes)
        TrendAnalysisPoints = 20
        PredictionConfidence = 0.75
        LeadTime = 300           # seconds (5 minutes warning)
    }
}

function Initialize-AlertingSystem {
    Write-Host "🚨 Initializing Real-time Alerting System..." -ForegroundColor Red
    
    # Create directory structure
    $dirs = @(
        "$LogPath\active", 
        "$LogPath\resolved", 
        "$LogPath\escalated",
        "$LogPath\predictive"
    )
    
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    # Initialize alert state tracking
    $script:AlertState = @{
        ActiveAlerts = @{}
        AlertHistory = @()
        EscalationTimers = @{}
        CorrelationGroups = @{}
        PredictiveModels = @{}
    }
    
    # Load existing alert state if available
    $stateFile = "$LogPath\alert-state.json"
    if (Test-Path $stateFile) {
        try {
            $savedState = Get-Content $stateFile | ConvertFrom-Json
            $script:AlertState = $savedState
            Write-Host "📂 Loaded existing alert state" -ForegroundColor Yellow
        } catch {
            Write-Warning "Could not load alert state: $($_.Exception.Message)"
        }
    }
    
    Write-Host "✅ Alerting system initialized" -ForegroundColor Green
}

function Invoke-RealTimeMonitoring {
    Write-Host "🔍 Starting real-time monitoring with alerting..." -ForegroundColor Cyan
    
    while ($true) {
        try {
            # Collect current metrics
            $metrics = Get-CurrentSystemMetrics
            
            # Analyze for alerts
            $newAlerts = Test-AllThresholds -Metrics $metrics
            
            # Process predictive alerting
            if ($EnablePredictiveAlerting) {
                $predictiveAlerts = Get-PredictiveAlerts -Metrics $metrics
                $newAlerts += $predictiveAlerts
            }
            
            # Process alert correlation
            if ($EnableAlertCorrelation) {
                $newAlerts = Invoke-AlertCorrelation -Alerts $newAlerts
            }
            
            # Process each new alert
            foreach ($alert in $newAlerts) {
                Process-Alert -Alert $alert
            }
            
            # Check for escalations
            Check-AlertEscalations
            
            # Check for auto-resolved alerts
            Check-AutoResolution -Metrics $metrics
            
            # Save alert state
            Save-AlertState
            
            # Status update
            $activeCount = $script:AlertState.ActiveAlerts.Count
            Write-Host "🔔 Monitoring cycle completed - $activeCount active alerts" -ForegroundColor Gray
            
            Start-Sleep -Seconds $AlertingInterval
            
        } catch {
            Write-Error "❌ Monitoring cycle failed: $($_.Exception.Message)"
            Start-Sleep -Seconds 30 # Wait longer on error
        }
    }
}

function Get-CurrentSystemMetrics {
    # This would integrate with your actual monitoring system
    return @{
        Timestamp = Get-Date
        Agents = Get-AgentMetrics
        MCPServers = Get-MCPMetrics
        Infrastructure = Get-InfrastructureMetrics
        Security = Get-SecurityMetrics
    }
}

function Get-AgentMetrics {
    $agentMetrics = @{}
    
    # Simulate agent metrics collection
    $agents = @(
        "bmad-orchestrator", "contains-test-performance", "contains-eng-backend",
        "contains-design-ui", "bmad-security", "contains-test-api"
    )
    
    foreach ($agent in $agents) {
        $agentMetrics[$agent] = @{
            Latency = Get-Random -Minimum 100 -Maximum 4000
            ErrorRate = Get-Random -Minimum 0 -Maximum 8
            CPUUsage = Get-Random -Minimum 20 -Maximum 90
            MemoryUsage = Get-Random -Minimum 30 -Maximum 85
            Status = if ((Get-Random -Minimum 1 -Maximum 100) -gt 95) { "Error" } else { "Active" }
        }
    }
    
    return $agentMetrics
}

function Get-MCPMetrics {
    $mcpMetrics = @{}
    
    $servers = @("github", "postgres", "redis", "notion", "firecrawl")
    
    foreach ($server in $servers) {
        $mcpMetrics[$server] = @{
            ResponseTime = Get-Random -Minimum 50 -Maximum 2500
            ErrorRate = Get-Random -Minimum 0 -Maximum 5
            Throughput = Get-Random -Minimum 100 -Maximum 1000
            ConnectionPool = @{
                Active = Get-Random -Minimum 5 -Maximum 45
                Idle = Get-Random -Minimum 0 -Maximum 20
                Max = 50
            }
            Status = if ((Get-Random -Minimum 1 -Maximum 100) -gt 97) { "Down" } else { "Up" }
        }
    }
    
    return $mcpMetrics
}

function Get-InfrastructureMetrics {
    return @{
        CPU = @{
            Total = Get-Random -Minimum 30 -Maximum 95
            PerCore = @((1..8) | ForEach-Object { Get-Random -Minimum 20 -Maximum 90 })
        }
        Memory = @{
            Used = Get-Random -Minimum 40 -Maximum 85
            Available = Get-Random -Minimum 15 -Maximum 60
            Cached = Get-Random -Minimum 10 -Maximum 30
        }
        Disk = @{
            Usage = Get-Random -Minimum 50 -Maximum 95
            IOLatency = Get-Random -Minimum 1 -Maximum 50
            IOPS = Get-Random -Minimum 100 -Maximum 5000
        }
        Network = @{
            Latency = Get-Random -Minimum 10 -Maximum 300
            Throughput = Get-Random -Minimum 100 -Maximum 1000
            PacketLoss = Get-Random -Minimum 0 -Maximum 3
        }
    }
}

function Get-SecurityMetrics {
    return @{
        AuthenticationFailures = Get-Random -Minimum 0 -Maximum 10
        UnauthorizedAccess = Get-Random -Minimum 0 -Maximum 2
        SecurityViolations = Get-Random -Minimum 0 -Maximum 3
        ComplianceScore = Get-Random -Minimum 95 -Maximum 100
    }
}

function Test-AllThresholds {
    param($Metrics)
    
    $alerts = @()
    $thresholds = $script:AlertingConfig.ThresholdProfiles.Production
    
    # Test agent metrics
    foreach ($agentName in $Metrics.Agents.Keys) {
        $agent = $Metrics.Agents[$agentName]
        
        # Latency alerts
        if ($agent.Latency -gt $thresholds.Critical.AgentLatency) {
            $alerts += New-Alert -Type "Critical" -Component "Agent" -SubComponent $agentName -Metric "Latency" -Value $agent.Latency -Threshold $thresholds.Critical.AgentLatency
        } elseif ($agent.Latency -gt $thresholds.Warning.AgentLatency) {
            $alerts += New-Alert -Type "Warning" -Component "Agent" -SubComponent $agentName -Metric "Latency" -Value $agent.Latency -Threshold $thresholds.Warning.AgentLatency
        }
        
        # Error rate alerts
        if ($agent.ErrorRate -gt $thresholds.Critical.ErrorRate) {
            $alerts += New-Alert -Type "Critical" -Component "Agent" -SubComponent $agentName -Metric "ErrorRate" -Value $agent.ErrorRate -Threshold $thresholds.Critical.ErrorRate
        }
        
        # Resource alerts
        if ($agent.CPUUsage -gt $thresholds.Critical.CPUUtilization) {
            $alerts += New-Alert -Type "Critical" -Component "Agent" -SubComponent $agentName -Metric "CPU" -Value $agent.CPUUsage -Threshold $thresholds.Critical.CPUUtilization
        }
    }
    
    # Test MCP server metrics
    foreach ($serverName in $Metrics.MCPServers.Keys) {
        $server = $Metrics.MCPServers[$serverName]
        
        if ($server.ResponseTime -gt $thresholds.Critical.MCPResponseTime) {
            $alerts += New-Alert -Type "Critical" -Component "MCP" -SubComponent $serverName -Metric "ResponseTime" -Value $server.ResponseTime -Threshold $thresholds.Critical.MCPResponseTime
        }
        
        if ($server.Status -eq "Down") {
            $alerts += New-Alert -Type "Critical" -Component "MCP" -SubComponent $serverName -Metric "Status" -Value "Down" -Threshold "Up"
        }
    }
    
    # Test infrastructure metrics
    $infra = $Metrics.Infrastructure
    if ($infra.CPU.Total -gt $thresholds.Critical.CPUUtilization) {
        $alerts += New-Alert -Type "Critical" -Component "Infrastructure" -SubComponent "CPU" -Metric "Utilization" -Value $infra.CPU.Total -Threshold $thresholds.Critical.CPUUtilization
    }
    
    if ($infra.Memory.Used -gt $thresholds.Critical.MemoryUtilization) {
        $alerts += New-Alert -Type "Critical" -Component "Infrastructure" -SubComponent "Memory" -Metric "Utilization" -Value $infra.Memory.Used -Threshold $thresholds.Critical.MemoryUtilization
    }
    
    return $alerts
}

function New-Alert {
    param(
        [string]$Type,
        [string]$Component,
        [string]$SubComponent,
        [string]$Metric,
        $Value,
        $Threshold
    )
    
    $alertId = [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
    
    return @{
        Id = $alertId
        Type = $Type
        Component = $Component
        SubComponent = $SubComponent
        Metric = $Metric
        Value = $Value
        Threshold = $Threshold
        Timestamp = Get-Date
        Status = "New"
        Message = "$(Component) $SubComponent $Metric ($Value) exceeded $Type threshold ($Threshold)"
        Hash = Get-AlertHash -Component $Component -SubComponent $SubComponent -Metric $Metric
    }
}

function Get-AlertHash {
    param($Component, $SubComponent, $Metric)
    
    $hashString = "$Component-$SubComponent-$Metric"
    return $hashString.GetHashCode()
}

function Get-PredictiveAlerts {
    param($Metrics)
    
    $predictiveAlerts = @()
    
    # Analyze trends for each metric
    foreach ($agentName in $Metrics.Agents.Keys) {
        $agent = $Metrics.Agents[$agentName]
        
        # Get historical data for trend analysis
        $historicalData = Get-HistoricalMetrics -Component "Agent" -SubComponent $agentName -Metric "Latency"
        
        if ($historicalData.Count -gt 10) {
            $trend = Calculate-Trend -Data $historicalData
            $prediction = Predict-FutureValue -Data $historicalData -Trend $trend -LeadTimeSeconds $script:AlertingConfig.PredictiveSettings.LeadTime
            
            if ($prediction.Confidence -gt $script:AlertingConfig.PredictiveSettings.PredictionConfidence) {
                $threshold = $script:AlertingConfig.ThresholdProfiles.Production.Critical.AgentLatency
                
                if ($prediction.Value -gt $threshold) {
                    $predictiveAlerts += @{
                        Id = [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
                        Type = "Predictive"
                        Component = "Agent"
                        SubComponent = $agentName
                        Metric = "Latency"
                        CurrentValue = $agent.Latency
                        PredictedValue = $prediction.Value
                        Threshold = $threshold
                        Confidence = $prediction.Confidence
                        ETA = (Get-Date).AddSeconds($script:AlertingConfig.PredictiveSettings.LeadTime)
                        Timestamp = Get-Date
                        Status = "Predicted"
                        Message = "Predictive alert: $agentName latency trending to exceed threshold in $($script:AlertingConfig.PredictiveSettings.LeadTime) seconds"
                    }
                }
            }
        }
    }
    
    return $predictiveAlerts
}

function Calculate-Trend {
    param($Data)
    
    if ($Data.Count -lt 2) { return 0 }
    
    # Simple linear regression for trend
    $n = $Data.Count
    $x = 0..($n-1)
    $y = $Data
    
    $sumX = ($x | Measure-Object -Sum).Sum
    $sumY = ($y | Measure-Object -Sum).Sum
    $sumXY = ($x | ForEach-Object { $i = $_; $x[$i] * $y[$i] } | Measure-Object -Sum).Sum
    $sumX2 = ($x | ForEach-Object { $_ * $_ } | Measure-Object -Sum).Sum
    
    $slope = ($n * $sumXY - $sumX * $sumY) / ($n * $sumX2 - $sumX * $sumX)
    
    return $slope
}

function Predict-FutureValue {
    param($Data, $Trend, $LeadTimeSeconds)
    
    if ($Data.Count -eq 0) { return @{ Value = 0; Confidence = 0 } }
    
    $currentValue = $Data[-1]
    $timeSteps = $LeadTimeSeconds / $script:AlertingInterval
    $predictedValue = $currentValue + ($Trend * $timeSteps)
    
    # Calculate confidence based on trend consistency
    $confidence = [Math]::Min(0.95, [Math]::Max(0.1, 1 - ([Math]::Abs($Trend) / $currentValue)))
    
    return @{
        Value = $predictedValue
        Confidence = $confidence
    }
}

function Get-HistoricalMetrics {
    param($Component, $SubComponent, $Metric)
    
    # Simulate historical data - in production, this would query your metrics database
    $data = @()
    for ($i = 0; $i -lt 20; $i++) {
        $data += Get-Random -Minimum 500 -Maximum 2000
    }
    
    return $data
}

function Invoke-AlertCorrelation {
    param($Alerts)
    
    if (!$EnableAlertCorrelation -or $Alerts.Count -eq 0) {
        return $Alerts
    }
    
    $correlatedAlerts = @()
    $processed = @{}
    
    foreach ($alert in $Alerts) {
        if ($processed.ContainsKey($alert.Id)) {
            continue
        }
        
        # Find correlated alerts
        $correlatedGroup = @($alert)
        $processed[$alert.Id] = $true
        
        foreach ($otherAlert in $Alerts) {
            if ($processed.ContainsKey($otherAlert.Id)) {
                continue
            }
            
            $correlation = Calculate-AlertCorrelation -Alert1 $alert -Alert2 $otherAlert
            if ($correlation -gt $script:AlertingConfig.AlertCorrelation.SimilarityThreshold) {
                $correlatedGroup += $otherAlert
                $processed[$otherAlert.Id] = $true
            }
        }
        
        # Create correlated alert or add individual alert
        if ($correlatedGroup.Count -gt 1) {
            $correlatedAlert = New-CorrelatedAlert -Alerts $correlatedGroup
            $correlatedAlerts += $correlatedAlert
        } else {
            $correlatedAlerts += $alert
        }
    }
    
    return $correlatedAlerts
}

function Calculate-AlertCorrelation {
    param($Alert1, $Alert2)
    
    $score = 0
    
    # Component similarity
    if ($Alert1.Component -eq $Alert2.Component) { $score += 0.3 }
    
    # Time proximity
    $timeDiff = [Math]::Abs(($Alert1.Timestamp - $Alert2.Timestamp).TotalSeconds)
    if ($timeDiff -lt $script:AlertingConfig.AlertCorrelation.TimeWindow) {
        $score += 0.4 * (1 - ($timeDiff / $script:AlertingConfig.AlertCorrelation.TimeWindow))
    }
    
    # Severity similarity
    if ($Alert1.Type -eq $Alert2.Type) { $score += 0.3 }
    
    return $score
}

function New-CorrelatedAlert {
    param($Alerts)
    
    $primaryAlert = $Alerts | Sort-Object { if ($_.Type -eq "Critical") { 0 } elseif ($_.Type -eq "Warning") { 1 } else { 2 } } | Select-Object -First 1
    
    return @{
        Id = [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
        Type = "Correlated"
        Severity = $primaryAlert.Type
        Component = "Multiple"
        Count = $Alerts.Count
        Alerts = $Alerts
        Timestamp = Get-Date
        Status = "New"
        Message = "Correlated alert group: $($Alerts.Count) related alerts detected"
    }
}

function Process-Alert {
    param($Alert)
    
    $alertHash = if ($Alert.Hash) { $Alert.Hash } else { Get-AlertHash -Component $Alert.Component -SubComponent $Alert.SubComponent -Metric $Alert.Metric }
    
    # Check if this is a duplicate of an active alert
    if ($script:AlertState.ActiveAlerts.ContainsKey($alertHash)) {
        $existingAlert = $script:AlertState.ActiveAlerts[$alertHash]
        
        # Update existing alert
        $existingAlert.Count++
        $existingAlert.LastSeen = Get-Date
        $existingAlert.Value = $Alert.Value
        
        Write-Host "🔄 Updated existing alert: $($Alert.Message)" -ForegroundColor Yellow
        return
    }
    
    # New alert - add to active alerts
    $Alert.Count = 1
    $Alert.FirstSeen = Get-Date
    $Alert.LastSeen = Get-Date
    $script:AlertState.ActiveAlerts[$alertHash] = $Alert
    
    # Send notifications
    Send-AlertNotifications -Alert $Alert
    
    # Log alert
    Log-Alert -Alert $Alert
    
    # Start escalation timer for critical alerts
    if ($Alert.Type -eq "Critical") {
        Start-EscalationTimer -Alert $Alert
    }
    
    Write-Host "🚨 NEW ALERT: $($Alert.Type) - $($Alert.Message)" -ForegroundColor Red
}

function Send-AlertNotifications {
    param($Alert)
    
    $channels = $NotificationChannels -split ","
    
    foreach ($channel in $channels) {
        switch ($channel.Trim().ToLower()) {
            "slack" { Send-SlackAlert -Alert $Alert }
            "teams" { Send-TeamsAlert -Alert $Alert }
            "email" { Send-EmailAlert -Alert $Alert }
            "pagerduty" { Send-PagerDutyAlert -Alert $Alert }
        }
    }
}

function Send-SlackAlert {
    param($Alert)
    
    if (!$script:AlertingConfig.Channels.Slack.Enabled -or !$script:AlertingConfig.Channels.Slack.WebhookUrl) {
        return
    }
    
    $color = switch ($Alert.Type) {
        "Critical" { "danger" }
        "Warning" { "warning" }
        "Predictive" { "#ff9500" }
        default { "good" }
    }
    
    $icon = switch ($Alert.Type) {
        "Critical" { ":fire:" }
        "Warning" { ":warning:" }
        "Predictive" { ":crystal_ball:" }
        default { ":information_source:" }
    }
    
    $payload = @{
        channel = if ($Alert.Type -eq "Critical") { $script:AlertingConfig.Channels.Slack.CriticalChannel } else { $script:AlertingConfig.Channels.Slack.DefaultChannel }
        username = "BMAD Alert System"
        icon_emoji = ":rotating_light:"
        attachments = @(
            @{
                color = $color
                title = "$icon BMAD Production Alert - $($Alert.Type)"
                text = $Alert.Message
                fields = @(
                    @{ title = "Component"; value = "$($Alert.Component)/$($Alert.SubComponent)"; short = $true }
                    @{ title = "Metric"; value = $Alert.Metric; short = $true }
                    @{ title = "Value"; value = $Alert.Value; short = $true }
                    @{ title = "Threshold"; value = $Alert.Threshold; short = $true }
                    @{ title = "Time"; value = $Alert.Timestamp.ToString("yyyy-MM-dd HH:mm:ss"); short = $false }
                )
                footer = "BMAD Alerting System"
                ts = [System.DateTimeOffset]::new($Alert.Timestamp).ToUnixTimeSeconds()
            }
        )
    }
    
    try {
        Invoke-RestMethod -Uri $script:AlertingConfig.Channels.Slack.WebhookUrl -Method Post -Body ($payload | ConvertTo-Json -Depth 10) -ContentType "application/json"
        Write-Host "📤 Slack alert sent" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to send Slack alert: $($_.Exception.Message)"
    }
}

function Send-EmailAlert {
    param($Alert)
    
    if (!$script:AlertingConfig.Channels.Email.Enabled) {
        return
    }
    
    $subject = "🚨 BMAD Production Alert - $($Alert.Type): $($Alert.Component)/$($Alert.SubComponent)"
    
    $body = @"
<!DOCTYPE html>
<html>
<head><title>BMAD Production Alert</title></head>
<body style="font-family: Arial, sans-serif;">
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px;">
        <h1>🚨 BMAD Production Alert</h1>
        <h2>Severity: $($Alert.Type)</h2>
    </div>
    
    <div style="padding: 20px;">
        <h3>Alert Details</h3>
        <table style="border-collapse: collapse; width: 100%;">
            <tr><td style="border: 1px solid #ddd; padding: 8px;"><strong>Component</strong></td><td style="border: 1px solid #ddd; padding: 8px;">$($Alert.Component)/$($Alert.SubComponent)</td></tr>
            <tr><td style="border: 1px solid #ddd; padding: 8px;"><strong>Metric</strong></td><td style="border: 1px solid #ddd; padding: 8px;">$($Alert.Metric)</td></tr>
            <tr><td style="border: 1px solid #ddd; padding: 8px;"><strong>Current Value</strong></td><td style="border: 1px solid #ddd; padding: 8px;">$($Alert.Value)</td></tr>
            <tr><td style="border: 1px solid #ddd; padding: 8px;"><strong>Threshold</strong></td><td style="border: 1px solid #ddd; padding: 8px;">$($Alert.Threshold)</td></tr>
            <tr><td style="border: 1px solid #ddd; padding: 8px;"><strong>Time</strong></td><td style="border: 1px solid #ddd; padding: 8px;">$($Alert.Timestamp.ToString('yyyy-MM-dd HH:mm:ss'))</td></tr>
        </table>
        
        <h3>Message</h3>
        <p style="background: #f8f9fa; padding: 15px; border-left: 4px solid #007bff;">$($Alert.Message)</p>
        
        <hr>
        <p style="color: #666; font-size: 12px;">Generated by BMAD Production Alerting System</p>
    </div>
</body>
</html>
"@

    Write-Host "📧 Email alert prepared (actual sending would require SMTP configuration)" -ForegroundColor Yellow
}

function Log-Alert {
    param($Alert)
    
    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Alert = $Alert
    }
    
    $logFile = "$LogPath\active\alert-$($Alert.Id).json"
    $logEntry | ConvertTo-Json -Depth 10 | Set-Content -Path $logFile -Encoding UTF8
    
    # Also append to main alert log
    $mainLogFile = "$LogPath\alerts-$(Get-Date -Format 'yyyy-MM-dd').log"
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$($Alert.Type)] $($Alert.Message)" | Add-Content -Path $mainLogFile -Encoding UTF8
}

function Start-EscalationTimer {
    param($Alert)
    
    $script:AlertState.EscalationTimers[$Alert.Id] = @{
        StartTime = Get-Date
        Level = 0
        Alert = $Alert
    }
}

function Check-AlertEscalations {
    $now = Get-Date
    
    foreach ($alertId in $script:AlertState.EscalationTimers.Keys) {
        $timer = $script:AlertState.EscalationTimers[$alertId]
        $elapsed = ($now - $timer.StartTime).TotalMinutes
        
        $escalationLevel = $null
        foreach ($level in $script:AlertingConfig.EscalationRules.Keys) {
            $rule = $script:AlertingConfig.EscalationRules[$level]
            if ($elapsed -gt $rule.TimeMinutes -and $timer.Level -lt [int]$level.Substring(5)) {
                $escalationLevel = $level
            }
        }
        
        if ($escalationLevel) {
            Invoke-AlertEscalation -AlertId $alertId -Level $escalationLevel
            $timer.Level = [int]$escalationLevel.Substring(5)
        }
    }
}

function Invoke-AlertEscalation {
    param($AlertId, $Level)
    
    $timer = $script:AlertState.EscalationTimers[$AlertId]
    $alert = $timer.Alert
    $rule = $script:AlertingConfig.EscalationRules[$Level]
    
    Write-Host "🔺 ESCALATION $Level for alert: $($alert.Message)" -ForegroundColor Magenta
    
    # Log escalation
    $escalationLog = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        AlertId = $AlertId
        Level = $Level
        Recipients = $rule.Recipients
        Alert = $alert
    }
    
    $escalationLogFile = "$LogPath\escalated\escalation-$AlertId-$Level.json"
    $escalationLog | ConvertTo-Json -Depth 10 | Set-Content -Path $escalationLogFile -Encoding UTF8
    
    # Send escalation notifications
    Send-EscalationNotification -Alert $alert -Level $Level -Recipients $rule.Recipients
}

function Send-EscalationNotification {
    param($Alert, $Level, $Recipients)
    
    Write-Host "📢 Sending escalation notifications to: $($Recipients -join ', ')" -ForegroundColor Red
    
    # In production, this would send notifications to specific recipient groups
    # For now, we'll log the escalation
    $escalationMessage = "🔺 ESCALATION $Level: $($Alert.Message) - Recipients: $($Recipients -join ', ')"
    Write-Host $escalationMessage -ForegroundColor Red
}

function Check-AutoResolution {
    param($Metrics)
    
    $resolvedAlerts = @()
    
    foreach ($alertHash in $script:AlertState.ActiveAlerts.Keys) {
        $alert = $script:AlertState.ActiveAlerts[$alertHash]
        
        # Check if the condition that triggered the alert is now resolved
        $isResolved = Test-AlertResolution -Alert $alert -Metrics $Metrics
        
        if ($isResolved) {
            $resolvedAlerts += $alert
            
            # Move to resolved
            $resolvedLogFile = "$LogPath\resolved\resolved-$($alert.Id).json"
            @{
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Alert = $alert
                ResolutionType = "Auto"
            } | ConvertTo-Json -Depth 10 | Set-Content -Path $resolvedLogFile -Encoding UTF8
            
            # Remove from active alerts
            $script:AlertState.ActiveAlerts.Remove($alertHash)
            
            # Remove escalation timer if exists
            if ($script:AlertState.EscalationTimers.ContainsKey($alert.Id)) {
                $script:AlertState.EscalationTimers.Remove($alert.Id)
            }
            
            Write-Host "✅ Auto-resolved alert: $($alert.Message)" -ForegroundColor Green
        }
    }
    
    return $resolvedAlerts
}

function Test-AlertResolution {
    param($Alert, $Metrics)
    
    # Check if the metric that triggered the alert is now below threshold
    if ($Alert.Component -eq "Agent" -and $Metrics.Agents.ContainsKey($Alert.SubComponent)) {
        $currentAgent = $Metrics.Agents[$Alert.SubComponent]
        
        switch ($Alert.Metric) {
            "Latency" { return $currentAgent.Latency -lt $Alert.Threshold }
            "ErrorRate" { return $currentAgent.ErrorRate -lt $Alert.Threshold }
            "CPU" { return $currentAgent.CPUUsage -lt $Alert.Threshold }
            default { return $false }
        }
    }
    
    if ($Alert.Component -eq "MCP" -and $Metrics.MCPServers.ContainsKey($Alert.SubComponent)) {
        $currentServer = $Metrics.MCPServers[$Alert.SubComponent]
        
        switch ($Alert.Metric) {
            "ResponseTime" { return $currentServer.ResponseTime -lt $Alert.Threshold }
            "Status" { return $currentServer.Status -eq "Up" }
            default { return $false }
        }
    }
    
    return $false
}

function Save-AlertState {
    $stateFile = "$LogPath\alert-state.json"
    try {
        $script:AlertState | ConvertTo-Json -Depth 10 | Set-Content -Path $stateFile -Encoding UTF8
    } catch {
        Write-Warning "Could not save alert state: $($_.Exception.Message)"
    }
}

# Main execution
function Start-RealTimeAlerting {
    try {
        Write-Host "🚨 Starting BMAD Real-time Alerting System..." -ForegroundColor Red
        Write-Host "=" * 80 -ForegroundColor Gray
        
        Initialize-AlertingSystem
        
        Write-Host "🔔 Notification channels: $NotificationChannels" -ForegroundColor Cyan
        Write-Host "⏰ Monitoring interval: $AlertingInterval seconds" -ForegroundColor Cyan
        Write-Host "🔮 Predictive alerting: $EnablePredictiveAlerting" -ForegroundColor Cyan
        Write-Host "🔗 Alert correlation: $EnableAlertCorrelation" -ForegroundColor Cyan
        
        Invoke-RealTimeMonitoring
        
    } catch {
        Write-Error "❌ Real-time alerting system failed: $($_.Exception.Message)"
        Write-Error $_.ScriptStackTrace
        exit 1
    }
}

# Execute if running directly
if ($MyInvocation.InvocationName -ne '.') {
    Start-RealTimeAlerting
}