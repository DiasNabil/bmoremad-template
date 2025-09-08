---
name: monitor-impact
description: >
  Post-deployment intelligence workflow with multi-agent coordination for performance
  monitoring, user impact analysis, and continuous optimization insights.
category: post-deployment-intelligence
---

# Post-Deployment Impact Monitoring - BMAD Intelligence Workflow

Orchestrates comprehensive post-deployment monitoring through multi-agent intelligence for performance tracking, user impact analysis, and continuous optimization.

## Usage
```bash
/BMad/monitor-impact [deployment]    # Start post-deployment monitoring
/BMad/analyze-performance           # Performance impact analysis
/BMad/track-user-behavior          # User behavior impact assessment
/BMad/measure-business-metrics     # Business impact measurement
/BMad/generate-insights            # Intelligence insights compilation
/BMad/optimize-based-on-data       # Data-driven optimization recommendations
```

## Post-Deployment Intelligence Team

### **Real-Time Monitoring Team (Parallel - Continuous)**
```yaml
MonitoringTeam:
  Agent1: "contains-eng-devops"
    Role: "performance-monitor"
    Tasks: ["system-performance-tracking", "resource-utilization-analysis", "error-rate-monitoring"]
    MCP_Integration: ["redis", "postgresql", "filesystem"]
    Focus: ["response-times", "throughput", "error-rates", "resource-usage"]
    Outputs: ["logs/monitoring/performance-metrics.md"]
    Schedule: "Continuous with 5-min intervals"
    
  Agent2: "contains-test-analyzer"
    Role: "quality-monitor"
    Tasks: ["service-health-assessment", "reliability-tracking", "sla-compliance-monitoring"]
    MCP_Integration: ["github", "redis", "postgresql"]
    Focus: ["availability", "reliability", "quality-metrics", "sla-adherence"]
    Outputs: ["logs/monitoring/quality-metrics.md"]
    Schedule: "Continuous with 10-min intervals"
    
  Agent3: "bmad-analyst"
    Role: "data-intelligence-analyst"
    Tasks: ["usage-pattern-analysis", "trend-identification", "anomaly-detection"]
    MCP_Integration: ["postgresql", "redis", "filesystem"]
    Focus: ["usage-analytics", "user-behavior", "data-patterns", "anomalies"]
    Outputs: ["logs/monitoring/intelligence-analysis.md"]
    Schedule: "Hourly analysis with real-time alerts"
```

### **Impact Assessment Team (Scheduled - Daily/Weekly)**
```yaml
AssessmentTeam:
  Agent1: "bmad-pm"
    Role: "business-impact-analyst"
    Tasks: ["business-metrics-analysis", "kpi-tracking", "roi-assessment"]
    MCP_Integration: ["notion", "postgresql"]
    Focus: ["conversion-rates", "user-satisfaction", "business-kpis", "revenue-impact"]
    Outputs: ["docs/monitoring/business-impact.md"]
    Schedule: "Daily summary, Weekly deep analysis"
    
  Agent2: "contains-design-ux-researcher"
    Role: "user-experience-analyst"
    Tasks: ["user-behavior-analysis", "ux-impact-assessment", "satisfaction-tracking"]
    MCP_Integration: ["notion", "filesystem"]
    Focus: ["user-journeys", "interaction-patterns", "satisfaction-scores", "usability-metrics"]
    Outputs: ["docs/monitoring/ux-impact.md"]
    Schedule: "Weekly analysis with daily trend monitoring"
```

## Monitoring Dimensions & Metrics

### **Technical Performance Metrics**
```yaml
TechnicalMetrics:
  Response_Performance:
    - "Average response time"
    - "95th percentile response time"
    - "99th percentile response time"
    - "Response time distribution"
    
  Throughput_Metrics:
    - "Requests per second"
    - "Transactions per minute"
    - "Concurrent user handling"
    - "Peak load capacity"
    
  Reliability_Metrics:
    - "System uptime percentage"
    - "Error rate (4xx, 5xx)"
    - "Failed request percentage"
    - "Recovery time from failures"
    
  Resource_Utilization:
    - "CPU utilization patterns"
    - "Memory usage trends"
    - "Disk I/O performance"
    - "Network bandwidth usage"
```

### **User Experience Metrics**
```yaml
UserExperienceMetrics:
  Engagement_Metrics:
    - "Session duration"
    - "Page views per session"
    - "Bounce rate changes"
    - "Feature adoption rates"
    
  Satisfaction_Metrics:
    - "User satisfaction scores"
    - "Net Promoter Score (NPS)"
    - "Customer support ticket volume"
    - "User feedback sentiment"
    
  Behavioral_Metrics:
    - "User journey completion rates"
    - "Feature usage patterns"
    - "Drop-off point analysis"
    - "Conversion funnel performance"
```

