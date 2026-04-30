#!/bin/bash
# =============================================================================
# TC-08: Send a webhook with an INVALID signature — expect 401 rejection
# =============================================================================

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

WEBHOOK_URL="${SPECSHIELD_WEBHOOK_URL:-https://specshield.io/webhooks/github}"

echo ""
echo -e "${YELLOW}[TC-08] Sending webhook with invalid signature...${NC}"
echo -e "  Target: ${BLUE}$WEBHOOK_URL${NC}"
echo ""

PAYLOAD='{"action":"opened","number":999,"pull_request":{"title":"Fake PR","head":{"ref":"fake","sha":"abc123"},"base":{"ref":"main"}},"repository":{"full_name":"fake/repo"},"installation":{"id":0}}'

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: pull_request" \
  -H "X-Hub-Signature-256: sha256=0000000000000000000000000000000000000000000000000000000000000000" \
  -d "$PAYLOAD")

HTTP_BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)

echo -e "  Response code : ${HTTP_CODE}"
echo -e "  Response body : ${HTTP_BODY}"
echo ""

if [ "$HTTP_CODE" = "401" ]; then
  echo -e "${GREEN}✓ TC-08 PASSED — Server correctly rejected the invalid signature with 401${NC}"
else
  echo -e "${RED}✗ TC-08 FAILED — Expected 401 but got $HTTP_CODE${NC}"
fi
echo ""
