---
name: review-advanced
description: >
  Advanced code review orchestration workflow with multi-agent coordination for
  comprehensive quality assessment, security analysis, and architectural validation.
category: advanced-quality-assurance
---

# Advanced Code Review - BMAD Multi-Agent Quality Orchestration

Orchestrates comprehensive code review through specialized multi-agent analysis covering quality, security, performance, and architectural consistency.

## Usage
```bash
/BMad/review-advanced [target]      # Start advanced review cycle
/BMad/review-quality               # Code quality deep analysis
/BMad/review-security              # Security vulnerability assessment
/BMad/review-performance           # Performance impact analysis
/BMad/review-architecture          # Architectural consistency check
/BMad/review-consolidate           # Consolidate all review findings
```

## Advanced Review Team Structure

### **Primary Review Team (Parallel - 15-25 minutes)**
```yaml
PrimaryReviewTeam:
  Agent1: "contains-eng-backend"
    Role: "code-quality-specialist"
    Tasks: ["code-quality-analysis", "best-practices-validation", "maintainability-assessment"]
    MCP_Integration: ["github", "filesystem"]
    Focus: ["complexity", "readability", "standards-compliance"]
    Outputs: ["docs/reviews/code-quality-report.md"]
    
  Agent2: "contains-test-analyzer"
    Role: "security-specialist"
    Tasks: ["security-vulnerability-scan", "threat-modeling", "compliance-check"]
    MCP_Integration: ["github", "filesystem", "postgresql"]
    Focus: ["vulnerabilities", "security-patterns", "data-protection"]
    Outputs: ["docs/reviews/security-analysis.md"]
    
  Agent3: "bmad-architect"
    Role: "architecture-validator"
    Tasks: ["architectural-consistency", "design-pattern-compliance", "integration-impact"]
    MCP_Integration: ["filesystem", "github"]
    Focus: ["design-patterns", "coupling", "cohesion"]
    Outputs: ["docs/reviews/architecture-review.md"]
    
  Agent4: "contains-eng-devops"
    Role: "performance-analyst"
    Tasks: ["performance-impact-analysis", "scalability-assessment", "resource-usage"]
    MCP_Integration: ["redis", "postgresql", "filesystem"]
    Focus: ["performance", "scalability", "resource-efficiency"]
    Outputs: ["docs/reviews/performance-analysis.md"]
```

### **Synthesis Team (Sequential - 10-15 minutes)**
```yaml
SynthesisTeam:
  Agent1: "bmad-pm"
    Role: "review-coordinator"
    Tasks: ["findings-consolidation", "priority-assessment", "action-planning"]
    Dependencies: ["primary-reviews-complete"]
    Outputs: ["docs/reviews/consolidated-review.md"]
    
  Agent2: "bmad-analyst"
    Role: "metrics-analyst"
    Tasks: ["quality-metrics-analysis", "trend-identification", "improvement-recommendations"]
    Dependencies: ["consolidation-complete"]
    Outputs: ["docs/reviews/quality-metrics.md"]
```

## Review Dimensions & Criteria

### **Code Quality Assessment**
```yaml
CodeQualityDimensions:
  Complexity:
    - "Cyclomatic complexity analysis"
    - "Cognitive complexity evaluation"
    - "Nesting depth assessment"
    - "Function/method length analysis"
    
  Maintainability:
    - "Code readability scoring"
    - "Documentation completeness"
    - "Naming convention adherence"
    - "Code organization structure"
    
  Reliability:
    - "Error handling patterns"
    - "Exception management"
    - "Null safety practices"
    - "Resource management"
    
  Standards:
    - "Coding standards compliance"
    - "Framework best practices"
    - "Industry pattern adherence"
    - "Team convention consistency"
```

### **Security Analysis Framework**
```yaml
SecurityDimensions:
  Vulnerability_Assessment:
    - "SQL injection vulnerability"
    - "XSS attack surface analysis"
    - "Authentication/authorization flaws"
    - "Input validation weaknesses"
    
  Data_Protection:
    - "PII handling compliance"
    - "Data encryption standards"
    - "Secure data transmission"
    - "Data retention policies"
    
  Access_Control:
    - "Permission model validation"
    - "Role-based access implementation"
    - "Privilege escalation risks"
    - "Session management security"
    
  Infrastructure_Security:
    - "Secrets management practices"
    - "Configuration security"
    - "Dependency vulnerability scan"
    - "Container security assessment"
```

