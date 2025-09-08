---
name: evolve-system
description: >
  System evolution planning workflow with multi-agent coordination for architecture
  modernization, technology migration, and strategic system transformation.
category: system-evolution
---

# System Evolution - BMAD Strategic Transformation Workflow

Orchestrates intelligent system evolution through coordinated multi-agent analysis, planning, and transformation roadmap development.

## Usage
```bash
/BMad/evolve-system [scope]        # Start system evolution assessment
/BMad/evolution-audit             # Current system assessment
/BMad/modernization-plan          # Architecture modernization roadmap
/BMad/migration-strategy          # Technology migration planning
/BMad/transformation-roadmap      # Strategic transformation plan
```

## Evolution Assessment Team

### **Current State Analysis (Parallel - 20-30 minutes)**
```yaml
CurrentStateTeam:
  Agent1: "bmad-architect"
    Role: "system-archaeologist"
    Tasks: ["architecture-audit", "technical-landscape-mapping"]
    MCP_Integration: ["filesystem", "github", "postgresql"]
    Outputs: ["docs/evolution/current-architecture.md"]
    
  Agent2: "bmad-analyst"
    Role: "data-analyst"
    Tasks: ["usage-analytics", "performance-profiling", "growth-trends"]
    MCP_Integration: ["postgresql", "redis", "filesystem"]
    Outputs: ["docs/evolution/system-analytics.md"]
    
  Agent3: "contains-eng-backend"
    Role: "technical-assessor"
    Tasks: ["code-quality-audit", "dependency-analysis", "security-assessment"]
    MCP_Integration: ["github", "filesystem"]
    Outputs: ["docs/evolution/technical-audit.md"]
    
  Agent4: "contains-test-analyzer"
    Role: "quality-evaluator"
    Tasks: ["testing-maturity-assessment", "reliability-analysis"]
    MCP_Integration: ["github", "filesystem"]
    Outputs: ["docs/evolution/quality-assessment.md"]
```

### **Future State Design (Sequential - 15-25 minutes)**
```yaml
FutureStateTeam:
  Agent1: "bmad-architect"
    Role: "visionary-architect"
    Tasks: ["target-architecture-design", "modernization-blueprint"]
    Dependencies: ["current-state-complete"]
    Outputs: ["docs/evolution/target-architecture.md"]
    
  Agent2: "bmad-pm"
    Role: "transformation-planner"
    Tasks: ["business-case-development", "resource-planning"]
    Dependencies: ["target-architecture-complete"]
    Outputs: ["docs/evolution/transformation-plan.md"]
```

## Evolution Dimensions

### **Technical Evolution**
```yaml
TechnicalDimensions:
  Architecture:
    - "Monolith to microservices migration"
    - "Event-driven architecture adoption"
    - "Cloud-native transformation"
    - "API-first architecture"
    
  Technology:
    - "Legacy language modernization"
    - "Database technology migration"
    - "Framework/library upgrades"
    - "Infrastructure modernization"
    
  Practices:
    - "DevOps transformation"
    - "Continuous deployment adoption"
    - "Observability implementation"
    - "Security-by-design integration"
```

### **Business Evolution**
```yaml
BusinessDimensions:
  Scalability:
    - "Performance optimization"
    - "Horizontal scaling capabilities"
    - "Global distribution readiness"
    - "Multi-tenancy support"
    
  Agility:
    - "Feature delivery acceleration"
    - "Rapid experimentation capability"
    - "A/B testing infrastructure"
    - "Continuous feedback loops"
    
  Compliance:
    - "Security standards alignment"
    - "Regulatory compliance preparation"
    - "Data privacy enhancements"
    - "Audit trail capabilities"
```

## Evolution Strategies

### **Incremental Evolution (Strangler Fig Pattern)**
```yaml
IncrementalStrategy:
  Approach: "Gradual replacement of system components"
  Timeline: "12-24 months"
  Risk: "Low"
  BusinessContinuity: "High"
  
  Phases:
    Phase1: "Identify boundaries and create facades"
    Phase2: "Implement new components alongside old"
    Phase3: "Route traffic to new components"
    Phase4: "Deprecate old components"
  
  BestFor:
    - "Mission-critical systems"
    - "Large monolithic applications"
    - "High availability requirements"
    - "Limited downtime tolerance"
```

