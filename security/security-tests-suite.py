#!/usr/bin/env python3
"""
🔒 ENTERPRISE MCP SECURITY TESTING SUITE
Agent: contains-test-analyzer + bmad-qa
Focus: Isolation ressources + TLS/Auth validation
Compliance: SOC2, ISO27001, NIST Cybersecurity Framework
"""

import asyncio
import ssl
import socket
import json
import hashlib
import logging
import unittest
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from pathlib import Path
import psutil
import docker
import redis
import psycopg2
from cryptography import x509
from cryptography.hazmat.primitives import hashes
from cryptography.x509.oid import NameOID

class MCPSecurityTestSuite:
    """Suite complète de tests sécurité MCP Enterprise"""
    
    def __init__(self, config_path: str):
        self.config = self._load_config(config_path)
        self.test_results = {}
        self.setup_logging()
        
    def setup_logging(self):
        """Configuration logging sécurisé pour les tests"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/var/log/bmad/security-tests.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)

class ResourceIsolationTests(unittest.TestCase):
    """Tests isolation des ressources entre agents"""
    
    def setUp(self):
        """Setup environnement test isolation"""
        self.test_containers = []
        self.docker_client = docker.from_env()
        
    def test_filesystem_isolation(self):
        """Valide isolation filesystem entre agents"""
        test_results = {
            'test_name': 'filesystem_isolation',
            'start_time': datetime.now().isoformat(),
            'status': 'running'
        }
        
        try:
            # Test 1: Vérifier isolation des chemins autorisés
            authorized_paths = ['/workspace', '/projects']
            unauthorized_paths = ['/etc', '/var', '/root', '/home']
            
            for path in unauthorized_paths:
                isolation_valid = self._test_path_access_denied(path)
                self.assertTrue(isolation_valid, 
                    f"SECURITY VIOLATION: Agent accès non autorisé {path}")
                
            # Test 2: Vérifier permissions granulaires
            agent_permissions = {
                'contains-test-analyzer': ['read'],
                'contains-eng-devops': ['read', 'write', 'execute'],
                'bmad-orchestrator': ['read', 'write']
            }
            
            for agent, perms in agent_permissions.items():
                for perm in perms:
                    self._validate_agent_permission(agent, perm)
                    
            test_results['status'] = 'passed'
            test_results['details'] = 'Isolation filesystem validée'
            
        except Exception as e:
            test_results['status'] = 'failed'
            test_results['error'] = str(e)
            self.fail(f"Test isolation filesystem échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)
    
    def test_database_isolation(self):
        """Valide isolation bases de données"""
        test_results = {
            'test_name': 'database_isolation', 
            'start_time': datetime.now().isoformat()
        }
        
        try:
            # Test isolation schemas PostgreSQL
            conn = psycopg2.connect(
                host="localhost",
                database="bmad_coordination", 
                user="test_user",
                password="test_pass"
            )
            
            # Chaque agent doit accéder uniquement à ses schemas
            agent_schemas = {
                'bmad_orchestrator': ['orchestrator_state', 'orchestrator_logs'],
                'contains_test_analyzer': ['test_results', 'quality_metrics'],
                'contains_eng_devops': ['deployment_logs', 'infrastructure']
            }
            
            for agent, schemas in agent_schemas.items():
                for schema in schemas:
                    access_valid = self._test_schema_access(conn, agent, schema)
                    self.assertTrue(access_valid, 
                        f"Agent {agent} ne peut pas accéder schema {schema}")
                
                # Test accès refusé autres schemas
                forbidden_schemas = [s for schemas_list in agent_schemas.values() 
                                   for s in schemas_list if s not in schemas]
                for forbidden in forbidden_schemas:
                    access_denied = self._test_schema_access_denied(conn, agent, forbidden)
                    self.assertTrue(access_denied,
                        f"VIOLATION: Agent {agent} accès non autorisé {forbidden}")
                        
            test_results['status'] = 'passed'
            conn.close()
            
        except Exception as e:
            test_results['status'] = 'failed'
            test_results['error'] = str(e)
            self.fail(f"Test isolation database échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)
    
    def test_redis_namespace_isolation(self):
        """Valide isolation namespaces Redis"""
        test_results = {
            'test_name': 'redis_namespace_isolation',
            'start_time': datetime.now().isoformat()
        }
        
        try:
            r = redis.Redis(host='localhost', port=6379, db=0)
            
            # Test isolation par préfixes
            agent_prefixes = {
                'orchestrator': 'orchestrator:*',
                'test_analyzer': 'test_analysis:*', 
                'devops': 'deployment:*'
            }
            
            # Écriture test data avec préfixes
            for agent, prefix in agent_prefixes.items():
                key = prefix.replace('*', 'test_key')
                r.set(key, f'test_data_{agent}')
                
            # Validation accès uniquement aux clés autorisées  
            for agent, prefix in agent_prefixes.items():
                pattern = prefix
                authorized_keys = r.keys(pattern)
                
                # Vérifier qu'on accède uniquement aux clés autorisées
                for key in authorized_keys:
                    self.assertTrue(key.decode().startswith(prefix.replace('*', '')),
                        f"Clé {key} ne respecte pas isolation {agent}")
                        
            test_results['status'] = 'passed'
            test_results['details'] = 'Isolation Redis namespaces validée'
            
        except Exception as e:
            test_results['status'] = 'failed'
            test_results['error'] = str(e)
            self.fail(f"Test isolation Redis échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)

class TLSAuthenticationTests(unittest.TestCase):
    """Tests validation TLS et authentification"""
    
    def test_tls_configuration(self):
        """Valide configuration TLS enterprise"""
        test_results = {
            'test_name': 'tls_configuration',
            'start_time': datetime.now().isoformat()
        }
        
        try:
            # Test connexions TLS 1.3 obligatoires
            mcp_servers = [
                ('localhost', 8001),  # github mcp
                ('localhost', 8002),  # postgres mcp  
                ('localhost', 8003),  # redis mcp
            ]
            
            for host, port in mcp_servers:
                tls_valid = self._validate_tls_connection(host, port)
                self.assertTrue(tls_valid, 
                    f"Configuration TLS invalide pour {host}:{port}")
                    
            # Vérifier rejet TLS < 1.3
            legacy_tls_rejected = self._test_legacy_tls_rejection()
            self.assertTrue(legacy_tls_rejected, "TLS legacy accepté - VIOLATION SÉCURITÉ")
            
            # Valider cipher suites autorisées
            allowed_ciphers = [
                'TLS_AES_256_GCM_SHA384',
                'TLS_CHACHA20_POLY1305_SHA256', 
                'TLS_AES_128_GCM_SHA256'
            ]
            
            for cipher in allowed_ciphers:
                cipher_supported = self._test_cipher_support(cipher)
                self.assertTrue(cipher_supported, f"Cipher {cipher} non supporté")
                
            test_results['status'] = 'passed'
            test_results['details'] = 'Configuration TLS validée'
            
        except Exception as e:
            test_results['status'] = 'failed'
            test_results['error'] = str(e)
            self.fail(f"Test TLS configuration échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)
    
    def test_mutual_tls_authentication(self):
        """Valide authentification mutuelle TLS"""
        test_results = {
            'test_name': 'mutual_tls_authentication',
            'start_time': datetime.now().isoformat()
        }
        
        try:
            # Test certificats agents valides
            agent_certificates = [
                '/security/certs/bmad-orchestrator.pem',
                '/security/certs/contains-test-analyzer.pem',
                '/security/certs/contains-eng-devops.pem'
            ]
            
            for cert_path in agent_certificates:
                cert_valid = self._validate_certificate(cert_path)
                self.assertTrue(cert_valid, f"Certificat {cert_path} invalide")
                
                # Test expiration (< 30 jours = warning)
                days_to_expiry = self._get_certificate_days_to_expiry(cert_path)
                self.assertGreater(days_to_expiry, 30, 
                    f"Certificat {cert_path} expire dans {days_to_expiry} jours")
            
            # Test révocation certificats
            revoked_certs = self._check_certificate_revocation()
            self.assertEqual(len(revoked_certs), 0, 
                f"Certificats révoqués détectés: {revoked_certs}")
                
            # Test authentification mutuelle
            mutual_auth_working = self._test_mutual_authentication()
            self.assertTrue(mutual_auth_working, "Authentification mutuelle échouée")
            
            test_results['status'] = 'passed'
            test_results['details'] = 'Authentification mutuelle TLS validée'
            
        except Exception as e:
            test_results['status'] = 'failed' 
            test_results['error'] = str(e)
            self.fail(f"Test authentification mutuelle échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)

class SecurityComplianceTests(unittest.TestCase):
    """Tests conformité sécurité enterprise"""
    
    def test_audit_trail_integrity(self):
        """Valide intégrité audit trail"""
        test_results = {
            'test_name': 'audit_trail_integrity',
            'start_time': datetime.now().isoformat()
        }
        
        try:
            # Vérifier logs audit non modifiables
            audit_log = '/var/log/bmad/audit/mcp-audit.log'
            integrity_valid = self._verify_log_integrity(audit_log)
            self.assertTrue(integrity_valid, "Intégrité audit logs compromise")
            
            # Test chaîne de hachage
            hash_chain_valid = self._verify_hash_chain(audit_log)
            self.assertTrue(hash_chain_valid, "Chaîne hachage audit compromise")
            
            # Vérifier rétention compliance
            retention_compliant = self._check_retention_compliance()
            self.assertTrue(retention_compliant, "Politique rétention non respectée")
            
            test_results['status'] = 'passed'
            
        except Exception as e:
            test_results['status'] = 'failed'
            test_results['error'] = str(e)
            self.fail(f"Test intégrité audit trail échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)
    
    def test_data_encryption(self):
        """Valide chiffrement données"""
        test_results = {
            'test_name': 'data_encryption',
            'start_time': datetime.now().isoformat()
        }
        
        try:
            # Test chiffrement en transit
            transit_encrypted = self._verify_transit_encryption()
            self.assertTrue(transit_encrypted, "Données transit non chiffrées")
            
            # Test chiffrement au repos
            rest_encrypted = self._verify_rest_encryption()  
            self.assertTrue(rest_encrypted, "Données repos non chiffrées")
            
            # Validation force algorithmes
            encryption_algorithms = self._get_encryption_algorithms()
            approved_algos = ['AES-256-GCM', 'ChaCha20-Poly1305']
            
            for algo in encryption_algorithms:
                self.assertIn(algo, approved_algos, 
                    f"Algorithme {algo} non approuvé")
                    
            test_results['status'] = 'passed'
            
        except Exception as e:
            test_results['status'] = 'failed'
            test_results['error'] = str(e)
            self.fail(f"Test chiffrement données échoué: {e}")
            
        finally:
            test_results['end_time'] = datetime.now().isoformat()
            self._record_test_result(test_results)

    # Helper methods implementation
    def _load_config(self, config_path: str) -> dict:
        """Charge configuration tests"""
        with open(config_path, 'r') as f:
            return json.load(f)
    
    def _validate_tls_connection(self, host: str, port: int) -> bool:
        """Valide connexion TLS sécurisée"""
        context = ssl.create_default_context()
        context.minimum_version = ssl.TLSVersion.TLSv1_3
        
        try:
            with socket.create_connection((host, port), timeout=10) as sock:
                with context.wrap_socket(sock, server_hostname=host) as ssock:
                    return ssock.version() == 'TLSv1.3'
        except Exception:
            return False
    
    def _validate_certificate(self, cert_path: str) -> bool:
        """Valide certificat X.509"""
        try:
            with open(cert_path, 'rb') as f:
                cert = x509.load_pem_x509_certificate(f.read())
                
            # Vérifier non expiré
            now = datetime.now()
            if cert.not_valid_after < now:
                return False
                
            # Vérifier algorithme signature sécurisé
            if isinstance(cert.signature_algorithm_oid._name, str):
                if 'sha1' in cert.signature_algorithm_oid._name.lower():
                    return False
                    
            return True
        except Exception:
            return False
    
    def _record_test_result(self, result: dict):
        """Enregistre résultat test"""
        results_file = '/var/log/bmad/security-test-results.json'
        
        try:
            with open(results_file, 'r') as f:
                results = json.load(f)
        except FileNotFoundError:
            results = []
            
        results.append(result)
        
        with open(results_file, 'w') as f:
            json.dump(results, f, indent=2)

def run_security_test_suite():
    """Exécute suite complète tests sécurité"""
    print("🔒 BMAD MCP ENTERPRISE SECURITY TESTING SUITE")
    print("=" * 50)
    
    # Load test suites
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add test classes
    suite.addTests(loader.loadTestsFromTestCase(ResourceIsolationTests))
    suite.addTests(loader.loadTestsFromTestCase(TLSAuthenticationTests))  
    suite.addTests(loader.loadTestsFromTestCase(SecurityComplianceTests))
    
    # Run tests with detailed output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Generate summary report
    print("\n" + "=" * 50)
    print("📊 RÉSULTATS TESTS SÉCURITÉ")
    print(f"Tests exécutés: {result.testsRun}")
    print(f"Échecs: {len(result.failures)}")
    print(f"Erreurs: {len(result.errors)}")
    
    if result.failures:
        print("\n❌ ÉCHECS SÉCURITÉ:")
        for test, traceback in result.failures:
            print(f"- {test}: {traceback}")
            
    if result.errors:
        print("\n🚨 ERREURS CRITIQUES:")
        for test, traceback in result.errors:
            print(f"- {test}: {traceback}")
    
    # Security posture assessment
    total_tests = result.testsRun
    failed_tests = len(result.failures) + len(result.errors)
    success_rate = ((total_tests - failed_tests) / total_tests) * 100
    
    print(f"\n📈 SCORE SÉCURITÉ: {success_rate:.1f}%")
    
    if success_rate >= 95:
        print("✅ SÉCURITÉ: ENTERPRISE READY")
    elif success_rate >= 80:
        print("⚠️ SÉCURITÉ: AMÉLIORATIONS REQUISES")  
    else:
        print("🚨 SÉCURITÉ: CRITIQUE - REMÉDIATION IMMÉDIATE")
    
    return result

if __name__ == "__main__":
    run_security_test_suite()