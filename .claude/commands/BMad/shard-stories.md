---
name: shard-stories
description: Découper un document BMAD en stories implémentables 
category: agile-management
---

# Shard Stories - Commande BMAD

Découpe un PRD, epic ou feature en stories atomiques implémentables selon BMAD.

## Usage
```bash
/BMad/shard-stories [source-doc]
```

## Workflow
1. **Analyse du document source** (PRD, epic, ou feature description)
2. **Identification des fonctionnalités** atomiques
3. **Génération de stories** avec :
   - Titre descriptif
   - Critères d'acceptation détaillés
   - Définition of Done BMAD
   - Estimation relative
4. **Sauvegarde** dans `docs/stories/` avec pattern `epic-{n}-story-{m}.md`

## Sources Supportées
- Documents PRD (`docs/prd.md` ou `docs/prd/*.md`)  
- Epics existants
- Descriptions de features textuelles
- Requirements brownfield

## Template Utilisé
- `story-tmpl.yaml` - Story standard BMAD
- Pattern de nommage : `epicFilePattern` depuis core-config

## Agent Recommandé  
`*agent sm` (Bob - Scrum Master) pour le découpage optimal.

## Exemple d'Exécution
```bash
# Découpage automatique du PRD
"Découpe ce PRD en stories" → /BMad/shard-stories docs/prd.md

# Via Scrum Master
*agent sm  
*task shard-doc docs/prd.md
```

## Livrables
- Stories individuelles dans `docs/stories/`
- Critères d'acceptation détaillés  
- Ready for development handoff
- Backlog structuré pour sprint planning