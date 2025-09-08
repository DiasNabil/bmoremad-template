---
name: init-prd
description: Initialiser la création d'un PRD (Product Requirements Document) BMAD
category: project-management
---

# Init PRD - Commande BMAD

Initialise la création d'un Product Requirements Document selon la méthode BMAD.

## Usage
```bash
/BMad/init-prd
```

## Workflow
1. **Détection du contexte** : Greenfield vs Brownfield
2. **Sélection du template** approprié :
   - `prd-tmpl.yaml` pour nouveaux projets
   - `brownfield-prd-tmpl.yaml` pour projets existants  
3. **Exécution de la tâche** `create-doc` avec le bon template
4. **Sauvegarde** dans `docs/prd.md` (ou `docs/prd/` si sharded)

## Paramètres Automatiques
- **Type de projet** : Détecté via analyse du contexte
- **Version** : Basée sur `core-config.yaml` (prdVersion: v4)
- **Location** : `docs/prd.md` ou sharded selon config

## Agent Recommandé
`*agent pm` (John - Product Manager) pour l'exécution optimale.

## Exemple d'Exécution
```bash
# Via orchestrateur
"Je veux créer un PRD" → /BMad/init-prd

# Via agent PM direct  
*agent pm
*task create-doc prd-tmpl
```

## Livrables
- Document PRD structuré selon BMAD v4
- Sauvegardé dans l'emplacement configuré
- Prêt pour découpage en stories