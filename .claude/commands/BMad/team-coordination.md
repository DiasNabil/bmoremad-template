---
name: team-coordination
description: >
  Coordination multi-agents BMAD pour exécution parallèle de tâches compatibles.
  Détection automatique d'opportunités et lancement d'équipes virtuelles.
category: multi-agent-coordination
---

# Team Coordination - Commande BMAD

Orchestre l'exécution **parallèle et coordonnée** de plusieurs agents BMAD sur des tâches compatibles.

## Usage
```bash
/BMad/team-launch [pattern]     # Lance équipe selon pattern détecté
/BMad/team-status              # Status des agents en cours
/BMad/team-sync               # Force point de synchronisation  
/BMad/team-abort              # Arrêt d'urgence tous agents
```

## Patterns de Coordination Pré-Configurés

### 🚀 Greenfield Project Launch
```bash
/BMad/team-launch greenfield
```
**Agents Parallèles :**
- **Analyst** : Market research + competitive analysis
- **Architect** : Tech stack analysis + preliminary architecture  
- **PM** : PRD outline + feature prioritization

**Synchronisation :** Research complete → Detailed PRD + Architecture → Stories

### 📋 Sprint Planning Coordination  
```bash
/BMad/team-launch sprint-planning
```
**Agents Parallèles :**
- **SM** : Story creation from PRD/epics
- **QA** : Test scenarios + acceptance criteria
- **Dev** : Technical feasibility + complexity analysis

**Synchronisation :** Stories + Tests + Analysis → Final sprint backlog

### 🔍 Architecture Review Team
```bash
/BMad/team-launch arch-review
```  
**Agents Parallèles :**
- **Architect** : Design review + improvements
- **QA** : Security review + NFR validation
- **Dev** : Implementation feasibility + performance analysis

**Synchronisation :** Individual reviews → Consolidated recommendations

### 🎯 Release Preparation  
```bash
/BMad/team-launch release-prep
```
**Agents Parallèles :**
- **QA** : Quality gate validation + test results
- **Dev** : Deployment preparation + final testing
- **SM** : Documentation + release notes

**Synchronisation :** All validations → Go/No-Go decision

## Détection Automatique d'Opportunités

### Triggers Langage Naturel
```yaml
AutoDetection:
  "nouveau projet complet": "greenfield"
  "démarrer un projet": "greenfield"  
  "planifier ce sprint": "sprint-planning"
  "préparer le sprint": "sprint-planning"
  "review architecture": "arch-review"
  "valider l'architecture": "arch-review"
  "préparer la release": "release-prep"
  "validation avant prod": "release-prep"
```

### Intelligence Contextuelle
```python
def detect_coordination_opportunity(context, user_request):
    # Analyse du contexte projet
    project_phase = analyze_project_phase(context)
    available_artifacts = scan_docs_folder(context)
    
    # Détection pattern approprié
    if not available_artifacts and "projet" in user_request:
        return "greenfield"
    elif "prd.md" in available_artifacts and "sprint" in user_request:
        return "sprint-planning"  
    elif "architecture.md" in available_artifacts and "review" in user_request:
        return "arch-review"
    
    return suggest_manual_coordination(context, user_request)
```

## Workflow d'Exécution

### Phase 1: Planning & Validation
```yaml
Planning:
  1. Parse user request / detect pattern
  2. Identify required agents for pattern
  3. Check resource availability & conflicts  
  4. Generate execution plan with sync points
  5. Request user confirmation if ambiguous
```

### Phase 2: Resource Allocation
```yaml  
ResourceAllocation:
  1. Create isolated workspaces per agent
  2. Allocate file system permissions
  3. Setup communication channels
  4. Initialize resource locks
  5. Prepare rollback mechanisms
```

### Phase 3: Parallel Execution
```yaml
ParallelExecution:
  1. Launch agents simultaneously via Task tool
  2. Monitor progress and resource usage
  3. Handle synchronization points  
  4. Detect and resolve conflicts
  5. Log all coordination activities
```

### Phase 4: Integration & Cleanup
```yaml
Integration:
  1. Aggregate results from all agents
  2. Validate consistency and completeness
  3. Merge deliverables if needed
  4. Update project documentation
  5. Clean up temporary resources
```

## Gestion des Conflits

### Détection Préventive
```yaml
ConflictPrevention:
  - File path analysis before agent launch
  - Resource dependency mapping
  - Logical conflict detection (e.g., story numbering)
  - Timeline conflict resolution
```

### Résolution Automatique
```yaml  
AutoResolution:
  - Resource queuing for non-critical conflicts
  - Alternative file path suggestions  
  - Sequential fallback for critical conflicts
  - User escalation for complex situations
```

## Monitoring & Observabilité

### Real-Time Status
```bash
# Affichage status temps réel
/BMad/team-status
```
```
🎭 Multi-Agent Coordination Status
├── 📊 Active Agents: 3/5
├── 📁 Resource Locks: docs/prd.md (PM), docs/architecture/ (Architect)
├── ⏱️  Execution Time: 2m 34s
├── 🔄 Next Sync Point: foundation_complete (waiting: market-research)
└── 🎯 Progress: Analyst(85%), Architect(72%), PM(91%)
```

### Audit Trail
```yaml
AuditLogging:
  - Agent launch events with parameters
  - Resource allocation and locks
  - Synchronization points reached
  - Conflict detection and resolution
  - Performance metrics and timings
```

## Sécurité & Rollback