### **Business Impact Metrics**
```yaml
BusinessMetrics:
  Revenue_Impact:
    - "Conversion rate changes"
    - "Average order value"
    - "Revenue per user"
    - "Customer lifetime value"
    
  Operational_Efficiency:
    - "Support ticket reduction"
    - "Processing time improvements"
    - "Manual intervention reduction"
    - "Cost per transaction"
    
  Growth_Metrics:
    - "User acquisition rate"
    - "User retention rate"
    - "Market share impact"
    - "Competitive advantage metrics"
```

## MCP Server Integration for Monitoring

### **Data Collection & Analysis**
```yaml
MCP_MonitoringIntegration:
  PostgreSQL:
    - User behavior data analysis
    - Performance metrics storage
    - Business KPI calculation
    - Trend analysis queries
    
  Redis:
    - Real-time performance monitoring
    - Cache hit/miss ratio tracking
    - Session analytics
    - Real-time dashboard updates
    
  Filesystem:
    - Log file analysis
    - Error pattern detection
    - Configuration change impact
    - Deployment correlation analysis
    
  GitHub:
    - Deployment impact correlation
    - Feature rollout tracking
    - Bug report correlation
    - Code change impact analysis
```

### **Intelligence Platform Integration**
```yaml
IntelligencePlatform:
  Notion:
    - Impact dashboard creation
    - Stakeholder reporting
    - Insights compilation
    - Action item tracking
    
  Firecrawl:
    - External benchmark comparison
    - Market impact analysis
    - Competitor performance tracking
    - Industry trend correlation
```

## Intelligent Alert Systems

### **Performance Alert Thresholds**
```yaml
PerformanceAlerts:
  Critical_Alerts:
    - "Response time > 5 seconds"
    - "Error rate > 5%"
    - "System availability < 99%"
    - "Resource utilization > 90%"
    
  Warning_Alerts:
    - "Response time > 2 seconds"
    - "Error rate > 1%"
    - "System availability < 99.5%"
    - "Resource utilization > 70%"
    
  Trend_Alerts:
    - "Performance degradation > 20%"
    - "Traffic increase > 50%"
    - "User satisfaction decrease > 10%"
    - "Business metric decline > 15%"
```

### **Anomaly Detection**
```yaml
AnomalyDetection:
  Statistical_Anomalies:
    - "Performance metrics outside 2 standard deviations"
    - "Traffic patterns significantly different from baseline"
    - "Error patterns not seen in training data"
    - "User behavior deviations from normal patterns"
    
  Machine_Learning_Detection:
    - "Time series forecasting deviations"
    - "Clustering-based outlier detection"
    - "Pattern recognition anomalies"
    - "Predictive model confidence thresholds"
```

## Impact Analysis Workflows

### **Phase 1: Immediate Post-Deployment (0-24 hours)**
```yaml
ImmediateAssessment:
  Technical_Monitoring:
    - "Performance baseline establishment"
    - "Error rate monitoring"
    - "Resource utilization tracking"
    - "Service health validation"
    
  User_Impact_Tracking:
    - "Initial user behavior monitoring"
    - "Feature adoption tracking"
    - "Support ticket volume monitoring"
    - "User feedback collection"
    
  Business_Impact_Assessment:
    - "Critical business metrics monitoring"
    - "Revenue impact assessment"
    - "Operational efficiency measurement"
    - "Stakeholder communication"
```

### **Phase 2: Short-term Analysis (1-7 days)**
```yaml
ShortTermAnalysis:
  Trend_Analysis:
    - "Performance trend identification"
    - "User behavior pattern analysis"
    - "Business metric evolution"
    - "Comparative analysis with pre-deployment"
    
  Impact_Quantification:
    - "Quantitative impact measurement"
    - "ROI calculation"
    - "Cost-benefit analysis"
    - "Risk assessment updates"
```

### **Phase 3: Long-term Intelligence (1-4 weeks)**
```yaml
LongTermIntelligence:
  Strategic_Insights:
    - "Long-term trend analysis"
    - "Seasonal pattern identification"
    - "User adaptation analysis"
    - "Market position impact assessment"
    
  Optimization_Opportunities:
    - "Performance optimization identification"
    - "User experience improvement areas"
    - "Business process enhancement opportunities"
    - "Future development prioritization"
```

## Optimization Recommendation Engine

