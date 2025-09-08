# 🚀 Scripts BMAD - Automatisation & Validation DevOps

Infrastructure complète d'automatisation pour template BMAD avec validation MCP, monitoring production et orchestration DevOps coordonnée.

## 📁 Structure & Organisation

```
scripts/
├── 🚀 Initialisation
│   ├── init-mcp-services.bat           # Init complète infrastructure MCP
│   └── monitoring-setup.bat            # Configuration monitoring
├── ✅ Validation MCP  
│   ├── validate-mcp-quick.bat          # Validation rapide (30s)
│   ├── validate-mcp-full.bat           # Validation complète + benchmarks (2-5min)
│   ├── validate-mcp-optimizations.bat  # Tests optimisations spécialisées
│   ├── validate-motion-mcp.bat         # Tests composants motion
│   └── mcp-infrastructure-validator.ps1 # Validation infrastructure complète
├── 📊 Performance & Analytics
│   ├── mcp-performance-analyzer.ps1     # Analyses détaillées + rapports
│   ├── mcp-optimization-validator.py    # Tests optimisations Python  
│   ├── performance-benchmarks.js        # Benchmarks Node.js/JavaScript
│   └── monitor-mcp.bat                  # Monitoring temps réel
├── 🔧 DevOps & CI/CD
│   ├── test-workflows.sh               # Tests workflows complets
│   ├── validate-ci-cd-setup.bat        # Validation pipeline CI/CD
│   └── bmad-devops-coordination.json   # Configuration coordination
├── 📈 Observabilité Production
│   ├── monitoring/                     # Dashboard et métriques live
│   └── observability/                  # Monitoring avancé + alertes
└── 📋 Logs & Audit
    ├── logs/                          # Logs structurés par catégorie
    └── mcp-validation/                # Résultats validation historiques
```

## ⚡ Ordre d'Exécution Recommandé

### **Phase 1: Initialisation (Première fois)**
```powershell
# 1. Infrastructure complète 
.\init-mcp-services.bat

# 2. Configuration monitoring
.\monitoring-setup.bat

# 3. Validation infrastructure
.\validate-mcp-full.bat
```

### **Phase 2: Développement Quotidien**
```powershell
# Validation rapide avant commit
.\validate-mcp-quick.bat

# Tests spécialisés selon besoins
.\validate-motion-mcp.bat      # Composants motion
```

### **Phase 3: Pre-Production & Déploiement**
```powershell
# Benchmarks complets
.\validate-mcp-full.bat

# Analyse performance détaillée
powershell -ExecutionPolicy Bypass -File .\mcp-performance-analyzer.ps1 -Mode Analyze

# Validation CI/CD
.\validate-ci-cd-setup.bat
```

### **Phase 4: Production & Monitoring**
```powershell
# Monitoring temps réel
.\monitor-mcp.bat

# Observabilité avancée  
.\observability\observability-master.bat

# Collecte métriques production
powershell -ExecutionPolicy Bypass -File .\observability\production-metrics-collector.ps1
```

## 🛠️ Configuration Environnements

### **Variables d'Environnement**
```batch
# Configuration paths
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..
set LOG_DIR=%PROJECT_ROOT%\logs
set MCP_CONFIG=%PROJECT_ROOT%\project.mcp.json

# Performance thresholds  
set LATENCY_MAX=10
set MEMORY_THRESHOLD=80
set CPU_THRESHOLD=75
```

### **Prérequis Système**
- **Windows** : PowerShell 5.1+, Windows 10/11
- **Node.js** : v18.0+ (LTS recommandée)
- **Python** : 3.8+ avec pip
- **Redis** : Version 6.0+ (local ou distant)
- **PostgreSQL** : Version 13+ (optionnel pour audit)

### **Permissions Requises**
```powershell
# Exécution PowerShell scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Permissions registry (monitoring avancé)
# Administrateur requis pour certains collecteurs
```

## 📊 Scripts Performance & Analytics

### **mcp-performance-analyzer.ps1**
```powershell
# Modes d'utilisation
.\mcp-performance-analyzer.ps1 -Mode Analyze     # Analyse standard
.\mcp-performance-analyzer.ps1 -Mode Compare     # Comparaison versions
.\mcp-performance-analyzer.ps1 -Mode Report      # Rapport HTML interactif
.\mcp-performance-analyzer.ps1 -Mode Optimize    # Recommandations auto
```

### **performance-benchmarks.js**
```javascript
// Benchmarks spécialisés
node performance-benchmarks.js --mode=full      // Tests complets
node performance-benchmarks.js --mode=quick     // Tests rapides  
node performance-benchmarks.js --mode=stress    // Tests charge
```

## 🔍 Troubleshooting Scripts Courants

### **Erreur: "MCP Server not responding"**
```powershell
# 1. Vérifier statut serveurs
.\validate-mcp-quick.bat

# 2. Redémarrer services
.\init-mcp-services.bat --restart-only

# 3. Logs détaillés
type logs\mcp-services.log | findstr ERROR
```

### **Performance dégradée**
```powershell  
# 1. Analyse rapide
.\mcp-optimization-validator.py --quick-check

# 2. Métriques détaillées
.\mcp-performance-analyzer.ps1 -Mode Analyze

# 3. Optimisation auto
.\mcp-performance-analyzer.ps1 -Mode Optimize
```

### **Échecs validation CI/CD**
```bash
# 1. Tests workflows individuels
./test-workflows.sh --verbose

# 2. Validation setup complet
.\validate-ci-cd-setup.bat --debug

# 3. Configuration DevOps
type bmad-devops-coordination.json
```

### **Monitoring indisponible**
```powershell
# 1. Restart monitoring
.\monitoring-setup.bat --force-restart

# 2. Health check complet
.\observability\health-check-comprehensive.ps1

# 3. Dashboard status
start monitoring\health-dashboard.html
```

## 🚨 Scripts Urgence & Incident Response

### **Crisis Response (< 5 minutes)**
```powershell
# Diagnostic rapide
.\validate-mcp-quick.bat && echo "MCP: OK" || echo "MCP: CRITICAL"

# Métriques critiques  
.\observability\production-monitoring-master.ps1 --emergency-mode

# Alertes temps réel
.\observability\realtime-alerting-system.ps1 --activate-all
```

## 📈 Métriques & KPIs

- **Latence coordination** : < 10ms (seuil alerte: 25ms)
- **Temps réponse MCP** : < 15ms (seuil alerte: 50ms)  
- **Utilisation mémoire** : > 98% efficacité
- **Taux succès validation** : > 99.5%
- **Disponibilité infrastructure** : > 99.9%

## 🔐 Sécurité & Audit

Tous les scripts incluent :
- **Audit logging** activé par défaut
- **Validation permissions** avant exécution
- **Sandbox isolation** pour tests
- **Chiffrement logs sensibles** (AES-256)
- **Rétention sécurisée** (7 ans minimum)

---

**🚀 Infrastructure DevOps optimisée pour développement intelligent coordonné avec BMAD.**