### Safety Mechanisms
```yaml
Safety:
  - Workspace isolation per agent
  - Atomic operations where possible
  - Checkpoint creation before major operations
  - Emergency stop capability
  - Automatic rollback on critical failures
```

### Error Handling
```yaml
ErrorHandling:
  - Graceful degradation to sequential execution
  - Partial result preservation
  - User notification with recovery options
  - Detailed error logging for debugging
  - Learning from failures for future optimization
```

## Exemples d'Usage

### Langage Naturel Conversationnel
```
User: "Je veux démarrer un nouveau projet e-commerce"
→ Auto-détection: Pattern "greenfield"  
→ Lancement: Analyst (market) + Architect (tech) + PM (prd)
→ Coordination automatique jusqu'à PRD + Architecture complets

User: "Prépare le prochain sprint avec ce PRD"  
→ Auto-détection: Pattern "sprint-planning"
→ Lancement: SM (stories) + QA (tests) + Dev (analysis)
→ Synchronisation: Backlog prêt pour développement
```

### Commandes Directes
```bash
# Pattern spécifique
/BMad/team-launch arch-review

# Avec paramètres
/BMad/team-launch greenfield --focus=saas --stack=nodejs

# Monitoring
/BMad/team-status --detailed
/BMad/team-sync --force
```

## 🎭 Contains Studio Integration Status

### **INTEGRATION COMPLETE ✅**

**Total Agents Harmonisés:** 20+ agents coordonnés
- **BMAD Core:** 6 agents (orchestration, development, architecture)
- **Contains Studio:** 13+ agents spécialisés (design, engineering, testing, product)
- **Enhanced Orchestrator:** bmad-orchestrator-enhanced avec routing intelligent

### **Contains Studio Agents Intégrés (13+)**

#### 🎨 Design Excellence (3 agents)
- `contains-design-ui` - UI Design & Design Systems
- `contains-design-ux-researcher` - UX Research & User Insights  
- `contains-design-whimsy` - Creative & Innovative Design

#### 🚀 Engineering Expertise (4 agents)
- `contains-eng-backend-architect` - Enterprise Backend Architecture
- `contains-eng-devops` - DevOps & Infrastructure Automation (YOU ARE HERE 👋)
- `contains-eng-frontend` - Advanced Frontend Development
- `contains-eng-prototyper` - Rapid Prototyping & MVP Development

#### 📊 Product Intelligence (2 agents)
- `contains-product-prioritizer` - Data-Driven Product Prioritization
- `contains-workflow-optimizer` - Process & Workflow Optimization

#### 🧪 Testing Excellence (5 agents)
- `contains-test-api` - Comprehensive API Testing
- `contains-test-performance` - Performance & Load Testing
- `contains-test-analyzer` - Test Results Analysis
- `contains-test-automation` - Test Automation Strategy
- `contains-test-evaluator` - Testing Strategy Evaluation & Coverage Analysis

### **Coordination Patterns Opérationnels (5 workflows hybrides)**

```yaml
Hybrid_Workflows_Status: ✅ OPERATIONAL
  design_system_complete: "UX Research → Architecture → UI Design → Frontend Implementation"
  api_enterprise_robust: "Analysis → Backend Architecture → Development → Testing → Performance"
  sprint_optimization_advanced: "Analysis → Prioritization → Planning → Workflow Optimization"
  deployment_pipeline_secure: "Architecture → DevOps → QA → Validation"
  creative_prototyping_rapid: "Creative → Validation → Prototyping → Polish"
```

### **Intelligence Routing ✅**
- **Langage Naturel Français:** Détection automatique patterns (90%+ précision)
- **Confidence Scoring:** Algorithme intelligent pour recommandations optimales
- **Interface Conversationnelle:** "*hybrid-coordinate" + descriptions naturelles
- **Pattern Matching:** Mots-clés → workflows coordonnés automatiquement

### **MCP Server Configuration ✅**
```yaml
MCP_Integration_Status: ✅ ENTERPRISE_READY
  Contains_Studio_Permissions:
    - Design agents: shadcn, notion, firecrawl, redis (pattern_caching)
    - Engineering agents: github, postgres, redis, filesystem, memory
    - Testing agents: postgres, redis, github, memory (test_pattern_learning)
    - Product agents: notion, memory, redis (prioritization_intelligence)
  Security_Posture: "enterprise_zero_trust"
  Performance_Optimization: "300%+ efficiency gains"
```

## Intégration Workflows Existants

### Compatibility Matrix
```yaml
Integration:
  greenfield-fullstack: "team-launch greenfield → continue with implementation"
  brownfield-enhancement: "team-launch arch-review → targeted improvements"  
  sprint-execution: "team-launch sprint-planning → individual story execution"
  
Hybrid_Extensions:
  bmad-workflows: "Standard BMAD → Contains Studio coordination seamless"
  contains-patterns: "Contains Studio → BMAD core handoff"
  multi-domain: "Cross-domain expertise coordination automatique"
```

### Workflow Extensions
```yaml
Extended Workflows:
  - All existing workflows can trigger team coordination
  - Team coordination can hand-off to individual workflows
  - Contains Studio patterns integrate with BMAD core workflows
  - Seamless hybrid coordination BMAD+Contains Studio
  - Backward compatibility maintained (100%)
  - Forward compatibility with new Contains Studio agents
```

---

**Coordination multi-agents intelligente avec détection automatique et exécution parallèle sécurisée.**