### **Data-Driven Recommendations**
```yaml
OptimizationRecommendations:
  Performance_Optimizations:
    - "Database query optimization suggestions"
    - "Caching strategy improvements"
    - "Resource allocation adjustments"
    - "Architecture optimization recommendations"
    
  User_Experience_Enhancements:
    - "UI/UX improvement suggestions"
    - "User journey optimization"
    - "Feature enhancement priorities"
    - "Accessibility improvement opportunities"
    
  Business_Process_Improvements:
    - "Workflow optimization suggestions"
    - "Automation opportunity identification"
    - "Cost reduction recommendations"
    - "Revenue optimization strategies"
```

### **Prioritization Framework**
```yaml
RecommendationPrioritization:
  High_Impact_Low_Effort:
    - "Quick wins with immediate impact"
    - "Configuration changes"
    - "Parameter tuning"
    - "Feature flag adjustments"
    
  High_Impact_High_Effort:
    - "Strategic improvements"
    - "Architecture changes"
    - "Major feature enhancements"
    - "System redesign initiatives"
    
  Impact_Scoring:
    - "User impact score (1-10)"
    - "Business impact score (1-10)"
    - "Technical effort score (1-10)"
    - "Implementation risk score (1-10)"
```

## Success Metrics & KPIs

### **Monitoring Effectiveness**
```yaml
MonitoringKPIs:
  Detection_Accuracy:
    - "Issue detection rate: >95%"
    - "False positive rate: <5%"
    - "Alert response time: <5 minutes"
    - "Root cause identification accuracy: >85%"
    
  Impact_Assessment_Quality:
    - "Impact prediction accuracy: >80%"
    - "Business correlation accuracy: >90%"
    - "Trend identification success: >85%"
    - "Optimization recommendation success: >75%"
```

### **Business Value Metrics**
```yaml
BusinessValueKPIs:
  Performance_Improvements:
    - "Response time improvement: -20%"
    - "Error rate reduction: -50%"
    - "User satisfaction increase: +15%"
    - "Cost reduction: -10%"
    
  Strategic_Value:
    - "Time to insight: <1 hour"
    - "Decision making speed: +40%"
    - "Proactive issue prevention: +60%"
    - "Competitive advantage metrics"
```

## Natural Language Monitoring Triggers

### **Monitoring Activation Commands**
```yaml
MonitoringTriggers:
  - "Monitor deployment impact"
  - "Track performance after release"
  - "Analyze user behavior changes"
  - "Measure business impact"
  - "Generate post-deployment insights"
  - "Monitor system health continuously"
  - "Track feature adoption"
```

### **Contextual Intelligence**
```python
def determine_monitoring_scope(deployment_context, user_request):
    if "performance" in user_request.lower():
        return ["technical-performance", "user-experience"]
    elif "business" in user_request.lower():
        return ["business-metrics", "user-behavior", "revenue-impact"]
    elif "user" in user_request.lower():
        return ["user-experience", "user-behavior", "satisfaction"]
    else:
        return ["comprehensive-monitoring"]
```

## Integration with BMAD Workflows

### **Quality Gates Integration**
```yaml
QualityGateIntegration:
  PostDeploymentGates:
    - "Performance threshold validation"
    - "User satisfaction benchmark achievement"
    - "Business metrics target confirmation"
    - "Error rate acceptance criteria"
```

### **Continuous Improvement Loop**
```yaml
ContinuousImprovement:
  FeedbackLoop:
    - "Monitoring insights to backlog prioritization"
    - "Performance data to architecture decisions"
    - "User behavior data to UX improvements"
    - "Business impact data to strategic planning"
```

## Deliverables

### **Monitoring Reports**
- **Performance Impact Report** (`docs/monitoring/performance-impact.md`)
- **User Behavior Analysis** (`docs/monitoring/user-behavior-analysis.md`)
- **Business Impact Assessment** (`docs/monitoring/business-impact.md`)
- **Intelligence Insights** (`docs/monitoring/intelligence-insights.md`)

### **Optimization Plans**
- **Performance Optimization Plan** (`docs/monitoring/performance-optimization.md`)
- **User Experience Enhancement Plan** (`docs/monitoring/ux-enhancement.md`)
- **Business Process Improvement Plan** (`docs/monitoring/business-improvement.md`)

### **Dashboards & Tracking**
- **Real-time Performance Dashboard** (Notion integration)
- **Business Intelligence Dashboard** (automated updates)
- **Alert Configuration** (`docs/monitoring/alert-config.md`)
- **Trend Analysis Reports** (`docs/monitoring/trend-analysis/`)

---

**📊 Intelligent post-deployment monitoring with multi-agent coordination for continuous optimization and data-driven decision making.**