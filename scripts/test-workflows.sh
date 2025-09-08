#!/bin/bash

# BMAD+Contains Studio CI/CD Workflow Integration Tests
# This script validates all GitHub Actions workflows locally

set -e

echo "🚀 BMAD+Contains Studio CI/CD Workflow Integration Tests"
echo "========================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Function to run test and track results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "\n${BLUE}🧪 Testing: $test_name${NC}"
    echo "Command: $test_command"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        
        # Show error details
        echo -e "${YELLOW}Error details:${NC}"
        eval "$test_command"
    fi
}

# Function to check if command exists
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ Required command '$1' not found${NC}"
        echo "Please install $1 to run these tests"
        exit 1
    fi
}

# Check prerequisites
echo -e "\n${BLUE}🔍 Checking Prerequisites${NC}"
check_command "jq"
check_command "git"
check_command "python3"
check_command "node"
check_command "npm"

# Install additional tools if needed
if ! command -v yamllint &> /dev/null; then
    echo -e "${YELLOW}⚠️  Installing yamllint...${NC}"
    pip install yamllint || pip3 install yamllint
fi

# Test 1: Validate GitHub Workflows YAML Syntax
echo -e "\n${BLUE}📋 Test Group 1: GitHub Workflows Validation${NC}"

run_test "BMAD CI Workflow YAML" "yamllint .github/workflows/bmad-ci.yml"
run_test "Claude Code PR Review YAML" "yamllint .github/workflows/claude-code-pr-review.yml"
run_test "MCP Validation YAML" "yamllint .github/workflows/mcp-validation.yml"
run_test "Weekly Reports YAML" "yamllint .github/workflows/weekly-reports.yml"

# Test 2: MCP Configuration Validation
echo -e "\n${BLUE}📋 Test Group 2: MCP Configuration Validation${NC}"

run_test "MCP JSON Structure" "jq . project.mcp.json"
run_test "MCP Security Configuration" "jq -e '.mcp_security' project.mcp.json"
run_test "MCP Permissions Matrix" "jq -e '.permissions_matrix' project.mcp.json"
run_test "MCP Servers Configuration" "jq -e '.mcpServers | length > 0' project.mcp.json"

# Test 3: Security Configuration Validation
echo -e "\n${BLUE}📋 Test Group 3: Security Configuration Validation${NC}"

run_test "Security Posture Check" "jq -e '.mcp_security.security_posture == \"enterprise_zero_trust\"' project.mcp.json"
run_test "Audit Logging Enabled" "jq -e '.mcp_security.audit_logging.enabled == true' project.mcp.json"
run_test "TLS 1.3 Encryption" "jq -e '.mcp_security.access_control.encrypted_connections == \"TLS_1_3\"' project.mcp.json"
run_test "Compliance Frameworks" "jq -e '.mcp_security.compliance.soc2_enabled == true' project.mcp.json"

# Test 4: Agent Configuration Validation
echo -e "\n${BLUE}📋 Test Group 4: Agent Configuration Validation${NC}"

run_test "BMAD Core Directory" "test -d .bmad-core"
run_test "Claude Configuration" "test -f CLAUDE.md"
run_test "Agent Harmonization Pack" "test -d agents-harmonization-pack"
run_test "Security Directory" "test -d security"

# Test 5: Workflow Logic Validation
echo -e "\n${BLUE}📋 Test Group 5: Workflow Logic Validation${NC}"

# Test workflow job dependencies
run_test "CI Pipeline Dependencies" "grep -q 'needs:' .github/workflows/bmad-ci.yml"
run_test "MCP Validation Matrix" "grep -q 'matrix:' .github/workflows/mcp-validation.yml"
run_test "Weekly Reports Schedule" "grep -q 'cron:' .github/workflows/weekly-reports.yml"
run_test "PR Review Triggers" "grep -q 'pull_request:' .github/workflows/claude-code-pr-review.yml"

# Test 6: Performance Validation
echo -e "\n${BLUE}📋 Test Group 6: Performance Validation${NC}"

# Test configuration parsing performance
run_test "MCP Config Parsing Speed" "time jq '.mcpServers' project.mcp.json"
run_test "Workflow File Size Check" "test \$(stat -c%s .github/workflows/bmad-ci.yml) -lt 51200"  # < 50KB
run_test "MCP Config Size Check" "test \$(stat -c%s project.mcp.json) -lt 20480"  # < 20KB

# Test 7: Integration Points Validation
echo -e "\n${BLUE}📋 Test Group 7: Integration Points Validation${NC}"

# Check for required integration points
run_test "GitHub Actions Integration" "grep -q 'actions/checkout@v4' .github/workflows/bmad-ci.yml"
run_test "Node.js Setup Integration" "grep -q 'actions/setup-node@v4' .github/workflows/bmad-ci.yml"
run_test "Python Setup Integration" "grep -q 'actions/setup-python@v4' .github/workflows/bmad-ci.yml"
run_test "Artifact Upload Integration" "grep -q 'actions/upload-artifact@v4' .github/workflows/bmad-ci.yml"

# Test 8: Security Integration Validation  
echo -e "\n${BLUE}📋 Test Group 8: Security Integration Validation${NC}"

# Validate security scanning integration
run_test "Security Scanning Job" "grep -q 'security-scan' .github/workflows/bmad-ci.yml"
run_test "MCP Security Validation" "grep -q 'mcp-security-validation' .github/workflows/mcp-validation.yml"
run_test "Permissions Matrix Validation" "grep -q 'permissions_matrix' .github/workflows/mcp-validation.yml"
run_test "TLS Configuration Check" "grep -q 'TLS_1_3' project.mcp.json"

# Test 9: Monitoring and Reporting Integration
echo -e "\n${BLUE}📋 Test Group 9: Monitoring Integration Validation${NC}"

run_test "Weekly Reports Schedule" "grep -q '0 9 \* \* 1' .github/workflows/weekly-reports.yml"
run_test "Health Check Schedule" "grep -q '0 \*/6 \* \* \*' .github/workflows/mcp-validation.yml"
run_test "Report Artifacts" "grep -q 'upload-artifact' .github/workflows/weekly-reports.yml"
run_test "Issue Creation" "grep -q 'github-script' .github/workflows/weekly-reports.yml"

# Test 10: Claude Code Integration Validation
echo -e "\n${BLUE}📋 Test Group 10: Claude Code Integration Validation${NC}"

run_test "Claude Commands Handler" "grep -q '/claude' .github/workflows/claude-code-pr-review.yml"
run_test "PR Review Automation" "grep -q 'claude-code-review' .github/workflows/claude-code-pr-review.yml"
run_test "Interactive Commands" "grep -q 'claude-code-commands' .github/workflows/claude-code-pr-review.yml"
run_test "CLAUDE.md Configuration" "test -f CLAUDE.md"

# Test Summary
echo -e "\n${BLUE}📊 Test Summary${NC}"
echo "==============="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "${GREEN}Failed: $TESTS_FAILED${NC}"
fi

# Calculate success rate
SUCCESS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
echo -e "Success Rate: $SUCCESS_RATE%"

# Final result
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All integration tests passed!${NC}"
    echo -e "${GREEN}✅ BMAD+Contains Studio CI/CD workflows are ready for deployment${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some integration tests failed${NC}"
    echo -e "${RED}Please review the failed tests above and fix the issues${NC}"
    exit 1
fi