### **Revolutionary Evolution (Big Bang Approach)**
```yaml
RevolutionaryStrategy:
  Approach: "Complete system replacement"
  Timeline: "6-12 months"
  Risk: "High"
  BusinessContinuity: "Medium"
  
  Phases:
    Phase1: "Build complete new system"
    Phase2: "Comprehensive testing and validation"
    Phase3: "Data migration and cutover"
    Phase4: "Legacy system decommission"
  
  BestFor:
    - "Small to medium systems"
    - "End-of-life technologies"
    - "Fundamental architecture changes"
    - "Greenfield opportunities"
```

### **Hybrid Evolution (Selective Modernization)**
```yaml
HybridStrategy:
  Approach: "Strategic component modernization"
  Timeline: "9-18 months"
  Risk: "Medium"
  BusinessContinuity: "High"
  
  Selection Criteria:
    - "Business impact prioritization"
    - "Technical debt concentration"
    - "Integration complexity analysis"
    - "Resource availability alignment"
  
  BestFor:
    - "Complex distributed systems"
    - "Mixed technology landscapes"
    - "Resource-constrained environments"
    - "Risk-averse organizations"
```

## MCP Server Integration for Evolution

### **Assessment & Analysis**
```yaml
MCP_EvolutionIntegration:
  GitHub:
    - Code evolution history analysis
    - Commit pattern identification
    - Developer productivity metrics
    - Repository complexity assessment
    
  PostgreSQL:
    - Data model evolution analysis
    - Query performance trends
    - Schema complexity assessment
    - Usage pattern identification
    
  Redis:
    - Caching strategy effectiveness
    - Performance bottleneck identification
    - Memory usage optimization opportunities
    
  Filesystem:
    - File structure complexity analysis
    - Configuration drift detection
    - Documentation completeness assessment
```

### **Planning & Strategy**
```yaml
StrategyIntegration:
  Notion:
    - Evolution roadmap management
    - Stakeholder communication dashboard
    - Progress tracking and reporting
    
  ShadCN:
    - UI component evolution planning
    - Design system modernization
    - Frontend architecture transformation
```

## Evolution Assessment Framework

### **Technical Maturity Assessment**
```yaml
TechnicalMaturity:
  Architecture:
    - Modularity and coupling assessment
    - Scalability and performance evaluation
    - Security and compliance review
    - Maintainability and technical debt analysis
    
  Development:
    - Code quality and standards adherence
    - Testing maturity and coverage
    - Development process effectiveness
    - DevOps and deployment automation
    
  Operations:
    - Monitoring and observability capabilities
    - Incident response and reliability
    - Performance optimization and tuning
    - Disaster recovery and business continuity
```

### **Business Alignment Assessment**
```yaml
BusinessAlignment:
  Strategic:
    - Business goal alignment
    - Competitive advantage enablement
    - Innovation capability support
    - Market responsiveness enhancement
    
  Operational:
    - Efficiency and productivity gains
    - Cost optimization opportunities
    - Risk reduction and compliance
    - Customer experience improvement
```

## Transformation Roadmap Development

### **Priority Matrix Framework**
```yaml
PriorityMatrix:
  HighImpactHighEffort:
    - "Core architecture transformation"
    - "Major technology migrations"
    - "Complete platform modernization"
    
  HighImpactLowEffort:
    - "Quick wins and optimizations"
    - "Configuration improvements"
    - "Process enhancements"
    
  LowImpactHighEffort:
    - "Nice-to-have modernizations"
    - "Experimental initiatives"
    - "Future-proofing investments"
    
  LowImpactLowEffort:
    - "Maintenance and housekeeping"
    - "Documentation updates"
    - "Small refactoring efforts"
```

