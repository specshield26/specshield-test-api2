#!/bin/bash
# =============================================================================
# SpecShield GitHub Integration — Test Branch Setup Script
# Run this from the ROOT of the specshield-test-api repo (not from test-scenarios/)
# Usage: bash test-scenarios/setup-all-branches.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   SpecShield — GitHub Integration Test Branch Setup          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Guard: must be on main ────────────────────────────────────────────────────
CURRENT=$(git branch --show-current)
if [ "$CURRENT" != "main" ]; then
  echo -e "${RED}✗ Error: You must be on 'main' before running this script.${NC}"
  echo -e "  Run: ${YELLOW}git checkout main${NC}"
  exit 1
fi

# ── Guard: working tree must be clean ─────────────────────────────────────────
if [ -n "$(git status --porcelain)" ]; then
  echo -e "${RED}✗ Error: Working tree is not clean. Commit or stash changes first.${NC}"
  git status --short
  exit 1
fi

echo -e "${GREEN}✓ Starting from clean 'main' branch${NC}"
echo ""

cleanup_branch() {
  local BRANCH=$1
  if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git branch -D "$BRANCH" > /dev/null 2>&1
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# TC-02 — No spec change (README only)
# Expected: SpecShield check passes silently, no PR comment
# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}[TC-02]${NC} Creating branch: no spec change (README update only)..."
cleanup_branch "test/tc02-no-spec-change"
git checkout -b test/tc02-no-spec-change > /dev/null 2>&1
echo "" >> README.md
echo "<!-- Updated by TC-02 test script -->" >> README.md
git add README.md
git commit -m "test(TC-02): update README only — spec unchanged

SpecShield should: pass silently with no PR comment.
No openapi.yaml changes in this commit." > /dev/null 2>&1
git checkout main > /dev/null 2>&1
echo -e "  ${GREEN}✓ test/tc02-no-spec-change${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# TC-03 — Non-breaking change (add /products endpoint)
# Expected: check passes, PR comment shows additions
# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}[TC-03]${NC} Creating branch: add /products endpoint (non-breaking)..."
cleanup_branch "test/tc03-add-endpoint"
git checkout -b test/tc03-add-endpoint > /dev/null 2>&1
cp test-scenarios/tc03-nonbreaking/openapi.yaml openapi.yaml
git add openapi.yaml
git commit -m "feat(TC-03): add GET /products and GET /products/{id} endpoints

Non-breaking additions:
- New /products endpoint (list all products)
- New /products/{id} endpoint (get single product)
- New Product schema added to components

SpecShield should: pass with additions comment showing 2 new endpoints." > /dev/null 2>&1
git checkout main > /dev/null 2>&1
echo -e "  ${GREEN}✓ test/tc03-add-endpoint${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# TC-04 — Breaking changes (remove email field + remove DELETE endpoint)
# Expected: check fails, PR blocked, comment shows breaking changes
# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}[TC-04]${NC} Creating branch: breaking changes (field removed + endpoint removed)..."
cleanup_branch "test/tc04-breaking-change"
git checkout -b test/tc04-breaking-change > /dev/null 2>&1
cp test-scenarios/tc04-breaking/openapi.yaml openapi.yaml
git add openapi.yaml
git commit -m "BREAKING(TC-04): remove email field and DELETE /users/{id} endpoint

Breaking changes introduced:
- 'email' field removed from User response schema
- 'email' removed from CreateUserRequest required fields
- DELETE /users/{id} endpoint removed entirely

SpecShield should: FAIL the PR check and block the merge." > /dev/null 2>&1
git checkout main > /dev/null 2>&1
echo -e "  ${GREEN}✓ test/tc04-breaking-change${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# TC-07 — Synchronize (first commit, then push a second to trigger re-check)
# Expected: second push creates a new check run
# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}[TC-07]${NC} Creating branch: synchronize test (open PR, then push second commit)..."
cleanup_branch "test/tc07-synchronize"
git checkout -b test/tc07-synchronize > /dev/null 2>&1
cp test-scenarios/tc03-nonbreaking/openapi.yaml openapi.yaml
git add openapi.yaml
git commit -m "feat(TC-07): first commit — add /products endpoint

Open a PR with this commit, wait for SpecShield to run.
Then push tc07-second-commit.sh to trigger the synchronize event." > /dev/null 2>&1
git checkout main > /dev/null 2>&1
echo -e "  ${GREEN}✓ test/tc07-synchronize${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# TC-10 — Delete openapi.yaml (spec removed from PR branch)
# Expected: check fails with "OpenAPI spec deleted" message
# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}[TC-10]${NC} Creating branch: delete openapi.yaml..."
cleanup_branch "test/tc10-delete-spec"
git checkout -b test/tc10-delete-spec > /dev/null 2>&1
git rm openapi.yaml > /dev/null 2>&1
git commit -m "chore(TC-10): delete openapi.yaml from repository

Simulates a team accidentally or intentionally removing the API spec.

SpecShield should: FAIL with 'OpenAPI spec deleted' and block the merge." > /dev/null 2>&1
git checkout main > /dev/null 2>&1
echo -e "  ${GREEN}✓ test/tc10-delete-spec${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# TC-12 — Breaking change on fail-on-breaking=false repo (warn only)
# Same spec as TC-04, but test with repo config changed in dashboard first
# ══════════════════════════════════════════════════════════════════════════════
echo -e "${BLUE}[TC-12]${NC} Creating branch: breaking change for fail-on-breaking=false test..."
cleanup_branch "test/tc12-breaking-warn-only"
git checkout -b test/tc12-breaking-warn-only > /dev/null 2>&1
cp test-scenarios/tc04-breaking/openapi.yaml openapi.yaml
git add openapi.yaml
git commit -m "BREAKING(TC-12): same breaking changes as TC-04

BEFORE opening the PR:
  1. Go to specshield.io/account/github
  2. Click Configure on this repo
  3. Uncheck 'Fail PR check on breaking changes'
  4. Save

SpecShield should: PASS (not block) but post a warning comment." > /dev/null 2>&1
git checkout main > /dev/null 2>&1
echo -e "  ${GREEN}✓ test/tc12-breaking-warn-only${NC}"

# ══════════════════════════════════════════════════════════════════════════════
# Summary
# ══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   All branches created successfully!                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Branches created:${NC}"
git branch | grep "test/"
echo ""
echo -e "${YELLOW}Step 1 — Push all branches to GitHub:${NC}"
echo -e "  ${BLUE}git push origin --all${NC}"
echo ""
echo -e "${YELLOW}Step 2 — Open Pull Requests (each branch → main):${NC}"
printf "  %-35s %s\n" "test/tc02-no-spec-change"    "→ Expect: silent pass, no comment"
printf "  %-35s %s\n" "test/tc03-add-endpoint"       "→ Expect: pass + additions comment"
printf "  %-35s %s\n" "test/tc04-breaking-change"    "→ Expect: FAIL, PR blocked"
printf "  %-35s %s\n" "test/tc07-synchronize"        "→ Expect: pass (then push 2nd commit)"
printf "  %-35s %s\n" "test/tc10-delete-spec"        "→ Expect: FAIL, spec deleted"
printf "  %-35s %s\n" "test/tc12-breaking-warn-only" "→ Expect: pass + warning (configure first)"
echo ""
echo -e "${YELLOW}Step 3 — For TC-07 synchronize, AFTER opening the PR run:${NC}"
echo -e "  ${BLUE}bash test-scenarios/tc07-push-second-commit.sh${NC}"
echo ""
echo -e "${YELLOW}Step 4 — For TC-08 invalid signature, run:${NC}"
echo -e "  ${BLUE}bash test-scenarios/tc08-invalid-signature.sh${NC}"
echo ""
echo -e "${YELLOW}Manual steps (no branch needed):${NC}"
printf "  %-8s %s\n" "TC-01:" "Install GitHub App from /account/github dashboard"
printf "  %-8s %s\n" "TC-05:" "See test-scenarios/TC05-INSTRUCTIONS.md"
printf "  %-8s %s\n" "TC-06:" "Configure repo in dashboard, change spec path to nonexistent.yaml"
printf "  %-8s %s\n" "TC-09:" "Same as TC-06 — wrong spec path triggers skip"
printf "  %-8s %s\n" "TC-11:" "Disable repo in dashboard, then open any PR"
echo ""
