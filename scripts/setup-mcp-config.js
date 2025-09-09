#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// Configuration MCP pour Claude Code
const mcpConfig = {
  "github": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": process.env.GITHUB_TOKEN || "your_github_token_here"
    }
  },
  "filesystem": {
    "type": "stdio", 
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem"],
    "env": {
      "ALLOWED_DIRECTORIES": process.cwd()
    }
  },
  "postgres": {
    "type": "stdio",
    "command": "npx", 
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {
      "POSTGRES_CONNECTION_STRING": process.env.DATABASE_URL || "postgresql://username:password@localhost:5432/database"
    }
  },
  "memory": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-memory"]
  },
  "brave-search": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-brave-search"],
    "env": {
      "BRAVE_API_KEY": process.env.BRAVE_API_KEY || "your_brave_api_key_here"
    }
  }
};

const claudeConfigPath = path.join(os.homedir(), '.claude.json');

try {
  // Lire le fichier .claude.json existant
  const claudeConfig = JSON.parse(fs.readFileSync(claudeConfigPath, 'utf8'));
  
  // Trouver la configuration du projet actuel
  const currentProjectPath = process.cwd();
  const projectKeys = Object.keys(claudeConfig.projectConfigs || {});
  
  let projectConfigKey = projectKeys.find(key => 
    key.toLowerCase().includes('bmoremad-template') ||
    key === currentProjectPath
  );
  
  if (!projectConfigKey) {
    projectConfigKey = currentProjectPath;
    claudeConfig.projectConfigs = claudeConfig.projectConfigs || {};
    claudeConfig.projectConfigs[projectConfigKey] = {
      allowedTools: [],
      mcpServers: {},
      enabledMcpjsonServers: [],
      disabledMcpjsonServers: [],
      hasTrustDialogAccepted: false
    };
  }
  
  // Ajouter la configuration MCP
  claudeConfig.projectConfigs[projectConfigKey].mcpServers = mcpConfig;
  
  // Sauvegarder le backup
  fs.writeFileSync(claudeConfigPath + '.backup', fs.readFileSync(claudeConfigPath));
  
  // Écrire la nouvelle configuration
  fs.writeFileSync(claudeConfigPath, JSON.stringify(claudeConfig, null, 2));
  
  console.log('✅ Configuration MCP ajoutée avec succès !');
  console.log(`📁 Projet: ${projectConfigKey}`);
  console.log(`🔧 Serveurs configurés: ${Object.keys(mcpConfig).join(', ')}`);
  console.log('📋 Redémarrez Claude Code pour appliquer les changements.');
  console.log('💡 Utilisez /mcp pour vérifier la connexion des serveurs.');
  
} catch (error) {
  console.error('❌ Erreur lors de la configuration MCP:', error.message);
  console.error('💡 Vérifiez que le fichier .claude.json existe dans:', claudeConfigPath);
}