### **Risk Assessment & Mitigation**
```yaml
RiskManagement:
  TechnicalRisks:
    - "Integration complexity"
    - "Data migration challenges"
    - "Performance regression"
    - "Security vulnerability introduction"
    
  BusinessRisks:
    - "Service disruption"
    - "Feature delivery delays"
    - "Cost overruns"
    - "Stakeholder resistance"
    
  MitigationStrategies:
    - "Phased rollout approach"
    - "Comprehensive testing strategy"
    - "Rollback and recovery procedures"
    - "Stakeholder communication and training"
```

## Success Metrics & KPIs

### **Technical Metrics**
```yaml
TechnicalKPIs:
  Performance:
    - "Response time improvement: -50%"
    - "Throughput increase: +200%"
    - "Error rate reduction: -90%"
    
  Maintainability:
    - "Code complexity reduction: -40%"
    - "Technical debt ratio: <20%"
    - "Test coverage increase: >90%"
    
  Scalability:
    - "Horizontal scaling capability: 10x"
    - "Resource utilization efficiency: +60%"
    - "Deployment frequency: Daily"
```

### **Business Metrics**
```yaml
BusinessKPIs:
  Agility:
    - "Feature delivery time: -70%"
    - "Time to market: -50%"
    - "Experiment cycle time: -80%"
    
  Efficiency:
    - "Operational cost reduction: -30%"
    - "Developer productivity: +100%"
    - "Incident resolution time: -60%"
    
  Quality:
    - "Customer satisfaction: +25%"
    - "System availability: 99.99%"
    - "Security incident reduction: -95%"
```

## Natural Language Evolution Triggers

### **Evolution Initiation Commands**
```yaml
EvolutionTriggers:
  - "Our system needs modernization"
  - "Plan technology transformation"
  - "Architecture evolution roadmap"
  - "Legacy system migration"
  - "Modernize our platform"
  - "Strategic system upgrade"
  - "Technology stack evolution"
```

### **Contextual Detection**
```python
def detect_evolution_need(context, performance_data):
    evolution_indicators = [
        "legacy", "outdated", "modernize", "migrate",
        "slow performance", "scaling issues",
        "maintenance burden", "competitive disadvantage"
    ]
    
    technical_indicators = [
        performance_data.get("response_time", 0) > 2000,
        performance_data.get("error_rate", 0) > 0.01,
        performance_data.get("technical_debt_ratio", 0) > 0.3
    ]
    
    return (any(indicator in context.lower() for indicator in evolution_indicators) or
            any(technical_indicators))
```

## Integration with BMAD Workflows

### **Architecture Reviews**
```yaml
ArchitectureIntegration:
  EvolutionReview: "Include evolution assessment in arch reviews"
  ModernizationGates: "Evolution checkpoints in quality gates"
  ContinuousEvolution: "Ongoing evolution assessment"
```

### **Strategic Planning**
```yaml
StrategyIntegration:
  BusinessAlignment: "Link evolution to business strategy"
  InnovationRoadmap: "Align with innovation initiatives"
  CompetitiveAdvantage: "Support competitive positioning"
```

## Deliverables

### **Assessment Reports**
- **Current State Analysis** (`docs/evolution/current-state.md`)
- **System Analytics Report** (`docs/evolution/analytics-report.md`)
- **Technical Audit Summary** (`docs/evolution/technical-audit.md`)
- **Quality Assessment** (`docs/evolution/quality-assessment.md`)

### **Strategy Documents**
- **Target Architecture Blueprint** (`docs/evolution/target-architecture.md`)
- **Transformation Roadmap** (`docs/evolution/transformation-roadmap.md`)
- **Migration Strategy** (`docs/evolution/migration-strategy.md`)
- **Risk Assessment & Mitigation** (`docs/evolution/risk-analysis.md`)

### **Implementation Guides**
- **Phase Implementation Plans** (`docs/evolution/phase-plans/`)
- **Testing Strategy** (`docs/evolution/testing-strategy.md`)
- **Rollback Procedures** (`docs/evolution/rollback-procedures.md`)
- **Success Metrics Dashboard** (Notion integration)

---

**🚀 Strategic system evolution with multi-agent intelligence for sustainable technological advancement and competitive advantage.**