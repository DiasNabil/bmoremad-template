---
name: sync-dependencies
description: >
  Cross-team dependency management workflow with multi-agent coordination for
  dependency mapping, conflict resolution, and synchronized delivery planning.
category: dependency-management
---

# Cross-Team Dependency Management - BMAD Synchronization Workflow

Orchestrates intelligent dependency management across teams and projects through multi-agent coordination for seamless delivery synchronization.

## Usage
```bash
/BMad/sync-dependencies [scope]     # Start dependency synchronization
/BMad/map-dependencies             # Comprehensive dependency mapping
/BMad/resolve-conflicts            # Dependency conflict resolution
/BMad/plan-delivery               # Synchronized delivery planning
/BMad/track-dependencies          # Ongoing dependency monitoring
```

## Dependency Management Team Structure

### **Discovery & Mapping Team (Parallel - 15-20 minutes)**
```yaml
DiscoveryTeam:
  Agent1: "bmad-analyst"
    Role: "dependency-mapper"
    Tasks: ["system-dependency-analysis", "data-flow-mapping", "integration-points-identification"]
    MCP_Integration: ["github", "filesystem", "postgresql"]
    Focus: ["code-dependencies", "data-dependencies", "service-dependencies"]
    Outputs: ["docs/dependencies/dependency-map.md"]
    
  Agent2: "bmad-architect"
    Role: "integration-analyst"
    Tasks: ["api-dependency-analysis", "service-mesh-mapping", "architectural-coupling-assessment"]
    MCP_Integration: ["filesystem", "github"]
    Focus: ["api-contracts", "service-boundaries", "architectural-dependencies"]
    Outputs: ["docs/dependencies/integration-analysis.md"]
    
  Agent3: "contains-eng-backend"
    Role: "technical-dependency-specialist"
    Tasks: ["library-dependency-audit", "version-compatibility-check", "performance-dependency-analysis"]
    MCP_Integration: ["github", "filesystem", "redis"]
    Focus: ["third-party-libraries", "internal-modules", "performance-critical-paths"]
    Outputs: ["docs/dependencies/technical-dependencies.md"]
    
  Agent4: "bmad-pm"
    Role: "business-dependency-coordinator"
    Tasks: ["feature-dependency-mapping", "team-dependency-analysis", "timeline-dependency-assessment"]
    MCP_Integration: ["notion", "filesystem"]
    Focus: ["feature-interdependencies", "team-coordination", "delivery-dependencies"]
    Outputs: ["docs/dependencies/business-dependencies.md"]
```

### **Resolution & Planning Team (Sequential - 10-15 minutes)**
```yaml
ResolutionTeam:
  Agent1: "bmad-sm"
    Role: "conflict-resolver"
    Tasks: ["dependency-conflict-identification", "resolution-strategy-development"]
    Dependencies: ["mapping-complete"]
    Outputs: ["docs/dependencies/conflict-resolution.md"]
    
  Agent2: "bmad-pm" 
    Role: "delivery-planner"
    Tasks: ["synchronized-delivery-planning", "milestone-coordination", "risk-mitigation-planning"]
    Dependencies: ["conflict-resolution-complete"]
    Outputs: ["docs/dependencies/delivery-plan.md"]
```

## Dependency Categories & Analysis

### **Technical Dependencies**
```yaml
TechnicalDependencies:
  Code_Level:
    - "Module interdependencies"
    - "Function call hierarchies"
    - "Class inheritance chains"
    - "Interface implementations"
    
  Service_Level:
    - "API endpoint dependencies"
    - "Database shared resources"
    - "Message queue dependencies"
    - "Cache dependencies"
    
  Infrastructure_Level:
    - "Deployment dependencies"
    - "Network connectivity requirements"
    - "Resource sharing constraints"
    - "Security policy dependencies"
    
  External_Dependencies:
    - "Third-party service integrations"
    - "External API dependencies"
    - "Vendor platform requirements"
    - "Compliance framework dependencies"
```

### **Business Dependencies**
```yaml
BusinessDependencies:
  Feature_Dependencies:
    - "Feature prerequisite chains"
    - "User journey dependencies"
    - "Business process workflows"
    - "Compliance requirement flows"
    
  Team_Dependencies:
    - "Cross-team deliverable dependencies"
    - "Expertise sharing requirements"
    - "Resource allocation dependencies"
    - "Review and approval workflows"
    
  Timeline_Dependencies:
    - "Sequential milestone dependencies"
    - "Parallel work coordination"
    - "Market timing constraints"
    - "Regulatory deadline requirements"
```

## Dependency Mapping Techniques

