# TC-05: Spec Added for the First Time (Neutral Result)

This scenario requires a repo that has NO `openapi.yaml` on `main`.
It cannot be done in this project (which already has the spec on main).

## Option A — Use a brand new GitHub repository

1. Create a new empty GitHub repo on GitHub (no files).
2. Install the SpecShield GitHub App on it.
3. Clone it locally:
   ```bash
   git clone https://github.com/YOUR_ORG/your-new-repo.git
   cd your-new-repo
   ```
4. Create main with only a README (no spec):
   ```bash
   echo "# New Project" > README.md
   git add README.md && git commit -m "initial commit"
   git push origin main
   ```
5. Create a branch that adds the spec for the first time:
   ```bash
   git checkout -b feat/add-openapi-spec
   cp /path/to/specshield-test-api/openapi.yaml openapi.yaml
   git add openapi.yaml && git commit -m "feat: add OpenAPI spec for the first time"
   git push origin feat/add-openapi-spec
   ```
6. Open a PR: `feat/add-openapi-spec` → `main`

## Option B — Temporarily remove spec from this repo's main

> ⚠️ Only do this in a test environment — do NOT do this on a shared/production repo.

```bash
git checkout main
git rm openapi.yaml
git commit -m "temp: remove spec to test TC-05 (revert after test)"
git push origin main

# Now create a branch that adds it back
git checkout -b test/tc05-spec-first-time
cp test-scenarios/tc03-nonbreaking/openapi.yaml openapi.yaml
git add openapi.yaml && git commit -m "feat(TC-05): add OpenAPI spec for first time"
git push origin test/tc05-spec-first-time
```

Open PR → watch SpecShield show **neutral** result.

After the test, restore main:
```bash
git checkout main
git revert HEAD
git push origin main
```

## Expected Result
- Check run conclusion: **neutral**
- Title: "OpenAPI spec added"
- Message: "A new spec was introduced at `openapi.yaml`. No base to compare against."
- PR is NOT blocked — merge proceeds normally.
