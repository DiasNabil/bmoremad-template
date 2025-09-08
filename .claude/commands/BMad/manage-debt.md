---
name: manage-debt
description: >
  Technical debt management workflow with multi-agent coordination for identification,
  prioritization, and systematic remediation across BMAD+Contains Studio ecosystem.
category: technical-debt-management
---

# Technical Debt Management - BMAD Multi-Agent Workflow

Orchestrates intelligent technical debt management through coordinated multi-agent analysis and remediation planning.

## Usage
```bash
/BMad/manage-debt [scope]     # Start debt management cycle
/BMad/debt-analyze           # Deep analysis of current debt
/BMad/debt-prioritize        # Prioritize debt items by impact
/BMad/debt-plan             # Create remediation roadmap
/BMad/debt-track            # Monitor progress on debt items
```

## Multi-Agent Coordination Pattern

### **Debt Discovery & Analysis Team**
```yaml
ParallelExecution:
  Agent1: "bmad-analyst"
    Role: "debt-scanner"
    Tasks: ["codebase-analysis", "metric-collection", "trend-analysis"]
    MCP_Integration: ["filesystem", "github"]
    Outputs: ["docs/debt/analysis-report.md", "docs/debt/metrics.md"]
    
  Agent2: "contains-eng-backend"  
    Role: "technical-reviewer"
    Tasks: ["code-quality-assessment", "architecture-debt-detection"]
    MCP_Integration: ["postgresql", "redis"]
    Outputs: ["docs/debt/technical-debt.md"]
    
  Agent3: "contains-test-analyzer"
    Role: "quality-assessor"
    Tasks: ["test-coverage-gaps", "performance-bottlenecks"]
    MCP_Integration: ["github", "filesystem"]
    Outputs: ["docs/debt/quality-gaps.md"]
```

### **Prioritization & Planning Team**
```yaml
SequentialExecution:
  Agent1: "bmad-pm"
    Role: "business-impact-analyzer"
    Tasks: ["business-impact-assessment", "roi-calculation"]
    Inputs: ["debt analysis reports"]
    Outputs: ["docs/debt/business-impact.md"]
    
  Agent2: "bmad-architect" 
    Role: "remediation-planner"
    Tasks: ["remediation-strategies", "architecture-improvements"]
    Inputs: ["technical debt + business impact"]
    Outputs: ["docs/debt/remediation-plan.md"]
```

## Workflow Phases

### **Phase 1: Debt Discovery (Parallel)**
```yaml
Discovery:
  Duration: "15-20 minutes"
  Agents: 3
  Synchronization: "discovery_complete"
  
  Tasks:
    - Automated code analysis (complexity, duplication, violations)
    - Performance profiling and bottleneck identification  
    - Test coverage analysis and quality gaps
    - Documentation debt assessment
    - Dependency vulnerability scanning
```

### **Phase 2: Impact Assessment (Sequential)**
```yaml
Assessment:
  Duration: "10-15 minutes"
  Agents: 2
  Dependencies: ["discovery_complete"]
  
  Tasks:
    - Business impact quantification
    - Development velocity impact analysis
    - Risk assessment (security, maintenance, scalability)
    - Cost-benefit analysis for remediation
```

### **Phase 3: Remediation Planning**
```yaml
Planning:
  Duration: "8-12 minutes"
  Agent: "bmad-architect"
  Dependencies: ["assessment_complete"]
  
  Tasks:
    - Prioritization matrix creation
    - Remediation roadmap development
    - Resource allocation planning
    - Timeline estimation
```

## MCP Server Integration

### **Data Collection**
```yaml
MCP_Servers:
  filesystem:
    - Code complexity metrics collection
    - File change frequency analysis
    - Documentation completeness assessment
    
  github:
    - Commit history analysis
    - PR review patterns
    - Issue tracking correlation
    
  postgresql/redis:
    - Performance query analysis
    - Data model debt identification
```

### **Automation Integration**
```yaml
Automation:
  NotionIntegration:
    - Debt tracking dashboard
    - Progress monitoring
    - Team collaboration space
    
  ShadCN:
    - UI debt identification
    - Component optimization opportunities
```

## Debt Categories & Patterns

### **Code Debt**
```yaml
CodeDebt:
  Complexity: "Cyclomatic complexity > threshold"
  Duplication: "Code duplication > 10%"  
  Coverage: "Test coverage < 80%"
  Standards: "Coding standard violations"
  Documentation: "Missing or outdated docs"
```

### **Architecture Debt**  
```yaml
ArchitectureDebt:
  Coupling: "High coupling between modules"
  Cohesion: "Low cohesion within modules"
  Patterns: "Anti-patterns identified"
  Performance: "Performance bottlenecks"
  Scalability: "Scalability limitations"
```

### **Process Debt**
```yaml
ProcessDebt:
  Testing: "Manual testing overhead"
  Deployment: "Manual deployment steps"
  Monitoring: "Missing observability"
  Documentation: "Process documentation gaps"
```

## Success Metrics

### **Quantitative Metrics**
```yaml
Metrics:
  TechnicalDebtRatio: "< 20% (Industry standard)"
  CodeComplexity: "Average complexity reduction"
  TestCoverage: "> 80% target"
  BuildTime: "< 5 minutes CI/CD"
  DeploymentFrequency: "Daily deployments capability"
```

### **Qualitative Outcomes**
```yaml
Outcomes:
  DeveloperVelocity: "Reduced friction in development"
  CodeMaintainability: "Easier to understand and modify"
  SystemReliability: "Reduced production incidents"
  TeamMorale: "Less frustration with legacy code"
```

## Natural Language Triggers

### **Debt Management Commands**
```yaml
Triggers:
  - "Analyze technical debt"
  - "What's our tech debt status?"  
  - "Prioritize code cleanup"
  - "Plan debt remediation"
  - "Technical debt assessment"
  - "Code quality review"
```

### **Contextual Detection**
```python
def detect_debt_management_need(context):
    indicators = [
        "slow development velocity",
        "increasing bugs",
        "deployment issues",
        "code quality concerns",
        "refactoring needed"
    ]
    return any(indicator in context.lower() for indicator in indicators)
```

## Integration with Existing Workflows

### **Brownfield Projects**
```yaml
Integration:
  BrownfieldEnhancement:
    - Start with debt analysis before new features
    - Debt remediation as part of enhancement stories
    - Quality gates include debt reduction targets
```

### **Sprint Planning**
```yaml
SprintIntegration:
  DebtStories: "20% sprint capacity for debt"
  QualityGates: "Debt reduction targets per sprint"
  Tracking: "Debt metrics in sprint retrospectives"
```

## Deliverables

### **Analysis Reports**
- **Debt Analysis Report** (`docs/debt/analysis-report.md`)
- **Technical Debt Inventory** (`docs/debt/technical-debt.md`)
- **Quality Gaps Assessment** (`docs/debt/quality-gaps.md`)
- **Business Impact Analysis** (`docs/debt/business-impact.md`)

### **Planning Documents**
- **Remediation Roadmap** (`docs/debt/remediation-plan.md`)
- **Priority Matrix** (`docs/debt/priority-matrix.md`)
- **Resource Allocation Plan** (`docs/debt/resource-plan.md`)

### **Tracking Tools**
- **Debt Dashboard** (Notion integration)
- **Progress Metrics** (automated collection)
- **Team Collaboration Space** (coordinated updates)

---

**🔧 Systematic technical debt management with multi-agent intelligence for sustainable code quality and development velocity.**