### **Automated Discovery**
```yaml
AutomatedDiscovery:
  Code_Analysis:
    - "Static code analysis for import/require statements"
    - "Dynamic runtime dependency tracking"
    - "Database query relationship mapping"
    - "API call pattern analysis"
    
  Configuration_Analysis:
    - "Docker compose dependencies"
    - "Kubernetes deployment dependencies"
    - "CI/CD pipeline dependencies"
    - "Environment configuration dependencies"
    
  Documentation_Mining:
    - "Architecture document parsing"
    - "API documentation analysis"
    - "README file dependency extraction"
    - "Meeting notes and decision records"
```

### **Manual Assessment**
```yaml
ManualAssessment:
  Expert_Knowledge:
    - "Team member interviews"
    - "Architect consultation"
    - "Historical experience analysis"
    - "Domain expert insights"
    
  Process_Analysis:
    - "Workflow dependency mapping"
    - "Approval process chains"
    - "Communication flow analysis"
    - "Decision-making dependencies"
```

## MCP Server Integration for Dependencies

### **Data Integration**
```yaml
MCP_DependencyIntegration:
  GitHub:
    - Repository dependency analysis
    - Cross-repo integration points
    - Commit dependency tracking
    - Branch dependency mapping
    
  PostgreSQL:
    - Database schema dependencies
    - Cross-table relationship analysis
    - Data flow dependency mapping
    - Transaction dependency chains
    
  Redis:
    - Cache dependency analysis
    - Session dependency mapping
    - Performance bottleneck dependencies
    - Data freshness requirements
    
  Filesystem:
    - Configuration file dependencies
    - Asset dependency chains
    - Build artifact dependencies
    - Documentation dependencies
```

### **Coordination Platform**
```yaml
CoordinationIntegration:
  Notion:
    - Dependency dashboard creation
    - Cross-team collaboration workspace
    - Progress tracking and updates
    - Stakeholder communication hub
    
  ShadCN:
    - UI component dependencies
    - Design system coordination
    - Frontend asset dependencies
    - Style guide synchronization
```

## Dependency Conflict Resolution

### **Conflict Types & Resolution Strategies**
```yaml
ConflictTypes:
  Version_Conflicts:
    - "Library version incompatibilities"
    - "API version mismatches"
    - "Protocol version differences"
    
    Resolution:
      - "Dependency injection patterns"
      - "Adapter pattern implementation"
      - "Gradual migration strategies"
      - "Compatibility layer creation"
    
  Resource_Conflicts:
    - "Shared resource contention"
    - "Performance bottleneck competition"
    - "Database lock conflicts"
    
    Resolution:
      - "Resource pooling strategies"
      - "Load balancing implementation"
      - "Caching layer optimization"
      - "Queue-based processing"
    
  Timeline_Conflicts:
    - "Delivery milestone misalignment"
    - "Development sequence conflicts"
    - "Testing dependency bottlenecks"
    
    Resolution:
      - "Parallel development strategies"
      - "Mock/stub implementation"
      - "Incremental delivery planning"
      - "Risk-based prioritization"
```

### **Resolution Prioritization**
```yaml
ResolutionPrioritization:
  Critical_Path_Dependencies:
    - "Block multiple teams/features"
    - "Impact customer-facing deliverables"
    - "Affect regulatory compliance"
    - "Influence revenue generation"
    
  High_Impact_Dependencies:
    - "Affect team productivity"
    - "Impact quality or performance"
    - "Influence technical debt"
    - "Affect system reliability"
    
  Medium_Impact_Dependencies:
    - "Create minor delays"
    - "Require workaround solutions"
    - "Affect non-critical features"
    - "Influence developer experience"
```

## Synchronized Delivery Planning

### **Delivery Coordination Strategies**
```yaml
DeliveryStrategies:
  Milestone_Synchronization:
    - "Cross-team milestone alignment"
    - "Dependency checkpoint creation"
    - "Integration testing coordination"
    - "Release train synchronization"
    
  Incremental_Delivery:
    - "Feature flag coordination"
    - "Gradual rollout planning"
    - "Backward compatibility maintenance"
    - "Version migration strategies"
    
  Parallel_Development:
    - "Independent work stream identification"
    - "Interface contract establishment"
    - "Mock/stub coordination"
    - "Integration point planning"
```

### **Risk Mitigation Planning**
```yaml
RiskMitigation:
  Dependency_Failures:
    - "Alternative solution preparation"
    - "Fallback mechanism implementation"
    - "Graceful degradation planning"
    - "Emergency response procedures"
    
  Timeline_Risks:
    - "Buffer time allocation"
    - "Critical path monitoring"
    - "Resource reallocation plans"
    - "Scope adjustment strategies"
    
  Quality_Risks:
    - "Comprehensive testing strategies"
    - "Quality gate coordination"
    - "Integration validation planning"
    - "Performance benchmarking"
```

