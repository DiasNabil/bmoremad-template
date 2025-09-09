#!/usr/bin/env node
/**
 * Script de nettoyage MCP - Supprime les configurations obsolètes
 * et nettoie les fichiers MCP surnuméraires du template BMAD
 */

const fs = require('fs');
const path = require('path');

// Fichiers à supprimer (configurations MCP obsolètes)
const OBSOLETE_FILES = [
  'project.mcp.json',           // Configuration MCP complexe et redondante
  '.claude-mcp-config.json',    // Configuration MCP intermédiaire
  'MCP-SETUP-GUIDE.md',        // Guide obsolète
  'validate-mcp-setup.bat',    // Validation obsolète
];

// Dossiers contenant des scripts MCP obsolètes à nettoyer
const OBSOLETE_SCRIPTS = [
  'scripts/init-mcp-services.bat',
  'scripts/mcp-infrastructure-validator.ps1', 
  'scripts/mcp-performance-analyzer.ps1',
  'scripts/monitor-mcp.bat',
  'scripts/validate-mcp-full.bat',
  'scripts/validate-mcp-quick.bat',
  'scripts/validate-mcp-optimizations.bat',
  'scripts/mcp-optimization-validator.py',
  'scripts/validate-motion-mcp.bat'
];

// Dossiers à nettoyer partiellement
const OBSOLETE_DIRECTORIES = [
  'scripts/mcp',
  'scripts/mcp-validation',
  'scripts/monitoring',
  'scripts/observability'
];

/**
 * Supprime un fichier de manière sécurisée
 */
function safeDelete(filePath) {
  try {
    if (fs.existsSync(filePath)) {
      const stats = fs.statSync(filePath);
      
      if (stats.isDirectory()) {
        fs.rmSync(filePath, { recursive: true, force: true });
        console.log(`🗂️  Dossier supprimé: ${filePath}`);
      } else {
        fs.unlinkSync(filePath);
        console.log(`📄 Fichier supprimé: ${filePath}`);
      }
      
      return true;
    }
  } catch (error) {
    console.error(`❌ Erreur lors de la suppression de ${filePath}:`, error.message);
    return false;
  }
  return false;
}

/**
 * Crée une sauvegarde des fichiers importants avant suppression
 */
function backupImportantFiles() {
  const backupDir = 'backup-mcp-cleanup';
  
  if (!fs.existsSync(backupDir)) {
    fs.mkdirSync(backupDir);
  }
  
  const filesToBackup = [
    'project.mcp.json',
    '.claude-mcp-config.json'
  ];
  
  console.log('💾 Création de sauvegardes...');
  
  for (const file of filesToBackup) {
    if (fs.existsSync(file)) {
      try {
        fs.copyFileSync(file, path.join(backupDir, file));
        console.log(`  ✅ Sauvegarde: ${file} → ${backupDir}/${file}`);
      } catch (error) {
        console.error(`  ❌ Erreur sauvegarde ${file}:`, error.message);
      }
    }
  }
}

/**
 * Analyse l'état actuel des fichiers MCP
 */
function analyzeCurrentState() {
  console.log('🔍 Analyse de la configuration MCP actuelle...\n');
  
  const findings = {
    obsoleteFiles: [],
    obsoleteScripts: [],
    obsoleteDirs: [],
    totalSize: 0
  };
  
  // Vérifier les fichiers obsolètes
  for (const file of OBSOLETE_FILES) {
    if (fs.existsSync(file)) {
      const stats = fs.statSync(file);
      findings.obsoleteFiles.push({
        path: file,
        size: stats.size
      });
      findings.totalSize += stats.size;
    }
  }
  
  // Vérifier les scripts obsolètes
  for (const script of OBSOLETE_SCRIPTS) {
    if (fs.existsSync(script)) {
      const stats = fs.statSync(script);
      findings.obsoleteScripts.push({
        path: script,
        size: stats.size
      });
      findings.totalSize += stats.size;
    }
  }
  
  // Vérifier les dossiers obsolètes
  for (const dir of OBSOLETE_DIRECTORIES) {
    if (fs.existsSync(dir)) {
      findings.obsoleteDirs.push(dir);
    }
  }
  
  return findings;
}

/**
 * Affiche le rapport de nettoyage
 */
function displayCleanupReport(findings) {
  console.log('📊 RAPPORT DE NETTOYAGE MCP');
  console.log('='.repeat(40));
  
  if (findings.obsoleteFiles.length > 0) {
    console.log('\n📄 Fichiers de configuration obsolètes:');
    findings.obsoleteFiles.forEach(file => {
      console.log(`  • ${file.path} (${(file.size / 1024).toFixed(1)} KB)`);
    });
  }
  
  if (findings.obsoleteScripts.length > 0) {
    console.log('\n🔧 Scripts obsolètes:');
    findings.obsoleteScripts.forEach(script => {
      console.log(`  • ${script.path} (${(script.size / 1024).toFixed(1)} KB)`);
    });
  }
  
  if (findings.obsoleteDirs.length > 0) {
    console.log('\n🗂️  Dossiers obsolètes:');
    findings.obsoleteDirs.forEach(dir => {
      console.log(`  • ${dir}`);
    });
  }
  
  console.log(`\n💾 Espace total à libérer: ${(findings.totalSize / 1024).toFixed(1)} KB`);
}

/**
 * Effectue le nettoyage
 */
function performCleanup(findings) {
  console.log('\n🧹 Démarrage du nettoyage...\n');
  
  let cleaned = 0;
  
  // Supprimer les fichiers obsolètes
  for (const file of findings.obsoleteFiles) {
    if (safeDelete(file.path)) cleaned++;
  }
  
  // Supprimer les scripts obsolètes
  for (const script of findings.obsoleteScripts) {
    if (safeDelete(script.path)) cleaned++;
  }
  
  // Supprimer les dossiers obsolètes
  for (const dir of findings.obsoleteDirs) {
    if (safeDelete(dir)) cleaned++;
  }
  
  console.log(`\n✅ Nettoyage terminé: ${cleaned} éléments supprimés`);
  
  return cleaned;
}

/**
 * Fonction principale
 */
function main() {
  console.log('🧹 BMAD Template - Nettoyage MCP');
  console.log('='.repeat(40));
  
  // Analyser l'état actuel
  const findings = analyzeCurrentState();
  
  // Afficher le rapport
  displayCleanupReport(findings);
  
  const totalItems = findings.obsoleteFiles.length + findings.obsoleteScripts.length + findings.obsoleteDirs.length;
  
  if (totalItems === 0) {
    console.log('\n✨ Aucun fichier obsolète trouvé. Le projet est déjà propre !');
    return;
  }
  
  console.log(`\n⚠️  ${totalItems} éléments obsolètes trouvés`);
  console.log('🔄 Création de sauvegardes avant suppression...\n');
  
  // Créer les sauvegardes
  backupImportantFiles();
  
  // Effectuer le nettoyage
  const cleaned = performCleanup(findings);
  
  console.log('\n🎉 Nettoyage MCP terminé avec succès !');
  console.log('\n📋 Étapes suivantes:');
  console.log('  1. Utilisez scripts/configure-mcp-modern.js pour la nouvelle config');
  console.log('  2. Configurez vos tokens dans .env');
  console.log('  3. Redémarrez Claude Code');
  console.log('\n💡 Sauvegarde disponible dans: backup-mcp-cleanup/');
}

// Exécuter si appelé directement
if (require.main === module) {
  main();
}

module.exports = {
  analyzeCurrentState,
  performCleanup,
  safeDelete
};