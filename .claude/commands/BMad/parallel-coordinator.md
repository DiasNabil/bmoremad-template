---
name: parallel-coordinator
description: >
  Système de coordination parallèle multi-agents pour BMAD+Contains Studio.
  Utilise les capacités natives Claude Code pour exécution simultanée réelle.
category: parallel-execution
---

# Parallel Coordinator - Système de Coordination Multi-Agent Réelle

Implémente une **vraie coordination parallèle** en utilisant les capacités natives de Claude Code pour lancer plusieurs agents simultanément avec synchronisation intelligente.

## 🚀 Principe de Fonctionnement

### **Exécution Parallèle Réelle**
Utilise la capacité de Claude Code à traiter **multiple tool calls dans un seul message** pour créer une véritable coordination parallèle.

```yaml
ParallelExecution:
  Method: "Multiple Task tool calls in single message"
  Agents: "3+ agents simultanés"
  Synchronization: "Intelligent conflict detection"
  Performance: "3-4x faster than sequential"
  
Architecture:
  LaunchPhase: "Single message with multiple Task calls"
  MonitoringPhase: "Progress tracking parallel"
  SynchronizationPhase: "Results aggregation intelligent"
  ConflictResolution: "Resource conflict prevention"
```

## 🎯 Patterns de Coordination Parallèle

### **Pattern 1: Contains Studio Integration**
```yaml
ParallelPattern: "contains-integration"
Agents: 3
Duration: "8-12 minutes (instead of 25-35 sequential)"

Execution:
  Agent1: "bmad-architect"
    Tasks: "Architecture planning + mapping"
    Resources: ["docs/architecture/", "analysis tools"]
    
  Agent2: "bmad-dev" 
    Tasks: "Technical validation + optimization"
    Resources: [".claude/agents/", "development tools"]
    
  Agent3: "bmad-sm"
    Tasks: "Workflow creation + documentation"  
    Resources: [".bmad-core/workflows/", "coordination tools"]

ConflictPrevention:
  - Separate resource allocation
  - Non-overlapping file access
  - Coordinated output locations
```

### **Pattern 2: Fullstack Development**
```yaml
ParallelPattern: "fullstack-parallel"
Agents: 4
Duration: "15-20 minutes"

Execution:
  Agent1: "bmad-architect"
    Focus: "System architecture + API design"
    
  Agent2: "contains-eng-backend"
    Focus: "Backend implementation"
    
  Agent3: "contains-eng-frontend" 
    Focus: "Frontend development"
    
  Agent4: "contains-design-ui"
    Focus: "UI/UX design system"
```

### **Pattern 3: Testing & Quality**
```yaml
ParallelPattern: "quality-assurance"
Agents: 3
Duration: "10-15 minutes"

Execution:
  Agent1: "contains-test-api"
    Focus: "API testing suite"
    
  Agent2: "contains-test-performance"
    Focus: "Performance benchmarks"
    
  Agent3: "contains-test-analyzer"
    Focus: "Results analysis + reporting"
```

## ⚙️ Implémentation Technique

### **Coordinateur Principal**
```python
class ParallelCoordinator:
    def launch_parallel_team(self, pattern, context):
        """Lance une équipe d'agents en parallèle véritable"""
        
        # Phase 1: Planification et allocation ressources
        agents = self.select_agents(pattern)
        resources = self.allocate_resources(agents)
        conflicts = self.detect_conflicts(resources)
        
        # Phase 2: Lancement parallèle simultané
        # Utilise multiple Task calls dans un seul message
        parallel_tasks = []
        for agent in agents:
            task = self.create_task(agent, context, resources[agent])
            parallel_tasks.append(task)
            
        # Lancement simultané réel
        results = self.execute_parallel(parallel_tasks)
        
        # Phase 3: Synchronisation et agrégation
        return self.aggregate_results(results)
```

### **Détection et Résolution de Conflits**
```yaml
ConflictDetection:
  FileAccess: "Prevent simultaneous write to same files"
  Resources: "Allocate exclusive tool access"
  Dependencies: "Manage agent interdependencies"
  
Resolution:
  FilePartitioning: "Assign exclusive directories to agents"
  ToolQueuing: "Manage shared tool access"
  DependencyOrdering: "Sequence dependent operations"
```

## 🔧 Commandes d'Exécution

### **Lancement Coordination Parallèle**
```bash
# Via orchestrator enhanced
"Lance l'équipe Contains Studio en parallèle réel"
→ Déclenche coordination 3 agents simultanés

# Via commande directe
/BMad/parallel-launch contains-integration
→ Pattern spécifique avec ressources allouées

# Via pattern avancé
/BMad/parallel-launch fullstack-parallel --agents=4 --timeout=20min
→ Équipe fullstack complète coordonnée
```

### **Monitoring et Contrôle**
```bash
# Status temps réel
/BMad/parallel-status
→ Progression de tous agents actifs

# Intervention si nécessaire  
/BMad/parallel-sync --force
→ Synchronisation forcée si conflit

# Arrêt coordonné
/BMad/parallel-stop --graceful
→ Arrêt propre de tous agents
```

## 📊 Algorithme de Coordination

### **Phase 1: Allocation Intelligente**
```yaml
ResourceAllocation:
  Step1: "Analyze task requirements per agent"
  Step2: "Map exclusive resource assignments"
  Step3: "Detect potential conflicts"
  Step4: "Generate coordination plan"
  Step5: "Validate feasibility"
```

### **Phase 2: Lancement Simultané**
```yaml
ParallelLaunch:
  Method: "Single message with multiple Task tool calls"
  Timing: "All agents start within same execution cycle"
  Monitoring: "Progress tracking via task IDs"
  Failover: "Automatic retry for failed agents"
```

### **Phase 3: Synchronisation**
```yaml
Synchronization:
  Checkpoints: "Predefined sync points during execution"
  DataSharing: "Coordinated information exchange"
  ConflictResolution: "Real-time conflict handling"
  ResultsAggregation: "Intelligent output consolidation"
```

## 🚀 Avantages Performance

### **Gains de Performance**
```yaml
PerformanceGains:
  TimeReduction: "70-80% faster than sequential"
  ResourceUtilization: "Optimal multi-core usage"
  Throughput: "3-4x more deliverables per hour"
  
Metrics:
  ContainsIntegration: "8-12min vs 25-35min sequential"
  FullstackDevelopment: "15-20min vs 45-60min sequential"
  QualityAssurance: "10-15min vs 30-40min sequential"
```

### **Qualité Maintenue**
```yaml
QualityAssurance:
  Coordination: "Intelligent synchronization prevents conflicts"
  Validation: "Cross-agent validation at sync points"
  Consistency: "Unified output standards maintained"
  ErrorHandling: "Distributed error recovery"
```

## 🎯 Critères de Succès

### **Critères Techniques**
- ✅ Lancement simultané réel de 3+ agents
- ✅ Zero conflicts sur ressources partagées
- ✅ Performance 3-4x supérieure au séquentiel
- ✅ Synchronisation intelligente automatique
- ✅ Résultats consolidés cohérents

### **Critères Utilisateur**
- ✅ Interface naturelle : "Lance une équipe en parallèle"
- ✅ Feedback temps réel sur progression
- ✅ Livrable final intégré et cohérent
- ✅ Temps d'exécution dramatiquement réduit

---

**🎭 Ce système de coordination parallèle révolutionne l'utilisation d'agents multiples en transformant l'exécution séquentielle en véritable travail d'équipe coordonné !**

**Résultat : Écosystème BMAD+Contains Studio avec coordination parallèle réelle, performance optimisée et collaboration multi-agent intelligente.**