### **Performance Impact Analysis**
```yaml
PerformanceDimensions:
  Computational_Efficiency:
    - "Algorithm complexity analysis"
    - "Database query optimization"
    - "Memory usage patterns"
    - "CPU utilization impact"
    
  Scalability_Assessment:
    - "Concurrent access handling"
    - "Resource contention analysis"
    - "Bottleneck identification"
    - "Load distribution patterns"
    
  Resource_Management:
    - "Memory leak detection"
    - "Connection pooling usage"
    - "Caching strategy effectiveness"
    - "Resource cleanup patterns"
```

### **Architectural Consistency**
```yaml
ArchitecturalDimensions:
  Design_Patterns:
    - "Pattern implementation correctness"
    - "Anti-pattern identification"
    - "Design principle adherence"
    - "Architectural layer respect"
    
  Integration_Impact:
    - "API contract consistency"
    - "Service boundary respect"
    - "Data flow integrity"
    - "Dependency management"
    
  Future_Maintainability:
    - "Extension point design"
    - "Configuration management"
    - "Testability considerations"
    - "Monitoring and observability"
```

## MCP Server Integration for Reviews

### **Code Analysis Integration**
```yaml
MCP_ReviewIntegration:
  GitHub:
    - Commit history analysis
    - PR change impact assessment
    - Code evolution patterns
    - Review comment synthesis
    
  Filesystem:
    - Code structure analysis
    - File dependency mapping
    - Configuration consistency check
    - Documentation completeness scan
    
  PostgreSQL:
    - Database schema impact analysis
    - Query performance assessment
    - Data model consistency check
    - Migration impact evaluation
    
  Redis:
    - Caching strategy validation
    - Performance pattern analysis
    - Memory usage optimization
    - Session management review
```

### **Quality Metrics Collection**
```yaml
QualityMetricsIntegration:
  Notion:
    - Quality dashboard updates
    - Review findings tracking
    - Improvement progress monitoring
    - Team performance metrics
    
  ShadCN:
    - UI component quality assessment
    - Design system compliance
    - Frontend performance analysis
    - Accessibility standards check
```

## Review Scoring & Prioritization

### **Quality Scoring Matrix**
```yaml
QualityScoring:
  Excellent (9-10):
    - "Exemplary code quality"
    - "Zero security issues"
    - "Optimal performance"
    - "Perfect architectural alignment"
    
  Good (7-8):
    - "High code quality with minor improvements"
    - "No critical security issues"
    - "Acceptable performance"
    - "Good architectural consistency"
    
  Fair (5-6):
    - "Adequate quality with several improvements needed"
    - "Minor security concerns"
    - "Performance optimization opportunities"
    - "Some architectural inconsistencies"
    
  Poor (3-4):
    - "Below standard quality requiring significant work"
    - "Moderate security issues"
    - "Performance concerns"
    - "Architectural violations"
    
  Unacceptable (1-2):
    - "Unacceptable quality requiring rework"
    - "Critical security vulnerabilities"
    - "Performance blockers"
    - "Major architectural violations"
```

### **Issue Prioritization Framework**
```yaml
IssuePrioritization:
  P0_Critical:
    - "Security vulnerabilities"
    - "Performance blockers"
    - "Architectural violations"
    - "Data corruption risks"
    
  P1_High:
    - "Code quality issues"
    - "Maintainability concerns"
    - "Testing gaps"
    - "Documentation deficiencies"
    
  P2_Medium:
    - "Style guide violations"
    - "Minor performance issues"
    - "Refactoring opportunities"
    - "Best practice deviations"
    
  P3_Low:
    - "Cosmetic improvements"
    - "Optional optimizations"
    - "Future enhancements"
    - "Nice-to-have changes"
```

## Advanced Review Workflows

### **Phase 1: Automated Analysis (5-10 minutes)**
```yaml
AutomatedAnalysis:
  StaticCodeAnalysis:
    - "Syntax and style validation"
    - "Complexity metrics calculation"
    - "Security vulnerability scanning"
    - "Performance pattern detection"
    
  DependencyAnalysis:
    - "Third-party library security scan"
    - "License compliance check"
    - "Version compatibility analysis"
    - "Dependency graph validation"
```

