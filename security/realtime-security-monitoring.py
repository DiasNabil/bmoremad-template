#!/usr/bin/env python3
"""
🚨 REAL-TIME MCP SECURITY MONITORING & COMPLIANCE
Agent: contains-test-analyzer + bmad-qa
Focus: Monitoring temps réel + alertes sécurité + compliance
Framework: Zero-Trust Security Architecture
"""

import asyncio
import json
import logging
import time
import hashlib
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
from collections import defaultdict, deque
import psutil
import redis
import psycopg2
from psycopg2.extras import RealDictCursor
import aiofiles
import aiohttp
import websockets
from prometheus_client import Counter, Histogram, Gauge, start_http_server

# Métriques Prometheus pour monitoring
SECURITY_EVENTS = Counter('bmad_security_events_total', 
                         'Total security events', ['agent', 'event_type', 'severity'])
AUTHENTICATION_ATTEMPTS = Counter('bmad_auth_attempts_total',
                                'Authentication attempts', ['agent', 'status'])
AUTHORIZATION_DECISIONS = Counter('bmad_authz_decisions_total', 
                                'Authorization decisions', ['agent', 'resource', 'decision'])
RESPONSE_TIME = Histogram('bmad_mcp_response_time_seconds',
                         'MCP server response times', ['server', 'method'])
ACTIVE_SESSIONS = Gauge('bmad_active_sessions', 'Active agent sessions', ['agent'])

@dataclass
class SecurityEvent:
    """Événement sécurité structuré"""
    timestamp: datetime
    agent_id: str
    event_type: str
    severity: str  # LOW, MEDIUM, HIGH, CRITICAL
    resource: str
    action: str
    source_ip: str
    user_agent: str
    details: Dict[str, Any]
    risk_score: float
    compliance_flags: List[str]

@dataclass
class ComplianceViolation:
    """Violation compliance détectée"""
    violation_id: str
    timestamp: datetime
    agent_id: str
    policy_violated: str
    severity: str
    description: str
    evidence: Dict[str, Any]
    remediation_required: bool
    escalation_level: int

