#!/usr/bin/env node
/**
 * Validation MCP Moderne - Vérifie la configuration optimisée
 * Compatible avec la documentation officielle Anthropic
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { exec } = require('child_process');

// Serveurs MCP essentiels attendus
const EXPECTED_MCP_SERVERS = [
  'filesystem',
  'github', 
  'memory',
  'postgres',
  'brave-search'
];

// Variables d'environnement critiques
const CRITICAL_ENV_VARS = {
  'GITHUB_TOKEN': {
    required: true,
    description: 'GitHub Personal Access Token',
    example: 'ghp_xxxxxxxxxxxxxxxxxxxx'
  }
};

const OPTIONAL_ENV_VARS = {
  'DATABASE_URL': {
    required: false,
    description: 'PostgreSQL connection string',
    example: 'postgresql://user:pass@localhost:5432/db'
  },
  'BRAVE_API_KEY': {
    required: false,
    description: 'Brave Search API key',
    example: 'BSAxxxxxxxxxxxxxxxxx'
  }
};

/**
 * Trouve et lit le fichier de configuration Claude
 */
function readClaudeConfig() {
  const possiblePaths = [
    path.join(os.homedir(), '.claude.json'),
    path.join(os.homedir(), '.config', 'claude', 'claude_desktop_config.json'),
    path.join(os.homedir(), 'AppData', 'Roaming', 'Claude', 'claude_desktop_config.json')
  ];
  
  for (const configPath of possiblePaths) {
    try {
      if (fs.existsSync(configPath)) {
        const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        return { path: configPath, config };
      }
    } catch (error) {
      console.warn(`⚠️  Erreur lecture ${configPath}:`, error.message);
    }
  }
  
  return null;
}

/**
 * Valide la configuration MCP
 */
function validateMcpConfiguration() {
  console.log('🔍 Validation Configuration MCP');
  console.log('-'.repeat(40));
  
  const claudeData = readClaudeConfig();
  
  if (!claudeData) {
    console.log('❌ Aucun fichier de configuration Claude trouvé');
    console.log('💡 Exécutez: node scripts/configure-mcp-modern.js');
    return false;
  }
  
  console.log(`📁 Configuration trouvée: ${claudeData.path}`);
  
  const { config } = claudeData;
  
  if (!config.mcpServers) {
    console.log('❌ Section mcpServers manquante');
    return false;
  }
  
  const configuredServers = Object.keys(config.mcpServers);
  console.log(`🔧 Serveurs configurés: ${configuredServers.length}`);
  
  let isValid = true;
  
  // Vérifier les serveurs essentiels
  for (const server of EXPECTED_MCP_SERVERS) {
    if (configuredServers.includes(server)) {
      console.log(`  ✅ ${server}: Configuré`);
    } else {
      console.log(`  ⚠️  ${server}: Non configuré (recommandé)`);
    }
  }
  
  // Vérifier la structure des serveurs configurés
  for (const [serverName, serverConfig] of Object.entries(config.mcpServers)) {
    if (!serverConfig.command || !Array.isArray(serverConfig.args)) {
      console.log(`  ❌ ${serverName}: Configuration invalide`);
      isValid = false;
    } else {
      console.log(`  🔧 ${serverName}: Structure valide`);
    }
  }
  
  return isValid;
}

/**
 * Valide les variables d'environnement
 */
function validateEnvironmentVariables() {
  console.log('\n🔐 Validation Variables d\'Environnement');
  console.log('-'.repeat(40));
  
  let hasRequiredVars = true;
  
  // Variables critiques
  for (const [varName, varInfo] of Object.entries(CRITICAL_ENV_VARS)) {
    const value = process.env[varName];
    
    if (value && value !== varInfo.example && !value.includes('your_')) {
      console.log(`  ✅ ${varName}: Configuré`);
    } else {
      console.log(`  ❌ ${varName}: Non configuré (REQUIS)`);
      console.log(`     💡 ${varInfo.description}`);
      hasRequiredVars = false;
    }
  }
  
  // Variables optionnelles
  console.log('\n  Variables optionnelles:');
  for (const [varName, varInfo] of Object.entries(OPTIONAL_ENV_VARS)) {
    const value = process.env[varName];
    
    if (value && !value.includes('your_')) {
      console.log(`  ✅ ${varName}: Configuré`);
    } else {
      console.log(`  ⚪ ${varName}: Non configuré (optionnel)`);
    }
  }
  
  return hasRequiredVars;
}

/**
 * Teste la connectivité des serveurs MCP
 */