### **Phase 2: Multi-Agent Deep Review (15-25 minutes)**
```yaml
DeepReview:
  ParallelAnalysis:
    - "Specialized agent analysis per dimension"
    - "Cross-functional perspective gathering"
    - "Comprehensive issue identification"
    - "Best practice validation"
    
  QualityGating:
    - "Threshold-based quality gates"
    - "Automated pass/fail determination"
    - "Exception handling for edge cases"
    - "Manual override capabilities"
```

### **Phase 3: Synthesis & Recommendations (10-15 minutes)**
```yaml
SynthesisPhase:
  FindingsConsolidation:
    - "Multi-agent findings aggregation"
    - "Duplicate issue elimination"
    - "Priority and impact assessment"
    - "Actionable recommendation generation"
    
  ImprovementPlanning:
    - "Remediation roadmap creation"
    - "Learning opportunity identification"
    - "Process improvement suggestions"
    - "Future prevention strategies"
```

## Success Metrics & KPIs

### **Quality Metrics**
```yaml
QualityKPIs:
  CodeQuality:
    - "Average quality score: >8.0"
    - "Critical issues per review: <1"
    - "Review coverage: >95%"
    - "Review cycle time: <2 days"
    
  SecurityMetrics:
    - "Security issues per review: <1"
    - "Vulnerability detection rate: >98%"
    - "Security compliance score: >9.0"
    - "Critical vulnerabilities: 0"
    
  PerformanceMetrics:
    - "Performance regression detection: >95%"
    - "Optimization opportunity identification: >80%"
    - "Resource usage improvement: +20%"
```

### **Process Metrics**
```yaml
ProcessKPIs:
  Efficiency:
    - "Review completion time: <4 hours"
    - "Issue resolution time: <24 hours"
    - "Re-review rate: <10%"
    - "Automated detection accuracy: >90%"
    
  Quality:
    - "Post-review defect rate: <2%"
    - "Customer satisfaction: >8.5"
    - "Team learning effectiveness: >8.0"
    - "Process improvement adoption: >85%"
```

## Natural Language Review Triggers

### **Advanced Review Activation**
```yaml
ReviewTriggers:
  - "Run comprehensive code review"
  - "Deep quality analysis needed"
  - "Security review before release"
  - "Architecture consistency check"
  - "Performance impact assessment"
  - "Complete review with all checks"
```

### **Contextual Intelligence**
```python
def determine_review_scope(context, change_type):
    if "security" in context.lower():
        return ["security", "code-quality"]
    elif "performance" in context.lower():
        return ["performance", "code-quality", "architecture"]
    elif "major" in change_type or "breaking" in change_type:
        return ["all-dimensions"]
    else:
        return ["code-quality", "security"]
```

## Integration with BMAD Ecosystem

### **Quality Gates Integration**
```yaml
QualityGateIntegration:
  PreCommit: "Automated review triggers"
  PreMerge: "Comprehensive review requirements"
  PreRelease: "Advanced review with all dimensions"
  PostRelease: "Retrospective review analysis"
```

### **Learning & Improvement**
```yaml
LearningIntegration:
  TeamLearning: "Review findings to learning opportunities"
  ProcessImprovement: "Review metrics to process optimization"
  StandardsEvolution: "Review patterns to standards updates"
  ToolEnhancement: "Review efficiency to tool improvements"
```

## Deliverables

### **Review Reports**
- **Consolidated Review Report** (`docs/reviews/advanced-review-YYYY-MM-DD.md`)
- **Code Quality Analysis** (`docs/reviews/code-quality-report.md`)
- **Security Assessment** (`docs/reviews/security-analysis.md`)
- **Performance Analysis** (`docs/reviews/performance-analysis.md`)
- **Architecture Review** (`docs/reviews/architecture-review.md`)

### **Metrics & Tracking**
- **Quality Metrics Dashboard** (Notion integration)
- **Review Trends Analysis** (`docs/reviews/trends-analysis.md`)
- **Improvement Recommendations** (`docs/reviews/improvement-plan.md`)
- **Learning Opportunities** (`docs/reviews/learning-points.md`)

### **Action Items**
- **Priority Issue List** (`docs/reviews/priority-issues.md`)
- **Remediation Roadmap** (`docs/reviews/remediation-plan.md`)
- **Process Improvements** (`docs/reviews/process-improvements.md`)

---

**🔍 Advanced multi-agent code review orchestration for comprehensive quality assurance and continuous improvement culture.**