class SecurityEventProcessor:
    """Processeur événements sécurité en temps réel"""
    
    def __init__(self, config: Dict):
        self.config = config
        self.event_queue = asyncio.Queue(maxsize=10000)
        self.redis_client = redis.Redis(**config['redis'])
        self.postgres_conn = None
        self.alert_channels = []
        self.setup_logging()
        
        # Détection d'anomalies
        self.baseline_metrics = defaultdict(deque)  # 30 jours glissants
        self.anomaly_thresholds = {
            'auth_failure_rate': 0.05,  # 5% max
            'privilege_escalation': 0,   # Tolérance zéro
            'unusual_access_pattern': 3  # 3 sigma
        }
        
        # Compliance tracking
        self.compliance_policies = self._load_compliance_policies()
        self.violation_history = deque(maxlen=1000)
        
    def setup_logging(self):
        """Configuration logging sécurisé"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/var/log/bmad/security-monitoring.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)

    async def start_monitoring(self):
        """Démarre monitoring sécurité temps réel"""
        self.logger.info("🚨 Démarrage monitoring sécurité MCP Enterprise")
        
        # Connexion base de données
        await self._setup_database_connection()
        
        # Démarrage serveur métriques Prometheus
        start_http_server(9090)
        self.logger.info("📊 Serveur métriques Prometheus démarré sur port 9090")
        
        # Lancement tâches monitoring
        tasks = [
            asyncio.create_task(self._monitor_mcp_interactions()),
            asyncio.create_task(self._monitor_authentication_events()),
            asyncio.create_task(self._monitor_authorization_decisions()),
            asyncio.create_task(self._monitor_file_system_access()),
            asyncio.create_task(self._monitor_database_interactions()),
            asyncio.create_task(self._process_security_events()),
            asyncio.create_task(self._detect_anomalies()),
            asyncio.create_task(self._compliance_monitoring()),
            asyncio.create_task(self._generate_real_time_alerts())
        ]
        
        await asyncio.gather(*tasks)

    async def _monitor_mcp_interactions(self):
        """Surveillance interactions MCP en temps réel"""
        self.logger.info("🔍 Monitoring interactions MCP actif")
        
        while True:
            try:
                # Lecture logs MCP en temps réel
                async with aiofiles.open('/var/log/bmad/audit/mcp-audit.log', 'r') as f:
                    await f.seek(0, 2)  # Fin du fichier
                    
                    while True:
                        line = await f.readline()
                        if not line:
                            await asyncio.sleep(0.1)
                            continue
                            
                        try:
                            event_data = json.loads(line.strip())
                            await self._process_mcp_event(event_data)
                        except json.JSONDecodeError:
                            continue
                            
            except Exception as e:
                self.logger.error(f"Erreur monitoring MCP: {e}")
                await asyncio.sleep(5)

    async def _process_mcp_event(self, event_data: Dict):
        """Traite événement MCP individuel"""
        agent_id = event_data.get('agent_id', 'unknown')
        method = event_data.get('method', 'unknown')
        server_name = event_data.get('server_name', 'unknown')
        response_time = event_data.get('duration_ms', 0) / 1000
        
        # Métriques Prometheus
        RESPONSE_TIME.labels(server=server_name, method=method).observe(response_time)
        
        # Détection patterns suspects
        risk_indicators = self._analyze_mcp_event_risk(event_data)
        
        if risk_indicators:
            security_event = SecurityEvent(
                timestamp=datetime.now(),
                agent_id=agent_id,
                event_type='mcp_interaction',
                severity=self._calculate_severity(risk_indicators),
                resource=server_name,
                action=method,
                source_ip=event_data.get('source_ip', ''),
                user_agent=event_data.get('user_agent', ''),
                details=event_data,
                risk_score=sum(indicator['score'] for indicator in risk_indicators),
                compliance_flags=[]
            )
            
            await self.event_queue.put(security_event)

    def _analyze_mcp_event_risk(self, event_data: Dict) -> List[Dict]:
        """Analyse risques événement MCP"""
        risk_indicators = []
        
        # Détection accès non autorisé
        agent_id = event_data.get('agent_id')
        server_name = event_data.get('server_name')
        method = event_data.get('method')
        
        if not self._is_access_authorized(agent_id, server_name, method):
            risk_indicators.append({
                'type': 'unauthorized_access',
                'score': 8.0,
                'description': f'Agent {agent_id} accès non autorisé {server_name}:{method}'
            })
        
        # Détection patterns temporels suspects
        hour = datetime.now().hour
        if hour < 6 or hour > 22:  # Accès hors heures
            risk_indicators.append({
                'type': 'off_hours_access', 
                'score': 3.0,
                'description': 'Accès hors heures ouverture'
            })
        
        # Détection volume anormal requêtes
        request_rate = self._get_agent_request_rate(agent_id)
        if request_rate > 100:  # > 100 req/min
            risk_indicators.append({
                'type': 'high_request_volume',
                'score': 5.0,
                'description': f'Volume requêtes anormal: {request_rate}/min'
            })
        
        # Détection erreurs répétées
        error_rate = self._get_agent_error_rate(agent_id)
        if error_rate > 0.1:  # > 10% erreurs
            risk_indicators.append({
                'type': 'high_error_rate',
                'score': 4.0,
                'description': f'Taux erreur élevé: {error_rate:.1%}'
            })
            
        return risk_indicators

    async def _monitor_authentication_events(self):
        """Surveillance événements authentification"""
        self.logger.info("🔐 Monitoring authentification actif")
        
        auth_failures = defaultdict(int)
        lockout_tracking = {}
        
        while True:
            try:
                # Lecture events authentification Redis
                auth_events = self.redis_client.lrange('auth_events', 0, -1)
                
                for event_json in auth_events:
                    event_data = json.loads(event_json)
                    agent_id = event_data['agent_id']
                    success = event_data['success']
                    
                    # Métriques
                    status = 'success' if success else 'failure'
                    AUTHENTICATION_ATTEMPTS.labels(agent=agent_id, status=status).inc()
                    
                    if not success:
                        auth_failures[agent_id] += 1
                        
                        # Détection brute force
                        if auth_failures[agent_id] >= 5:
                            await self._trigger_security_lockout(agent_id, 'brute_force_attempt')
                            
                # Nettoyage compteurs (reset quotidien)
                if datetime.now().hour == 0 and datetime.now().minute == 0:
                    auth_failures.clear()
                    
                await asyncio.sleep(1)
                
            except Exception as e:
                self.logger.error(f"Erreur monitoring auth: {e}")
                await asyncio.sleep(5)

    async def _monitor_authorization_decisions(self):
        """Surveillance décisions autorisation"""
        self.logger.info("🛡️ Monitoring autorisation actif")
        
        while True:
            try:
                # Requête décisions autorisation récentes
                query = """
                SELECT agent_id, resource, action, decision, timestamp, policy_matched
                FROM authorization_log 
                WHERE timestamp > NOW() - INTERVAL '1 minute'
                ORDER BY timestamp DESC
                """
                
                cursor = self.postgres_conn.cursor(cursor_factory=RealDictCursor)
                cursor.execute(query)
                decisions = cursor.fetchall()
                
                for decision in decisions:
                    agent_id = decision['agent_id']
                    resource = decision['resource']
                    decision_result = decision['decision']
                    
                    # Métriques
                    AUTHORIZATION_DECISIONS.labels(
                        agent=agent_id, 
                        resource=resource, 
                        decision=decision_result
                    ).inc()
                    
                    # Détection tentatives escalade privilèges
                    if decision_result == 'DENIED':
                        risk_score = self._calculate_privilege_escalation_risk(decision)
                        
                        if risk_score > 7.0:
                            security_event = SecurityEvent(
                                timestamp=datetime.now(),
                                agent_id=agent_id,
                                event_type='privilege_escalation_attempt',
                                severity='HIGH',
                                resource=resource,
                                action=decision['action'],
                                source_ip='',
                                user_agent='',
                                details=dict(decision),
                                risk_score=risk_score,
                                compliance_flags=['SOX', 'PCI_DSS']
                            )
                            
                            await self.event_queue.put(security_event)
                
                await asyncio.sleep(10)
                
            except Exception as e:
                self.logger.error(f"Erreur monitoring authz: {e}")
                await asyncio.sleep(5)

    async def _detect_anomalies(self):
        """Détection anomalies comportementales"""
        self.logger.info("🔍 Détection anomalies active")
        
        while True:
            try:
                # Collecte métriques agents dernières 24h
                metrics = await self._collect_agent_metrics()
                
                for agent_id, agent_metrics in metrics.items():
                    # Mise à jour baseline (30 jours glissants)
                    baseline = self.baseline_metrics[agent_id]
                    baseline.append(agent_metrics)
                    
                    if len(baseline) > 30 * 24:  # 30 jours * 24 heures
                        baseline.popleft()
                    
                    # Détection anomalies si baseline suffisante
                    if len(baseline) >= 7 * 24:  # Minimum 7 jours
                        anomalies = self._detect_agent_anomalies(agent_id, agent_metrics, baseline)
                        
                        for anomaly in anomalies:
                            security_event = SecurityEvent(
                                timestamp=datetime.now(),
                                agent_id=agent_id,
                                event_type='behavioral_anomaly',
                                severity=anomaly['severity'],
                                resource=anomaly['metric'],
                                action='anomaly_detected',
                                source_ip='',
                                user_agent='',
                                details=anomaly,
                                risk_score=anomaly['risk_score'],
                                compliance_flags=['MONITORING']
                            )
                            
                            await self.event_queue.put(security_event)
                
                await asyncio.sleep(3600)  # Analyse horaire
                
            except Exception as e:
                self.logger.error(f"Erreur détection anomalies: {e}")
                await asyncio.sleep(300)

    async def _compliance_monitoring(self):
        """Surveillance compliance temps réel"""
        self.logger.info("📋 Monitoring compliance actif")
        
        while True:
            try:
                # Vérification policies compliance
                violations = []
                
                # Politique: rétention logs audit
                retention_violation = await self._check_audit_retention_policy()
                if retention_violation:
                    violations.append(retention_violation)
                
                # Politique: chiffrement obligatoire
                encryption_violation = await self._check_encryption_policy()
                if encryption_violation:
                    violations.append(encryption_violation)
                
                # Politique: accès least privilege
                privilege_violations = await self._check_least_privilege_policy()
                violations.extend(privilege_violations)
                
                # Politique: ségrégation duties
                segregation_violations = await self._check_segregation_policy()
                violations.extend(segregation_violations)
                
                # Traitement violations détectées
                for violation in violations:
                    self.violation_history.append(violation)
                    
                    # Escalade selon sévérité
                    if violation.severity in ['HIGH', 'CRITICAL']:
                        await self._escalate_compliance_violation(violation)
                
                await asyncio.sleep(1800)  # Vérification 30min
                
            except Exception as e:
                self.logger.error(f"Erreur monitoring compliance: {e}")
                await asyncio.sleep(300)

    async def _generate_real_time_alerts(self):
        """Génération alertes temps réel"""
        self.logger.info("🚨 Générateur alertes temps réel actif")
        
        alert_rules = self._load_alert_rules()
        
        while True:
            try:
                # Traitement événements en attente
                while not self.event_queue.empty():
                    security_event = await self.event_queue.get()
                    
                    # Évaluation règles alerte
                    for rule in alert_rules:
                        if self._event_matches_rule(security_event, rule):
                            alert = self._create_alert(security_event, rule)
                            await self._send_alert(alert)
                    
                    # Persistence événement
                    await self._store_security_event(security_event)
                
                await asyncio.sleep(1)
                
            except Exception as e:
                self.logger.error(f"Erreur génération alertes: {e}")
                await asyncio.sleep(5)

    def _load_alert_rules(self) -> List[Dict]:
        """Charge règles alertes sécurité"""
        return [
            {
                'name': 'unauthorized_access_critical',
                'conditions': {
                    'event_type': 'mcp_interaction',
                    'risk_score': {'min': 8.0},
                    'severity': ['HIGH', 'CRITICAL']
                },
                'actions': ['email', 'slack', 'pagerduty'],
                'cooldown': 300  # 5 minutes
            },
            {
                'name': 'brute_force_attempt',
                'conditions': {
                    'event_type': 'authentication',
                    'pattern': 'repeated_failures'
                },
                'actions': ['email', 'auto_lockout'],
                'cooldown': 60
            },
            {
                'name': 'privilege_escalation',
                'conditions': {
                    'event_type': 'privilege_escalation_attempt',
                    'severity': ['HIGH', 'CRITICAL']
                },
                'actions': ['email', 'slack', 'incident_creation'],
                'cooldown': 0  # Pas de cooldown pour escalade privilèges
            },
            {
                'name': 'compliance_violation_critical',
                'conditions': {
                    'event_type': 'compliance_violation',
                    'severity': 'CRITICAL'
                },
                'actions': ['email', 'compliance_team', 'auto_remediation'],
                'cooldown': 1800  # 30 minutes
            }
        ]

    async def _send_alert(self, alert: Dict):
        """Envoie alerte selon canaux configurés"""
        alert_id = alert['id']
        channels = alert['channels']
        
        self.logger.warning(f"🚨 ALERTE SÉCURITÉ: {alert_id}")
        
        for channel in channels:
            try:
                if channel == 'email':
                    await self._send_email_alert(alert)
                elif channel == 'slack':
                    await self._send_slack_alert(alert)
                elif channel == 'pagerduty':
                    await self._send_pagerduty_alert(alert)
                elif channel == 'auto_lockout':
                    await self._execute_auto_lockout(alert)
                    
            except Exception as e:
                self.logger.error(f"Erreur envoi alerte {channel}: {e}")

    async def _send_slack_alert(self, alert: Dict):
        """Envoie alerte Slack"""
        webhook_url = self.config.get('slack_webhook_url')
        if not webhook_url:
            return
            
        message = {
            "text": f"🚨 ALERTE SÉCURITÉ BMAD MCP",
            "attachments": [
                {
                    "color": "danger" if alert['severity'] in ['HIGH', 'CRITICAL'] else "warning",
                    "fields": [
                        {"title": "Agent", "value": alert['agent_id'], "short": True},
                        {"title": "Type", "value": alert['event_type'], "short": True},
                        {"title": "Sévérité", "value": alert['severity'], "short": True},
                        {"title": "Score Risque", "value": str(alert['risk_score']), "short": True},
                        {"title": "Description", "value": alert['description'], "short": False}
                    ],
                    "ts": int(time.time())
                }
            ]
        }
        
        async with aiohttp.ClientSession() as session:
            await session.post(webhook_url, json=message)

def create_security_monitoring_dashboard():
    """Crée dashboard monitoring sécurité"""
    dashboard_config = {
        "dashboard": {
            "title": "BMAD MCP Security Monitoring",
            "panels": [
                {
                    "title": "Security Events by Severity",
                    "type": "graph",
                    "targets": [
                        {
                            "expr": 'rate(bmad_security_events_total[5m])',
                            "legend": "{{severity}} - {{event_type}}"
                        }
                    ]
                },
                {
                    "title": "Authentication Success Rate",
                    "type": "singlestat",
                    "targets": [
                        {
                            "expr": 'rate(bmad_auth_attempts_total{status="success"}[5m]) / rate(bmad_auth_attempts_total[5m])',
                            "legend": "Success Rate"
                        }
                    ]
                },
                {
                    "title": "Authorization Decisions",
                    "type": "piechart",
                    "targets": [
                        {
                            "expr": 'bmad_authz_decisions_total',
                            "legend": "{{decision}}"
                        }
                    ]
                },
                {
                    "title": "MCP Response Times",
                    "type": "graph",
                    "targets": [
                        {
                            "expr": 'histogram_quantile(0.95, rate(bmad_mcp_response_time_seconds_bucket[5m]))',
                            "legend": "95th percentile"
                        }
                    ]
                }
            ]
        }
    }
    
    with open('/var/log/bmad/security-dashboard.json', 'w') as f:
        json.dump(dashboard_config, f, indent=2)

async def main():
    """Point d'entrée monitoring sécurité"""
    print("🔒 BMAD MCP ENTERPRISE SECURITY MONITORING")
    print("=" * 50)
    
    # Configuration
    config = {
        'redis': {
            'host': 'localhost',
            'port': 6379,
            'db': 1
        },
        'postgres': {
            'host': 'localhost',
            'database': 'bmad_coordination',
            'user': 'security_monitor',
            'password': 'secure_password'
        },
        'slack_webhook_url': 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
    }
    
    # Démarrage monitoring
    processor = SecurityEventProcessor(config)
    
    # Création dashboard
    create_security_monitoring_dashboard()
    
    # Lancement monitoring temps réel
    await processor.start_monitoring()

if __name__ == "__main__":
    asyncio.run(main())