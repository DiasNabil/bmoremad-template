---
name: crisis-response
description: >
  Crisis and incident response coordination workflow with rapid multi-agent mobilization
  for production incidents, security breaches, and critical system failures.
category: incident-response
---

# Crisis Response - BMAD Incident Coordination Workflow

Orchestrates rapid multi-agent crisis response with coordinated incident management, root cause analysis, and recovery planning.

## Usage
```bash
/BMad/crisis-response [severity]    # Activate crisis response team
/BMad/incident-assess              # Rapid impact assessment
/BMad/emergency-fix                # Coordinate emergency fixes
/BMad/crisis-comms                 # Manage crisis communications
/BMad/post-mortem                  # Post-incident analysis
```

## Crisis Response Team Structure

### **Immediate Response Team (Parallel - 0-5 minutes)**
```yaml
ImmediateResponse:
  Agent1: "contains-eng-devops"
    Role: "incident-commander"
    Tasks: ["system-status-assessment", "immediate-stabilization"]
    MCP_Integration: ["github", "redis", "postgresql"]
    Priority: "P0 - Critical"
    Outputs: ["logs/incident/initial-assessment.md"]
    
  Agent2: "contains-test-analyzer"
    Role: "impact-assessor"  
    Tasks: ["service-health-check", "user-impact-analysis"]
    MCP_Integration: ["filesystem", "redis"]
    Priority: "P0 - Critical"
    Outputs: ["logs/incident/impact-report.md"]
    
  Agent3: "bmad-analyst"
    Role: "data-collector"
    Tasks: ["log-aggregation", "metrics-collection", "timeline-construction"]
    MCP_Integration: ["filesystem", "github"]
    Priority: "P0 - Critical"
    Outputs: ["logs/incident/data-collection.md"]
```

### **Recovery Team (Sequential - 5-30 minutes)**
```yaml
RecoveryPhase:
  Agent1: "contains-eng-backend"
    Role: "technical-lead"
    Tasks: ["root-cause-identification", "fix-development"]
    Dependencies: ["initial-assessment-complete"]
    Outputs: ["logs/incident/technical-analysis.md"]
    
  Agent2: "bmad-pm"
    Role: "coordination-lead"
    Tasks: ["stakeholder-communication", "resource-coordination"]
    Dependencies: ["impact-assessment-complete"]  
    Outputs: ["logs/incident/communication-log.md"]
```

## Incident Severity Classifications

### **P0 - Critical (System Down)**
```yaml
P0_Response:
  ResponseTime: "< 5 minutes"
  TeamSize: "Full crisis team (5 agents)"
  Escalation: "Immediate C-level notification"
  
  Triggers:
    - "Complete system outage"
    - "Security breach detected"
    - "Data loss incident"
    - "Payment processing failure"
    
  Actions:
    - Immediate war room activation
    - All-hands mobilization
    - Customer communication within 15 minutes
    - Executive briefing within 30 minutes
```

### **P1 - High (Major Impact)**
```yaml
P1_Response:
  ResponseTime: "< 15 minutes"
  TeamSize: "Core crisis team (3 agents)"
  Escalation: "Management notification"
  
  Triggers:
    - "Major feature dysfunction"
    - "Performance severe degradation"
    - "API endpoints failing"
    - "Database connectivity issues"
```

### **P2 - Medium (Limited Impact)**
```yaml
P2_Response:
  ResponseTime: "< 30 minutes"
  TeamSize: "Specialized team (2 agents)"
  Escalation: "Team lead notification"
  
  Triggers:
    - "Non-critical feature issues"
    - "Moderate performance impact"
    - "Minor integration failures"
```

## Crisis Response Workflows

### **Phase 1: Detection & Assessment (0-5 minutes)**
```yaml
Detection:
  AutoTriggers:
    - Monitoring alert thresholds exceeded
    - Error rate spikes > 5%
    - Response time > 10x baseline
    - User-reported critical issues
    
  ManualTriggers:
    - "/BMad/crisis-response P0"
    - "Emergency: system down"
    - "Security incident detected"
    
  ImmediateActions:
    - Log collection activation
    - System health dashboard
    - Initial stakeholder notification
    - Crisis team mobilization
```

### **Phase 2: Stabilization (5-30 minutes)**
```yaml
Stabilization:
  TechnicalActions:
    - Emergency fixes deployment
    - Traffic routing adjustments
    - Database failover if needed
    - Cache clearing/warming
    
  CommunicationActions:
    - Status page updates
    - Customer notifications
    - Internal stakeholder briefings
    - Media response preparation
```

### **Phase 3: Recovery (30 minutes - 2 hours)**
```yaml
Recovery:
  SystemRestoration:
    - Full service restoration
    - Performance optimization
    - Data integrity verification
    - Monitoring enhancement
    
  BusinessContinuity:
    - Customer impact mitigation
    - Revenue loss calculation
    - Compliance notification if required
    - Partner/vendor coordination
```

### **Phase 4: Post-Incident (2-24 hours)**
```yaml
PostIncident:
  Analysis:
    - Root cause analysis
    - Timeline reconstruction
    - Contributing factors identification
    - Prevention measures design
    
  Documentation:
    - Incident report creation
    - Lessons learned compilation
    - Process improvement recommendations
    - Knowledge base updates
```

