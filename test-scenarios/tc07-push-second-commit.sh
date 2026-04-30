#!/bin/bash
# =============================================================================
# TC-07: Push a second commit to the open PR to trigger the "synchronize" event
# Run AFTER you have opened a PR for test/tc07-synchronize on GitHub
# =============================================================================

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo ""
echo -e "${YELLOW}[TC-07] Pushing second commit to trigger synchronize event...${NC}"

CURRENT=$(git branch --show-current)
if [ "$CURRENT" != "test/tc07-synchronize" ]; then
  git checkout test/tc07-synchronize
fi

# Make a small additional change to the spec
sed -i '' 's/version: "1.1.0"/version: "1.1.1"/' openapi.yaml
echo "  x-updated-by: TC-07-second-commit" >> openapi.yaml

git add openapi.yaml
git commit -m "fix(TC-07): second commit — triggers synchronize webhook event

This commit causes GitHub to fire the 'pull_request' webhook with
action=synchronize. SpecShield should create a NEW check run for
this commit SHA (separate from the first check run)."

git push origin test/tc07-synchronize

echo ""
echo -e "${GREEN}✓ Second commit pushed to test/tc07-synchronize${NC}"
echo -e "${BLUE}  Watch the PR on GitHub — a new SpecShield check run should appear.${NC}"
echo -e "${BLUE}  The dashboard PR history should now show 2 rows for this PR.${NC}"
echo ""