function testMcpConnectivity() {
  return new Promise((resolve) => {
    console.log('\n🌐 Test de Connectivité MCP');
    console.log('-'.repeat(40));
    
    // Tester si NPX peut accéder aux packages MCP
    const testCommands = [
      'npx -y @modelcontextprotocol/server-filesystem --help',
      'npx -y @modelcontextprotocol/server-github --help', 
      'npx -y @modelcontextprotocol/server-memory --help'
    ];
    
    let testsCompleted = 0;
    let testsSuccessful = 0;
    
    testCommands.forEach((command, index) => {
      const serverName = command.split('/server-')[1].split(' ')[0];
      
      exec(command, { timeout: 10000 }, (error, stdout, stderr) => {
        testsCompleted++;
        
        if (!error && !stderr.includes('Error')) {
          console.log(`  ✅ ${serverName}: Package accessible`);
          testsSuccessful++;
        } else {
          console.log(`  ❌ ${serverName}: Erreur d'accès`);
          console.log(`     💡 Vérifiez votre connexion internet et NPX`);
        }
        
        if (testsCompleted === testCommands.length) {
          console.log(`\n📊 Résultats: ${testsSuccessful}/${testCommands.length} serveurs accessibles`);
          resolve(testsSuccessful === testCommands.length);
        }
      });
    });
  });
}

/**
 * Vérifie les fichiers de configuration du projet
 */
function validateProjectFiles() {
  console.log('\n📄 Validation Fichiers Projet');
  console.log('-'.repeat(40));
  
  const requiredFiles = {
    '.env.example': 'Modèle de variables d\'environnement',
    'MCP-MODERN-SETUP.md': 'Guide de configuration moderne',
    'scripts/configure-mcp-modern.js': 'Script de configuration',
    'scripts/cleanup-mcp.js': 'Script de nettoyage'
  };
  
  let allFilesPresent = true;
  
  for (const [filePath, description] of Object.entries(requiredFiles)) {
    if (fs.existsSync(filePath)) {
      console.log(`  ✅ ${filePath}: Présent`);
    } else {
      console.log(`  ❌ ${filePath}: Manquant`);
      console.log(`     💡 ${description}`);
      allFilesPresent = false;
    }
  }
  
  return allFilesPresent;
}

/**
 * Génère le rapport de validation
 */
function generateValidationReport(results) {
  console.log('\n📊 RAPPORT DE VALIDATION MCP MODERNE');
  console.log('='.repeat(50));
  
  const { mcpConfig, envVars, projectFiles, connectivity } = results;
  
  console.log(`🔧 Configuration MCP: ${mcpConfig ? '✅ Valide' : '❌ Invalide'}`);
  console.log(`🔐 Variables d'environnement: ${envVars ? '✅ Complètes' : '⚠️ Incomplètes'}`);
  console.log(`📄 Fichiers projet: ${projectFiles ? '✅ Présents' : '❌ Manquants'}`);
  console.log(`🌐 Connectivité serveurs: ${connectivity ? '✅ Fonctionnelle' : '❌ Problématique'}`);
  
  const overallScore = [mcpConfig, envVars, projectFiles, connectivity].filter(Boolean).length;
  console.log(`\n🎯 Score global: ${overallScore}/4`);
  
  if (overallScore === 4) {
    console.log('\n🎉 Configuration MCP moderne parfaitement opérationnelle !');
    console.log('📋 Prochaines étapes:');
    console.log('  1. Redémarrez Claude Code complètement');
    console.log('  2. Testez avec: /mcp');
    console.log('  3. Essayez: "Liste mes repositories GitHub"');
  } else {
    console.log('\n⚠️  Configuration incomplète. Actions recommandées:');
    
    if (!mcpConfig) {
      console.log('  • Exécutez: node scripts/configure-mcp-modern.js');
    }
    if (!envVars) {
      console.log('  • Configurez vos tokens dans .env');
    }
    if (!projectFiles) {
      console.log('  • Restaurez les fichiers manquants depuis le repository');
    }
    if (!connectivity) {
      console.log('  • Vérifiez votre connexion internet et NPX');
    }
  }
  
  return overallScore === 4;
}

/**
 * Fonction principale de validation
 */
async function main() {
  console.log('🚀 BMAD Template - Validation MCP Moderne');
  console.log('='.repeat(50));
  
  try {
    // Exécuter toutes les validations
    const mcpConfig = validateMcpConfiguration();
    const envVars = validateEnvironmentVariables(); 
    const projectFiles = validateProjectFiles();
    const connectivity = await testMcpConnectivity();
    
    // Générer le rapport
    const isValid = generateValidationReport({
      mcpConfig,
      envVars, 
      projectFiles,
      connectivity
    });
    
    process.exit(isValid ? 0 : 1);
    
  } catch (error) {
    console.error('\n❌ Erreur lors de la validation:', error.message);
    process.exit(1);
  }
}

// Exécuter si appelé directement
if (require.main === module) {
  main();
}

module.exports = {
  validateMcpConfiguration,
  validateEnvironmentVariables,
  testMcpConnectivity,
  validateProjectFiles
};