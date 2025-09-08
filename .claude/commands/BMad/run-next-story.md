---
name: run-next-story
description: Exécuter la prochaine story du backlog BMAD
category: development
---

# Run Next Story - Commande BMAD

Lance l'implémentation de la prochaine story prioritaire du backlog BMAD.

## Usage
```bash
/BMad/run-next-story
```

## Workflow
1. **Identification** de la prochaine story dans `docs/stories/`
2. **Validation** des prérequis et dépendances
3. **Chargement** des documents de référence :
   - Architecture (`docs/architecture/`)
   - Coding standards
   - Tech stack
4. **Implémentation** selon la DoD BMAD
5. **Tests** unitaires et fonctionnels
6. **Mise à jour** du tracking

## Critères de Sélection Story
- Status `ready` ou `todo`
- Dépendances satisfaites  
- Priorité la plus élevée
- Critères d'acceptation clairs

## Definition of Done BMAD
- ✅ Code fonctionnel implémenté
- ✅ Tests unitaires passants
- ✅ Standards de code respectés
- ✅ Documentation technique à jour
- ✅ Ready for QA review

## Agent Recommandé
`*agent dev` (James - Developer) pour l'implémentation technique.

## Exemple d'Exécution  
```bash
# Via langage naturel
"Attaque la prochaine story" → /BMad/run-next-story

# Via développeur
*agent dev
*task create-next-story
```

## Livrables
- Code fonctionnel dans le repository
- Tests passants
- Story marquée `in-progress` → `done`
- Log dans `.ai/debug-log.md`