## Monitoring & Tracking

### **Dependency Health Monitoring**
```yaml
HealthMonitoring:
  Technical_Health:
    - "API availability monitoring"
    - "Performance degradation alerts"
    - "Error rate threshold monitoring"
    - "Resource utilization tracking"
    
  Delivery_Health:
    - "Milestone progress tracking"
    - "Dependency completion status"
    - "Quality gate pass/fail rates"
    - "Team velocity correlation"
    
  Business_Health:
    - "Feature delivery alignment"
    - "Customer impact assessment"
    - "Revenue impact tracking"
    - "Stakeholder satisfaction monitoring"
```

### **Early Warning Systems**
```yaml
EarlyWarning:
  Technical_Alerts:
    - "Performance regression detection"
    - "Breaking change identification"
    - "Compatibility issue warnings"
    - "Security vulnerability alerts"
    
  Process_Alerts:
    - "Milestone delay predictions"
    - "Resource constraint warnings"
    - "Quality trend deterioration"
    - "Communication breakdown indicators"
```

## Success Metrics & KPIs

### **Dependency Management Metrics**
```yaml
DependencyKPIs:
  Discovery_Effectiveness:
    - "Dependency identification accuracy: >95%"
    - "Hidden dependency detection rate: >80%"
    - "Mapping completeness: >90%"
    - "Update frequency: Weekly"
    
  Resolution_Efficiency:
    - "Conflict resolution time: <48 hours"
    - "Resolution success rate: >90%"
    - "Stakeholder satisfaction: >8.0"
    - "Re-occurrence rate: <10%"
    
  Delivery_Synchronization:
    - "On-time delivery rate: >85%"
    - "Cross-team coordination efficiency: >80%"
    - "Integration success rate: >95%"
    - "Rollback rate due to dependencies: <5%"
```

## Natural Language Dependency Triggers

### **Dependency Management Commands**
```yaml
DependencyTriggers:
  - "Map all project dependencies"
  - "Resolve dependency conflicts"
  - "Synchronize team deliveries"
  - "Check dependency health"
  - "Plan coordinated release"
  - "Analyze integration points"
  - "Track dependency progress"
```

### **Contextual Detection**
```python
def detect_dependency_context(user_input, project_state):
    dependency_indicators = [
        "depends on", "blocks", "requires", "needs",
        "integration", "coordination", "synchronize",
        "cross-team", "shared", "coupled"
    ]
    
    complexity_indicators = [
        len(project_state.get("teams", [])) > 2,
        len(project_state.get("services", [])) > 5,
        project_state.get("external_integrations", 0) > 3
    ]
    
    return (any(indicator in user_input.lower() for indicator in dependency_indicators) or
            any(complexity_indicators))
```

## Integration with BMAD Workflows

### **Sprint Planning Integration**
```yaml
SprintIntegration:
  DependencyValidation: "Check dependencies before sprint commitment"
  CrossTeamCoordination: "Coordinate dependent stories across teams"
  RiskAssessment: "Assess dependency risks in sprint planning"
```

### **Release Planning Integration**
```yaml
ReleaseIntegration:
  FeatureDependencies: "Map feature dependencies for release planning"
  TeamCoordination: "Coordinate cross-team release activities"
  IntegrationTesting: "Plan integration testing for dependent features"
```

## Deliverables

### **Mapping & Analysis**
- **Comprehensive Dependency Map** (`docs/dependencies/dependency-map.md`)
- **Integration Analysis** (`docs/dependencies/integration-analysis.md`)
- **Technical Dependencies Report** (`docs/dependencies/technical-dependencies.md`)
- **Business Dependencies Overview** (`docs/dependencies/business-dependencies.md`)

### **Resolution & Planning**
- **Conflict Resolution Plan** (`docs/dependencies/conflict-resolution.md`)
- **Synchronized Delivery Plan** (`docs/dependencies/delivery-plan.md`)
- **Risk Mitigation Strategy** (`docs/dependencies/risk-mitigation.md`)
- **Coordination Roadmap** (`docs/dependencies/coordination-roadmap.md`)

### **Monitoring & Tracking**
- **Dependency Health Dashboard** (Notion integration)
- **Progress Tracking Reports** (`docs/dependencies/progress-reports/`)
- **Alert Configuration** (`docs/dependencies/monitoring-config.md`)
- **Lessons Learned** (`docs/dependencies/lessons-learned.md`)

---

**🔄 Intelligent cross-team dependency management with multi-agent coordination for seamless delivery synchronization and conflict resolution.**