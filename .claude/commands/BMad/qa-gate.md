---
name: qa-gate
description: Exécuter le QA Gate BMAD pour validation qualité
category: quality-assurance
---

# QA Gate - Commande BMAD

Exécute le processus de Quality Gate selon les standards BMAD pour valider la qualité.

## Usage
```bash
/BMad/qa-gate [target]
```

## Workflow
1. **Analyse du target** (story, epic, ou release)
2. **Exécution des checks** :
   - Tests unitaires et intégration
   - Respect des coding standards
   - Couverture de tests
   - Performance benchmarks
   - Security checks
3. **Génération du rapport** QA Gate
4. **Décision** : PASS / CONCERNS / FAIL / WAIVED
5. **Sauvegarde** dans `docs/qa/`

## Types de QA Gates
- **Story Gate** : Validation d'une story individuelle
- **Epic Gate** : Validation d'un epic complet  
- **Release Gate** : Validation avant mise en production

## Template Utilisé
- `qa-gate-tmpl.yaml` - Rapport QA standard BMAD
- Sauvegarde dans `qaLocation: docs/qa` (core-config)

## Critères d'Évaluation
- ✅ **Functional** : Critères d'acceptation respectés
- ✅ **Technical** : Standards de code et architecture
- ✅ **Performance** : Benchmarks non-régressifs  
- ✅ **Security** : Pas de vulnérabilités identifiées
- ✅ **Documentation** : À jour et complète

## Agent Recommandé
`*agent qa` (Quinn - Quality Advisor) pour l'expertise qualité.

## Exemple d'Exécution
```bash
# QA Gate sur story
"Passe cette story en QA" → /BMad/qa-gate story-001

# Via QA expert
*agent qa
*task qa-gate story-001
```

## Livrables
- Rapport QA Gate dans `docs/qa/`
- Décision motivée (PASS/CONCERNS/FAIL/WAIVED)
- Actions correctives si nécessaire
- Metrics qualité trackées