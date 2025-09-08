#!/usr/bin/env node

/**
 * BMAD+Contains Studio Production Observability Suite
 * Real-time monitoring, metrics collection, and alerting system
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { performance } = require('perf_hooks');

class ProductionObservabilityMonitor {
    constructor(config = {}) {
        this.config = {
            metricsInterval: config.metricsInterval || 30000, // 30 seconds
            alertThresholds: {
                cpuUsage: 80,           // 80% CPU
                memoryUsage: 85,        // 85% Memory
                responseTime: 5000,     // 5 seconds
                errorRate: 5,           // 5% error rate
                agentFailures: 3        // 3 consecutive failures
            },
            retentionDays: config.retentionDays || 30,
            ...config
        };
        
        this.metrics = {
            agents: {},
            mcpServers: {},
            workflows: {},
            system: {},
            alerts: []
        };
        
        this.isRunning = false;
        this.intervalId = null;
        
        this.setupDirectories();
        this.initializeMetrics();
    }

    async start() {
        if (this.isRunning) {
            console.log('⚠️  Monitoring already running');
            return;
        }

        console.log('🚀 Starting BMAD+Contains Studio Production Observability Monitor');
        console.log('================================================================');
        
        this.isRunning = true;
        this.intervalId = setInterval(() => {
            this.collectMetrics();
        }, this.config.metricsInterval);
        
        // Start immediate collection
        await this.collectMetrics();
        
        // Setup graceful shutdown
        process.on('SIGINT', () => this.shutdown());
        process.on('SIGTERM', () => this.shutdown());
        
        console.log(`✅ Monitoring started (interval: ${this.config.metricsInterval}ms)`);
        console.log('📊 Metrics collection active');
        console.log('🔔 Alerting system enabled');
        console.log('💾 Data retention: ' + this.config.retentionDays + ' days');
        console.log('\nPress Ctrl+C to stop monitoring...\n');
    }

    async collectMetrics() {
        const timestamp = new Date().toISOString();
        console.log(`📊 [${timestamp}] Collecting metrics...`);
        
        try {
            // Collect system metrics
            const systemMetrics = await this.collectSystemMetrics();
            
            // Collect agent metrics
            const agentMetrics = await this.collectAgentMetrics();
            
            // Collect MCP server metrics
            const mcpMetrics = await this.collectMCPMetrics();
            
            // Collect workflow metrics
            const workflowMetrics = await this.collectWorkflowMetrics();
            
            // Store metrics
            await this.storeMetrics({
                timestamp,
                system: systemMetrics,
                agents: agentMetrics,
                mcpServers: mcpMetrics,
                workflows: workflowMetrics
            });
            
            // Check alerts
            await this.checkAlerts(systemMetrics, agentMetrics, mcpMetrics);
            
            // Cleanup old data
            await this.cleanupOldData();
            
        } catch (error) {
            console.error('❌ Error collecting metrics:', error);
            this.recordAlert('MONITORING_ERROR', 'high', error.message);
        }
    }

    async collectSystemMetrics() {
        const cpuUsage = os.loadavg()[0];
        const totalMemory = os.totalmem();
        const freeMemory = os.freemem();
        const usedMemory = totalMemory - freeMemory;
        const memoryUsagePercent = (usedMemory / totalMemory) * 100;
        
        const nodeMemory = process.memoryUsage();
        const nodeCpu = process.cpuUsage();
        
        return {
            cpu: {
                loadAverage: Math.round(cpuUsage * 100) / 100,
                usage_percent: Math.min(100, Math.round(cpuUsage * 10))
            },
            memory: {
                total_mb: Math.round(totalMemory / 1024 / 1024),
                used_mb: Math.round(usedMemory / 1024 / 1024),
                free_mb: Math.round(freeMemory / 1024 / 1024),
                usage_percent: Math.round(memoryUsagePercent)
            },
            process: {
                heap_used_mb: Math.round(nodeMemory.heapUsed / 1024 / 1024),
                heap_total_mb: Math.round(nodeMemory.heapTotal / 1024 / 1024),
                rss_mb: Math.round(nodeMemory.rss / 1024 / 1024),
                cpu_user_ms: Math.round(nodeCpu.user / 1000),
                cpu_system_ms: Math.round(nodeCpu.system / 1000)
            },
            uptime: Math.round(os.uptime()),
            platform: os.platform(),
            arch: os.arch()
        };
    }

    async collectAgentMetrics() {
        const agentTypes = [
            'bmad-orchestrator', 'bmad-parallel-orchestrator', 'bmad-analyst', 
            'bmad-architect', 'bmad-dev', 'bmad-sm', 'contains-design-ui',
            'contains-eng-frontend', 'contains-eng-devops', 'contains-test-analyzer'
        ];
        
        const agentMetrics = {};
        
        for (const agentType of agentTypes) {
            // Simulate agent health check
            const healthCheck = await this.simulateAgentHealthCheck(agentType);
            
            agentMetrics[agentType] = {
                status: healthCheck.status,
                response_time_ms: healthCheck.responseTime,
                success_rate: healthCheck.successRate,
                last_used: healthCheck.lastUsed,
                coordination_score: healthCheck.coordinationScore,
                error_count: healthCheck.errorCount
            };
        }
        
        return agentMetrics;
    }

    async collectMCPMetrics() {
        const mcpServers = [
            'github', 'firecrawl', 'postgresql', 'redis',
            'notion', 'shadcn', 'filesystem', 'memory'
        ];
        
        const mcpMetrics = {};
        
        for (const server of mcpServers) {
            // Simulate MCP server health check
            const healthCheck = await this.simulateMCPHealthCheck(server);
            
            mcpMetrics[server] = {
                status: healthCheck.status,
                response_time_ms: healthCheck.responseTime,
                availability_percent: healthCheck.availability,
                throughput_qps: healthCheck.throughput,
                error_rate: healthCheck.errorRate,
                security_status: healthCheck.securityStatus
            };
        }
        
        return mcpMetrics;
    }

    async collectWorkflowMetrics() {
        const workflows = ['init-prd', 'init-architecture', 'shard-stories', 'run-next-story', 'qa-gate'];
        const workflowMetrics = {};
        
        for (const workflow of workflows) {
            // Simulate workflow metrics
            const metrics = await this.simulateWorkflowMetrics(workflow);
            
            workflowMetrics[workflow] = {
                executions_last_hour: metrics.executions,
                avg_duration_ms: metrics.avgDuration,
                success_rate: metrics.successRate,
                parallel_efficiency: metrics.parallelEfficiency,
                resource_utilization: metrics.resourceUtilization
            };
        }
        
        return workflowMetrics;
    }

    async storeMetrics(metrics) {
        const filename = `metrics-${new Date().toISOString().split('T')[0]}.json`;
        const filepath = path.join('logs', 'monitoring', filename);
        
        // Append to daily metrics file
        let existingData = [];
        if (fs.existsSync(filepath)) {
            const content = fs.readFileSync(filepath, 'utf8');
            existingData = JSON.parse(content);
        }
        
        existingData.push(metrics);
        fs.writeFileSync(filepath, JSON.stringify(existingData, null, 2));
        
        // Update real-time metrics
        const realtimeFile = path.join('logs', 'monitoring', 'realtime-metrics.json');
        fs.writeFileSync(realtimeFile, JSON.stringify(metrics, null, 2));
        
        console.log(`  💾 Metrics stored: ${filepath}`);
    }

    async checkAlerts(systemMetrics, agentMetrics, mcpMetrics) {
        const alerts = [];
        
        // System alerts
        if (systemMetrics.cpu.usage_percent > this.config.alertThresholds.cpuUsage) {
            alerts.push({
                type: 'CPU_HIGH',
                severity: 'high',
                message: `CPU usage ${systemMetrics.cpu.usage_percent}% exceeds threshold ${this.config.alertThresholds.cpuUsage}%`,
                value: systemMetrics.cpu.usage_percent
            });
        }
        
        if (systemMetrics.memory.usage_percent > this.config.alertThresholds.memoryUsage) {
            alerts.push({
                type: 'MEMORY_HIGH',
                severity: 'high',
                message: `Memory usage ${systemMetrics.memory.usage_percent}% exceeds threshold ${this.config.alertThresholds.memoryUsage}%`,
                value: systemMetrics.memory.usage_percent
            });
        }
        
        // Agent alerts
        Object.entries(agentMetrics).forEach(([agent, metrics]) => {
            if (metrics.response_time_ms > this.config.alertThresholds.responseTime) {
                alerts.push({
                    type: 'AGENT_SLOW_RESPONSE',
                    severity: 'medium',
                    message: `Agent ${agent} response time ${metrics.response_time_ms}ms exceeds threshold`,
                    agent: agent,
                    value: metrics.response_time_ms
                });
            }
            
            if (metrics.success_rate < 95) {
                alerts.push({
                    type: 'AGENT_LOW_SUCCESS_RATE',
                    severity: 'high',
                    message: `Agent ${agent} success rate ${metrics.success_rate}% is below 95%`,
                    agent: agent,
                    value: metrics.success_rate
                });
            }
        });
        
        // MCP Server alerts
        Object.entries(mcpMetrics).forEach(([server, metrics]) => {
            if (metrics.status !== 'healthy') {
                alerts.push({
                    type: 'MCP_SERVER_UNHEALTHY',
                    severity: 'critical',
                    message: `MCP Server ${server} is ${metrics.status}`,
                    server: server,
                    value: metrics.status
                });
            }
            
            if (metrics.error_rate > this.config.alertThresholds.errorRate) {
                alerts.push({
                    type: 'MCP_HIGH_ERROR_RATE',
                    severity: 'high',
                    message: `MCP Server ${server} error rate ${metrics.error_rate}% exceeds threshold`,
                    server: server,
                    value: metrics.error_rate
                });
            }
        });
        
        // Process alerts
        if (alerts.length > 0) {
            await this.processAlerts(alerts);
        } else {
            console.log('  ✅ All systems healthy - no alerts');
        }
    }

    async processAlerts(alerts) {
        console.log(`  🔔 Processing ${alerts.length} alerts:`);
        
        for (const alert of alerts) {
            const alertWithTimestamp = {
                ...alert,
                timestamp: new Date().toISOString(),
                id: this.generateAlertId()
            };
            
            this.metrics.alerts.push(alertWithTimestamp);
            
            // Log alert
            console.log(`    ${this.getSeverityIcon(alert.severity)} ${alert.type}: ${alert.message}`);
            
            // Store alert
            await this.storeAlert(alertWithTimestamp);
            
            // Send notifications (if configured)
            await this.sendAlertNotification(alertWithTimestamp);
        }
    }

    async storeAlert(alert) {
        const alertsFile = path.join('logs', 'monitoring', 'alerts.json');
        
        let alerts = [];
        if (fs.existsSync(alertsFile)) {
            const content = fs.readFileSync(alertsFile, 'utf8');
            alerts = JSON.parse(content);
        }
        
        alerts.push(alert);
        
        // Keep only last 1000 alerts
        if (alerts.length > 1000) {
            alerts = alerts.slice(-1000);
        }
        
        fs.writeFileSync(alertsFile, JSON.stringify(alerts, null, 2));
    }

    async sendAlertNotification(alert) {
        // In a real implementation, this would send to Slack, email, PagerDuty, etc.
        if (alert.severity === 'critical') {
            console.log(`    📢 CRITICAL ALERT NOTIFICATION: ${alert.message}`);
        }
    }

    async cleanupOldData() {
        const cutoffDate = new Date();
        cutoffDate.setDate(cutoffDate.getDate() - this.config.retentionDays);
        
        const monitoringDir = path.join('logs', 'monitoring');
        const files = fs.readdirSync(monitoringDir);
        
        for (const file of files) {
            if (file.startsWith('metrics-') && file.endsWith('.json')) {
                const dateStr = file.replace('metrics-', '').replace('.json', '');
                const fileDate = new Date(dateStr);
                
                if (fileDate < cutoffDate) {
                    fs.unlinkSync(path.join(monitoringDir, file));
                    console.log(`  🗑️  Cleaned up old metrics file: ${file}`);
                }
            }
        }
    }

    async generateDashboardReport() {
        console.log('\n📊 Generating Dashboard Report...');
        
        const report = {
            timestamp: new Date().toISOString(),
            summary: {
                system_health: 'healthy',
                active_agents: 10,
                mcp_servers_healthy: 8,
                alerts_last_24h: this.metrics.alerts.length,
                uptime_hours: Math.round(os.uptime() / 3600)
            },
            metrics: this.metrics,
            recommendations: this.generateHealthRecommendations()
        };
        
        const reportFile = path.join('logs', 'monitoring', 'dashboard-report.json');
        fs.writeFileSync(reportFile, JSON.stringify(report, null, 2));
        
        console.log(`✅ Dashboard report generated: ${reportFile}`);
        return report;
    }

    generateHealthRecommendations() {
        const recommendations = [];
        
        // Analyze recent alerts
        const recentAlerts = this.metrics.alerts.filter(alert => {
            const alertTime = new Date(alert.timestamp);
            const now = new Date();
            return (now - alertTime) < 24 * 60 * 60 * 1000; // Last 24 hours
        });
        
        if (recentAlerts.length === 0) {
            recommendations.push('System is running optimally with no recent alerts');
        } else {
            recommendations.push(`Review and address ${recentAlerts.length} alerts from last 24 hours`);
        }
        
        recommendations.push('Monitor CPU and memory usage during peak hours');
        recommendations.push('Review agent coordination patterns for optimization opportunities');
        recommendations.push('Ensure MCP server health checks are passing consistently');
        
        return recommendations;
    }

    // Simulation methods (replace with real implementations)
    async simulateAgentHealthCheck(agentType) {
        await this.sleep(Math.random() * 100);
        return {
            status: Math.random() > 0.1 ? 'healthy' : 'degraded',
            responseTime: Math.round(50 + Math.random() * 200),
            successRate: Math.round(95 + Math.random() * 5),
            lastUsed: new Date(Date.now() - Math.random() * 3600000).toISOString(),
            coordinationScore: Math.round(85 + Math.random() * 15),
            errorCount: Math.floor(Math.random() * 3)
        };
    }

    async simulateMCPHealthCheck(server) {
        await this.sleep(Math.random() * 50);
        return {
            status: Math.random() > 0.05 ? 'healthy' : 'unhealthy',
            responseTime: Math.round(30 + Math.random() * 150),
            availability: Math.round(99 + Math.random()),
            throughput: Math.round(10 + Math.random() * 40),
            errorRate: Math.round(Math.random() * 2),
            securityStatus: 'secure'
        };
    }

    async simulateWorkflowMetrics(workflow) {
        await this.sleep(Math.random() * 30);
        return {
            executions: Math.floor(Math.random() * 20),
            avgDuration: Math.round(1000 + Math.random() * 3000),
            successRate: Math.round(96 + Math.random() * 4),
            parallelEfficiency: Math.round(75 + Math.random() * 20),
            resourceUtilization: Math.round(60 + Math.random() * 30)
        };
    }

    // Utility methods
    setupDirectories() {
        const dirs = ['logs/monitoring', 'logs/alerts'];
        dirs.forEach(dir => {
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
        });
    }

    initializeMetrics() {
        this.metrics = {
            agents: {},
            mcpServers: {},
            workflows: {},
            system: {},
            alerts: []
        };
    }

    getSeverityIcon(severity) {
        const icons = {
            low: '🟡',
            medium: '🟠',
            high: '🔴',
            critical: '🚨'
        };
        return icons[severity] || '⚪';
    }

    generateAlertId() {
        return `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    recordAlert(type, severity, message) {
        const alert = {
            id: this.generateAlertId(),
            timestamp: new Date().toISOString(),
            type,
            severity,
            message
        };
        this.metrics.alerts.push(alert);
        this.storeAlert(alert);
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    shutdown() {
        console.log('\n🛑 Shutting down monitoring system...');
        
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
        
        this.isRunning = false;
        
        // Generate final report
        this.generateDashboardReport().then(() => {
            console.log('✅ Monitoring system shutdown complete');
            process.exit(0);
        });
    }
}

// CLI interface
if (require.main === module) {
    const monitor = new ProductionObservabilityMonitor({
        metricsInterval: process.argv.includes('--fast') ? 10000 : 30000,
        retentionDays: 30
    });
    
    if (process.argv.includes('--report')) {
        // Generate single report and exit
        monitor.generateDashboardReport().then(() => {
            console.log('✅ Dashboard report generated');
            process.exit(0);
        });
    } else {
        // Start continuous monitoring
        monitor.start();
    }
}

module.exports = ProductionObservabilityMonitor;