#!/usr/bin/env node
/**
 * Configuration MCP Moderne - Basée sur la documentation officielle Anthropic
 * https://docs.anthropic.com/en/docs/claude-code/mcp
 * 
 * Ce script configure les serveurs MCP essentiels selon les meilleures pratiques
 * et les scopes d'installation recommandés.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// Configuration MCP optimisée selon les standards Anthropic
const ESSENTIAL_MCP_SERVERS = {
  // GitHub - Gestion des repositories et workflows
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
    },
    "description": "GitHub repository management and workflows",
    "scope": "global",
    "priority": "high"
  },
  
  // Filesystem - Accès aux fichiers locaux avec sécurité
  "filesystem": {
    "command": "npx", 
    "args": ["-y", "@modelcontextprotocol/server-filesystem", process.cwd()],
    "env": {},
    "description": "Secure local file system access",
    "scope": "project",
    "priority": "critical"
  },
  
  // Memory - Intelligence et mémoire contextuelle
  "memory": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"],
    "env": {},
    "description": "Contextual memory and learning",
    "scope": "global",
    "priority": "high"
  },
  
  // PostgreSQL - Base de données relationnelle
  "postgres": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {
      "POSTGRES_CONNECTION_STRING": "${DATABASE_URL}"
    },
    "description": "PostgreSQL database integration",
    "scope": "project",
    "priority": "medium"
  },
  
  // Brave Search - Recherche web intelligente
  "brave-search": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-brave-search"],
    "env": {
      "BRAVE_API_KEY": "${BRAVE_API_KEY}"
    },
    "description": "Intelligent web search capabilities",
    "scope": "global", 
    "priority": "medium"
  }
};

/**
 * Détecte le fichier de configuration Claude approprié
 */
function getClaudeConfigPath() {
  const possiblePaths = [
    path.join(os.homedir(), '.claude.json'),
    path.join(os.homedir(), '.config', 'claude', 'claude_desktop_config.json'),
    path.join(os.homedir(), 'AppData', 'Roaming', 'Claude', 'claude_desktop_config.json')
  ];
  
  for (const configPath of possiblePaths) {
    if (fs.existsSync(configPath)) {
      return configPath;
    }
  }
  
  // Créer le chemin par défaut
  const defaultPath = path.join(os.homedir(), '.claude.json');
  fs.writeFileSync(defaultPath, JSON.stringify({ mcpServers: {} }, null, 2));
  return defaultPath;
}

/**
 * Configure les serveurs MCP selon le scope d'installation
 */
function configureMcpServers(configPath, scope = 'project') {
  try {
    console.log(`🔧 Configuration MCP - Scope: ${scope}`);
    
    // Lire la configuration existante
    let claudeConfig = {};
    if (fs.existsSync(configPath)) {
      claudeConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }
    
    // Initialiser la structure si nécessaire
    if (!claudeConfig.mcpServers) {
      claudeConfig.mcpServers = {};
    }
    
    // Ajouter TOUS les serveurs essentiels (pas seulement selon le scope)
    const serversToAdd = Object.entries(ESSENTIAL_MCP_SERVERS)
      .reduce((acc, [name, config]) => {
        acc[name] = {
          command: config.command,
          args: config.args,
          env: config.env
        };
        return acc;
      }, {});
    
    // Ajouter les serveurs à la configuration
    Object.assign(claudeConfig.mcpServers, serversToAdd);
    
    // Créer une sauvegarde
    if (fs.existsSync(configPath)) {
      fs.copyFileSync(configPath, configPath + '.backup');
      console.log(`💾 Sauvegarde créée: ${configPath}.backup`);
    }
    
    // Écrire la nouvelle configuration
    fs.writeFileSync(configPath, JSON.stringify(claudeConfig, null, 2));
    
    console.log('✅ Configuration MCP mise à jour avec succès !');
    console.log(`📁 Fichier de config: ${configPath}`);
    console.log(`🚀 Serveurs configurés (${scope}):`, Object.keys(serversToAdd));
    
    return true;
  } catch (error) {
    console.error('❌ Erreur lors de la configuration MCP:', error.message);
    return false;
  }
}

/**
 * Valide la configuration des variables d'environnement
 */
function validateEnvironmentVariables() {
  const requiredVars = ['GITHUB_TOKEN'];
  const optionalVars = ['DATABASE_URL', 'BRAVE_API_KEY'];
  
  console.log('\n🔍 Validation des variables d\'environnement:');
  
  // Variables requises
  let hasRequiredVars = true;
  for (const varName of requiredVars) {
    if (process.env[varName] && process.env[varName] !== 'your_github_token_here') {
      console.log(`  ✅ ${varName}: Configuré`);
    } else {
      console.log(`  ❌ ${varName}: Non configuré (REQUIS)`);
      hasRequiredVars = false;
    }
  }
  
  // Variables optionnelles
  for (const varName of optionalVars) {
    if (process.env[varName] && !process.env[varName].includes('your_')) {
      console.log(`  ✅ ${varName}: Configuré`);
    } else {
      console.log(`  ⚠️  ${varName}: Non configuré (optionnel)`);
    }
  }
  
  if (!hasRequiredVars) {
    console.log('\n⚠️  Configurez les variables requises dans votre fichier .env');
    console.log('📖 Voir .env.example pour les valeurs nécessaires');
  }
  
  return hasRequiredVars;
}

/**
 * Fonction principale
 */
function main() {
  console.log('🚀 BMAD Template - Configuration MCP Moderne');
  console.log('='.repeat(50));
  
  // Détecter le fichier de configuration
  const configPath = getClaudeConfigPath();
  console.log(`📄 Configuration trouvée: ${configPath}`);
  
  // Configurer les serveurs MCP
  const success = configureMcpServers(configPath, 'project');
  
  if (success) {
    // Valider les variables d'environnement
    validateEnvironmentVariables();
    
    console.log('\n📋 Étapes suivantes:');
    console.log('  1. Configurez vos tokens dans le fichier .env');
    console.log('  2. Redémarrez Claude Code complètement');
    console.log('  3. Utilisez la commande /mcp pour vérifier les serveurs');
    console.log('  4. Testez avec "Liste mes repositories GitHub"');
    
    console.log('\n🔧 Serveurs MCP configurés selon les meilleures pratiques Anthropic');
    console.log('📚 Documentation: https://docs.anthropic.com/en/docs/claude-code/mcp');
  }
}

// Exécuter si appelé directement
if (require.main === module) {
  main();
}

module.exports = {
  configureMcpServers,
  validateEnvironmentVariables,
  ESSENTIAL_MCP_SERVERS
};