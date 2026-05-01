# SpecShield Test API

A minimal Spring Boot REST API used to test the **SpecShield GitHub Integration** end-to-end.

## What This Project Tests

| Test Case | Scenario | Expected SpecShield Result |
|-----------|----------|---------------------------|
| TC-01 | Install GitHub App | Installation appears on dashboard |
| TC-02 | PR with no spec changes | Silent pass — no comment |
| TC-03 | PR adds new endpoints | Pass + additions comment |
| TC-04 | PR removes required field + endpoint | **FAIL** — PR blocked |
| TC-05 | Spec added for first time | Neutral — no base to compare |
| TC-06 | Wrong spec path configured | Skipped — spec not found |
| TC-07 | Push second commit to open PR | New check run triggered |
| TC-08 | Invalid webhook signature | 401 rejected |
| TC-09 | Spec missing on both branches | Skipped |
| TC-10 | Spec deleted on PR branch | **FAIL** — spec deleted |
| TC-11 | Repo check disabled | No check run at all |
| TC-12 | Breaking change + fail-on-breaking=false | Pass with warning comment |

---

## Quick Start Modified

### 1. Push this project to GitHub

```bash
cd /Users/deepaksatyam/IntellijProject/claude/test_projects/specshield-test-api
git init
git add .
git commit -m "initial: SpecShield test project with baseline openapi.yaml"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/specshield-test-api.git
git push -u origin main
```

### 2. Install the SpecShield GitHub App

- Go to `https://specshield.io/account/github`
- Click **"Install GitHub App"**
- Select `specshield-test-api` repository
- Click **Install**

### 3. Create All Test Branches

```bash
bash test-scenarios/setup-all-branches.sh
```

### 4. Push All Branches

```bash
git push origin --all
```

### 5. Open Pull Requests

Open a PR for each branch → `main` on GitHub, and watch SpecShield check runs appear.

---

## Running the API Locally

```bash
./mvnw spring-boot:run
```

The API runs at `http://localhost:8080`.

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /users | List all users |
| GET | /users/{id} | Get user by ID |
| POST | /users | Create a user |
| DELETE | /users/{id} | Delete a user |

### Example

```bash
# Get all users
curl http://localhost:8080/users

# Create a user
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Charlie Brown","email":"charlie@example.com"}'
```

---

## Project Structure

```
specshield-test-api/
├── openapi.yaml                        ← Baseline v1.0 spec (on main)
├── pom.xml
├── src/main/java/com/example/testapi/
│   ├── TestApiApplication.java
│   ├── controller/UserController.java
│   └── model/User.java
└── test-scenarios/
    ├── setup-all-branches.sh           ← Run this to create all test branches
    ├── tc07-push-second-commit.sh      ← Run after opening TC-07 PR
    ├── tc08-invalid-signature.sh       ← Sends bad webhook, expects 401
    ├── TC05-INSTRUCTIONS.md            ← Manual steps for TC-05
    ├── tc03-nonbreaking/openapi.yaml   ← Adds /products (non-breaking)
    └── tc04-breaking/openapi.yaml      ← Removes email field (breaking)
```

---

## API Versions

| Version | File | Changes |
|---------|------|---------|
| v1.0.0 | `openapi.yaml` (main) | Baseline: `/users`, `/users/{id}` |
| v1.1.0 | `tc03-nonbreaking/openapi.yaml` | Adds `/products`, `/products/{id}` |
| v2.0.0 | `tc04-breaking/openapi.yaml` | Removes `email` field + `DELETE /users/{id}` |
