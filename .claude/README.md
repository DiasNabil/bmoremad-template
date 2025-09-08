# Claude Code Configuration - BMAD Template

Configuration technique de l'écosystème BMAD pour Claude Code avec 20+ agents spécialisés, workflows automatisés et infrastructure MCP.

## 📁 Structure Technique

```
.claude/
├── agents/                     # 20+ agents spécialisés
│   ├── bmad-*.md              # Core BMAD (6 agents)
│   └── Contains-Studio/       # Agents spécialisés (14+ agents)
│       ├── Design/           # UI/UX (3 agents)
│       ├── Engineering/      # Backend/DevOps/Frontend (4 agents)
│       ├── Product/          # Product Management (2 agents)
│       └── Testing/          # QA/Performance (5 agents)
├── commands/BMad/             # 15+ workflows automatisés
├── hooks/                     # Hooks de validation
└── output-styles/             # Styles de sortie formatés
```

## 🤖 Agents par Spécialité

### Core BMAD (6 agents)
| Agent | Rôle | Usage |
|-------|------|-------|
| `bmad-orchestrator` | Coordination master | `*agent orchestrator` |
| `bmad-analyst` | Analyse données/métier | `*agent analyst` |
| `bmad-architect` | Architecture système | `*agent architect` |
| `bmad-dev` | Développement | `*agent dev` |
| `bmad-sm` | Scrum Master | `*agent sm` |
| `bmad-parallel-orchestrator` | Coordination parallèle | Auto-invoqué |

### Contains Studio - Design (3 agents)
| Agent | Spécialité | Usage |
|-------|------------|-------|
| `contains-design-ui` | UI/UX Design | `*contains-design-ui` |
| `contains-design-ux-researcher` | UX Research | `*contains-design-ux-researcher` |
| `contains-design-whimsy` | Design créatif | `*contains-design-whimsy` |

### Contains Studio - Engineering (4 agents)
| Agent | Spécialité | Usage |
|-------|------------|-------|
| `contains-eng-backend-architect` | Architecture backend | `*contains-eng-backend-architect` |
| `contains-eng-devops` | Infrastructure/DevOps | `*contains-eng-devops` |
| `contains-eng-frontend` | Développement frontend | `*contains-eng-frontend` |
| `contains-eng-prototyper` | Prototypage rapide | `*contains-eng-prototyper` |

### Contains Studio - Testing (5 agents)
| Agent | Spécialité | Usage |
|-------|------------|-------|
| `contains-test-api` | Tests API | `*contains-test-api` |
| `contains-test-analyzer` | Analyse métriques | `*contains-test-analyzer` |
| `contains-test-automation` | Automatisation tests | `*contains-test-automation` |
| `contains-test-evaluator` | Évaluation qualité | `*contains-test-evaluator` |
| `contains-test-performance` | Tests performance | `*contains-test-performance` |

### Contains Studio - Product (2 agents)
| Agent | Spécialité | Usage |
|-------|------------|-------|
| `contains-product-prioritizer` | Priorisation features | `*contains-product-prioritizer` |
| `contains-workflow-optimizer` | Optimisation processus | `*contains-workflow-optimizer` |

## 🚀 Commandes /BMad/ Disponibles

### Workflows Core
```bash
/BMad/init-prd              # PRD selon BMAD v4
/BMad/init-architecture     # Planification architecture  
/BMad/shard-stories         # Décomposition user stories
/BMad/run-next-story        # Exécution développement
/BMad/qa-gate              # Validation qualité
```

### Workflows Avancés
```bash
/BMad/manage-debt           # Gestion dette technique
/BMad/crisis-response       # Réponse incident production
/BMad/evolve-system         # Évolution architecture
/BMad/review-advanced       # Review code multi-dimensionnel
/BMad/sync-dependencies     # Coordination dépendances
/BMad/monitor-impact        # Analytics post-déploiement
/BMad/integrate-feedback    # Intégration feedback utilisateur
```