## MCP Server Integration for Crisis

### **Real-Time Monitoring**
```yaml
MCP_CrisisIntegration:
  Redis:
    - Real-time metrics collection
    - Cache status monitoring
    - Session state analysis
    
  PostgreSQL:
    - Database health checks
    - Query performance analysis
    - Data integrity validation
    
  Filesystem:
    - Log file monitoring
    - Disk space checks
    - Configuration validation
    
  GitHub:
    - Recent deployment correlation
    - Code change impact analysis
    - Emergency fix tracking
```

### **Communication Channels**
```yaml
CommunicationIntegration:
  Notion:
    - Crisis dashboard creation
    - Real-time status updates
    - Stakeholder communication log
    
  Firecrawl:
    - External status monitoring
    - Competitor impact analysis
    - Public sentiment tracking
```

## Crisis Communication Protocols

### **Internal Communication**
```yaml
InternalComms:
  ImmediateNotification:
    - Crisis team via automated alerts
    - Management via escalation matrix
    - Engineering team via broadcast
    
  OngoingUpdates:
    - 15-minute status updates during P0
    - 30-minute updates during P1
    - Hourly updates during P2
```

### **External Communication**
```yaml
ExternalComms:
  CustomerFacing:
    - Status page updates (immediate)
    - Email notifications (< 30 min for P0)
    - In-app notifications
    - Social media updates
    
  StakeholderBriefing:
    - Executive summary (< 1 hour)
    - Partner notifications
    - Regulatory reporting if required
```

## Recovery Strategies

### **Technical Recovery**
```yaml
TechnicalStrategies:
  QuickFixes:
    - Service restart procedures
    - Configuration rollbacks
    - Traffic re-routing
    - Emergency patches
    
  SystemRecovery:
    - Database restoration
    - Application rollback
    - Infrastructure scaling
    - Performance tuning
```

### **Business Recovery**
```yaml
BusinessRecovery:
  CustomerRetention:
    - Service credits calculation
    - Apology communications
    - Feature rollout acceleration
    - Relationship management
    
  ReputationManagement:
    - Public statement preparation
    - Media response strategy
    - Community engagement
    - Trust rebuilding initiatives
```

## Success Metrics

### **Response Time Metrics**
```yaml
ResponseMetrics:
  DetectionTime: "< 5 minutes from occurrence"
  ResponseTime: "< 5 minutes for P0, < 15 min for P1"
  ResolutionTime: "< 1 hour for P0, < 4 hours for P1"
  CommunicationTime: "< 15 minutes for customer notification"
```

### **Recovery Effectiveness**
```yaml
RecoveryMetrics:
  SystemRecovery: "RTO (Recovery Time Objective) achievement"
  DataIntegrity: "RPO (Recovery Point Objective) compliance"
  CustomerSatisfaction: "Post-incident survey scores"
  PreventionEffectiveness: "Incident recurrence reduction"
```

## Natural Language Crisis Triggers

### **Emergency Activation**
```yaml
CrisisTriggers:
  - "Emergency: system is down"
  - "Critical incident response needed"
  - "Security breach detected"
  - "Production outage"
  - "Customer impact severe"
  - "Database failure"
  - "API completely failing"
```

### **Contextual Detection**
```python
def detect_crisis_severity(context, user_input):
    p0_indicators = ["down", "outage", "breach", "failure", "critical", "emergency"]
    p1_indicators = ["slow", "errors", "degraded", "issues", "problems"]
    
    if any(indicator in user_input.lower() for indicator in p0_indicators):
        return "P0"
    elif any(indicator in user_input.lower() for indicator in p1_indicators):
        return "P1"
    else:
        return "P2"
```

## Integration with BMAD Workflows

### **Quality Gates Enhancement**
```yaml
QualityIntegration:
  PreventiveMeasures:
    - Crisis scenarios in testing
    - Incident response drills
    - Monitoring threshold tuning
    - Alerting optimization
```

### **Architecture Reviews**
```yaml
ArchitectureIntegration:
  ResilienceReview:
    - Single points of failure identification
    - Disaster recovery planning
    - Monitoring and alerting design
    - Incident response capabilities
```

## Deliverables

### **Crisis Response Outputs**
- **Incident Report** (`logs/incident/incident-report.md`)
- **Timeline Reconstruction** (`logs/incident/timeline.md`)
- **Impact Assessment** (`logs/incident/impact-analysis.md`)
- **Recovery Actions Log** (`logs/incident/recovery-log.md`)

### **Post-Crisis Documentation**
- **Root Cause Analysis** (`docs/incidents/rca-YYYY-MM-DD.md`)
- **Lessons Learned** (`docs/incidents/lessons-learned.md`)
- **Process Improvements** (`docs/incidents/improvements.md`)
- **Prevention Measures** (`docs/incidents/prevention-plan.md`)

### **Knowledge Management**
- **Runbook Updates** (`docs/operations/runbooks/`)
- **Crisis Response Procedures** (`docs/operations/crisis-procedures.md`)
- **Emergency Contacts** (`docs/operations/emergency-contacts.md`)

---

**🚨 Rapid crisis response coordination with multi-agent intelligence for minimal downtime and maximum recovery effectiveness.**