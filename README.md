# BMAD Template

Un template de développement multi-agent utilisant Claude Code avec le framework BMAD (Brain-Inspired Multi-Agent Development) et l'écosystème MCP (Model Context Protocol).

## Vue d'ensemble

Ce template fournit une configuration complète pour le développement collaboratif avec des agents IA spécialisés :

- **6 agents BMAD Core** : Orchestrateur, analyste, architecte, chef de projet, développeur, scrum master
- **14+ agents Contains Studio** : Spécialistes design, engineering, testing, product
- **8 serveurs MCP** : GitHub, Memory, Filesystem, Redis, PostgreSQL, Notion, ShadCN, Firecrawl
- **18+ workflows BMAD** : Commandes `/BMad/` pour automatiser les processus de développement

## Fonctionnalités disponibles

### Configuration Multi-Agent
- Interface naturelle en français avec Claude Code
- Agents spécialisés par domaine (design, développement, test, product)
- Coordination automatique des tâches entre agents
- Workflows pré-définis pour les processus de développement

### Intégration MCP
- Serveurs MCP configurés pour GitHub, bases de données, stockage
- Permissions granulaires par agent
- Configuration sécurisée avec variables d'environnement
- Monitoring et logging centralisés

### Workflows de Développement
- Génération de PRD (Product Requirements Document)
- Architecture technique et design system
- Coordination d'équipe et gestion de projet
- Tests automatisés et validation qualité

## Installation

### Prérequis
- Node.js 18+ 
- Claude Code installé
- Tokens d'accès pour les services externes (GitHub, OpenAI, etc.)

### Configuration

1. **Cloner le template**
   ```bash
   git clone https://github.com/votre-org/bmoremad-template
   cd bmoremad-template
   ```

2. **Installer les dépendances**
   ```bash
   npm install
   ```

3. **Configurer les variables d'environnement**
   ```bash
   cp .env.example .env
   # Éditer .env avec vos tokens
   ```

4. **Valider la configuration MCP**
   ```bash
   npm run validate-mcp
   ```

## Structure du projet

```
bmoremad-template/
├── .claude/                    # Configuration Claude Code
│   ├── agents/                 # Agents spécialisés (20+ agents)
│   ├── commands/BMad/          # Commandes workflow
│   ├── hooks/                  # Automatisation
│   └── output-styles/          # Styles de sortie
├── scripts/                    # Scripts d'automatisation
├── docs/                       # Documentation détaillée
├── project.mcp.json           # Configuration serveurs MCP
├── package.json               # Scripts et dépendances
└── .env.example              # Template variables d'environnement
```

## Démarrage rapide

### Utilisation des agents

1. **Invoquer un agent spécialisé**
   ```
   *bmad-orchestrator coordonne le développement de cette feature
   *contains-design-ui crée les composants de l'interface utilisateur
   *contains-eng-devops configure le pipeline de déploiement
   ```

2. **Utiliser les workflows BMAD**
   ```
   /BMad/init-prd              # Créer un PRD
   /BMad/init-architecture     # Planifier l'architecture
   /BMad/shard-stories         # Découper en user stories
   /BMad/run-next-story        # Développer la prochaine story
   ```

### Validation du setup

```bash
# Vérifier la configuration
npm run health-check

# Valider les serveurs MCP  
npm run validate-mcp

# Tester les agents
npm run test-agents
```

## Agents disponibles

### BMAD Core (6 agents)
- `bmad-orchestrator` : Coordination générale et workflow
- `bmad-analyst` : Analyse de données et business intelligence  
- `bmad-architect` : Architecture technique et système
- `bmad-pm` : Gestion de projet et planification
- `bmad-dev` : Développement et implémentation
- `bmad-sm` : Scrum Master et coordination agile

### Contains Studio (14+ agents)
- **Design** : UI/UX, recherche utilisateur, créativité
- **Engineering** : Backend, DevOps, Frontend, prototypage
- **Testing** : API, performance, analyse, automatisation, évaluation
- **Product** : Priorisation, optimisation workflow

## Configuration MCP

Les serveurs MCP sont configurés dans `project.mcp.json` :

- **GitHub** : Gestion repos, PRs, issues
- **Memory** : Apprentissage inter-projets  
- **Filesystem** : Espaces de travail isolés
- **Redis** : Cache et coordination
- **PostgreSQL** : Base de données analytics
- **Notion** : Documentation et connaissances
- **ShadCN** : Composants UI
- **Firecrawl** : Recherche web intelligente

## Documentation

- **[CLAUDE.md](./CLAUDE.md)** : Configuration détaillée pour Claude Code
- **[Guide utilisateur](./docs/USER_GUIDE.md)** : Utilisation quotidienne et workflows
- **[Référence technique](./docs/TECHNICAL_REFERENCE.md)** : Architecture et configuration avancée
- **[Sécurité](./docs/SECURITY.md)** : Guide sécurité et permissions

## Commandes utiles

```bash
# Validation
npm run validate-mcp        # Valider config MCP
npm run health-check        # Vérification santé système

# Développement  
npm run dev                 # Mode développement
npm run test                # Lancer les tests
npm run build               # Construire le projet

# Monitoring
npm run monitor             # Monitoring agents
npm run audit               # Audit sécurité
```

## Support et contribution

- **Issues** : [GitHub Issues](https://github.com/votre-org/bmoremad-template/issues)
- **Discussions** : [GitHub Discussions](https://github.com/votre-org/bmoremad-template/discussions)  
- **Wiki** : [Documentation communautaire](https://github.com/votre-org/bmoremad-template/wiki)

## Licence

MIT License - Voir [LICENSE](./LICENSE) pour plus de détails.