### Coordination Multi-Agent
```bash
/BMad/contains-integration  # Patterns Contains Studio
/BMad/parallel-coordinator  # Exécution parallèle optimisée
/BMad/team-coordination     # Coordination équipes multi-agents
```

### Motion Animation (1 workflow)
```bash
/BMad/motion-animation-system      # Système animations avancé
```

## 🔧 Configuration Hooks

### Hook de Validation MCP
**Fichier:** `hooks/mcp-coordination-validator.bat`

**Fonctionnalités:**
- Validation coordination agents parallèles
- Monitoring ressources actives
- Gestion verrous concurrents
- Logs audit centralisés
- Limitation 3 agents max simultanés

**Usage automatique:** Exécuté avant chaque opération multi-agent

## 🎨 Styles de Sortie

### Style DevOps Technique
**Fichier:** `output-styles/containers-eng-devops.md`

**Format structuré:**
```
🔧 INFRASTRUCTURE MCP - [ACTION]
📋 ANALYSE: [Points techniques]
💾 FICHIERS GÉNÉRÉS: [Scripts .bat/.ps1]  
⚡ COMMANDES: [Commandes exactes]
🎯 MÉTRIQUES CIBLES: [Seuils performance]
```

## 🛠️ Usage Technique

### Invocation Directe d'Agent
```bash
*contains-eng-backend-architect
# Active l'agent avec expertise complète
```

### Workflows Avec Coordination
```bash
/BMad/team-launch greenfield
# Lance équipe complète projet nouveau
```

### Mode Langage Naturel
```bash
"Crée une API robuste avec tests complets"
→ Auto-routing vers contains-eng-backend + contains-test-*
```

## 🔗 Intégration MCP

### Serveurs Essentiels
- **GitHub:** Gestion PR + workflows
- **Memory:** Intelligence collective 
- **Filesystem:** Gestion fichiers virtualisée
- **Redis:** Cache + coordination
- **PostgreSQL:** Base données + audit

### Points de Coordination
1. **Hook validation** avant multi-agent
2. **Locks ressources** partagées
3. **Audit centralisé** toutes actions
4. **Métriques performance** temps réel

## 📊 Monitoring & Performance

### KPIs Techniques
- Latence coordination agents: < 10ms
- Agents concurrents max: 32
- Taux utilisation mémoire: > 98%
- Temps réponse MCP: < 15ms

### Logs & Audit
- **Emplacement:** `logs/audit/`
- **Fichiers clés:**
  - `mcp-coordination.log`
  - `active-agents.json`
  - `resource-locks.json`

## 🚨 Sécurité & Compliance

### Validation Automatique
- Hook MCP avant chaque exécution
- Limitation agents simultanés
- Vérification conflits ressources
- Audit trail complet

### Niveau Sécurité
- **Type:** `enterprise_zero_trust`
- **Compliance:** SOC2, GDPR, NIST CSF
- **Rétention:** 7 ans audit logging

## 💡 Personnalisation Agents

### Modification Agent Existant
1. Éditer `.claude/agents/[agent-name].md`
2. Modifier section `tools:` et description
3. Tester avec `*agent [nom]`
4. Valider coordination avec hooks

### Création Nouvel Agent
1. Créer fichier `.claude/agents/mon-agent.md`
2. Suivre format YAML front-matter
3. Définir outils et mission
4. Ajouter style sortie si spécialisé

### Ajout Nouveau Workflow
1. Créer `.claude/commands/BMad/mon-workflow.md`
2. Documenter usage et paramètres
3. Intégrer dans `bmad-orchestrator.md`
4. Tester coordination multi-agent

## 🔄 Maintenance & Évolution

### Mise à Jour Agents
- Versionning dans front-matter YAML
- Tests régression coordination
- Validation performance hooks
- Documentation changements

### Optimisation Performance
- Monitoring métriques KPI
- Analyse logs coordination
- Ajustement seuils validation
- Optimisation workflows parallèles

---

**🚀 Configuration optimisée pour développement intelligent coordonné avec Claude Code.**