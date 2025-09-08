---
name: init-architecture  
description: Initialiser la création d'un document d'architecture BMAD
category: technical-design
---

# Init Architecture - Commande BMAD

Initialise la création d'un document d'architecture selon la méthode BMAD.

## Usage
```bash
/BMad/init-architecture
```

## Workflow
1. **Analyse du contexte** : Type de projet et stack technique
2. **Sélection du template** :
   - `architecture-tmpl.yaml` - Architecture générale
   - `fullstack-architecture-tmpl.yaml` - Applications complètes  
   - `front-end-architecture-tmpl.yaml` - Frontend spécialisé
   - `brownfield-architecture-tmpl.yaml` - Systèmes existants
3. **Exécution** via `create-doc` task
4. **Sauvegarde** dans `docs/architecture.md` (ou sharded)

## Paramètres Automatiques
- **Version** : `architectureVersion: v4` (core-config.yaml)
- **Sharding** : `architectureSharded: true` si configuré
- **Location** : `docs/architecture/` si sharded

## Fichiers de Référence Chargés
- `docs/architecture/coding-standards.md`
- `docs/architecture/tech-stack.md` 
- `docs/architecture/source-tree.md`

## Agent Recommandé
`*agent architect` (Winston) pour l'expertise technique optimale.

## Exemple d'Exécution
```bash
# Via langage naturel
"Définis l'architecture du système" → /BMad/init-architecture

# Via agent architecte
*agent architect
*task create-doc architecture-tmpl
```

## Livrables
- Document d'architecture structuré BMAD v4
- Intégration avec les standards existants
- Base pour l'implémentation développeur