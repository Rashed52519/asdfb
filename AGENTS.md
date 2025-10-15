# AGENTS.md — Frova Drive
## Goal
Ship eligible Shopify orders in Riyadh within 1–2 business days. Build: Python FastAPI backend + SwiftUI iOS (driver).

## Source of truth
- Start with `TASKS.md` top-to-bottom. No scope creep.
- Create missing folders/files if absent.

## Repo layout (target)
backend/services/{codex,dispatch,courier}/
ios/FrovaDriver/

## Environments & secrets (do NOT log)
SHOP_DOMAIN, ADMIN_API_TOKEN, APNS_KEY_ID, APNS_TEAM_ID, APNS_TOPIC, APNS_PRIVATE_KEY, JWT_SECRET.

## Python (backend)
- Python 3.12.
- Setup:
  ```bash
  cd backend && python -m venv .venv && . .venv/bin/activate
  pip install -r requirements-dev.txt
  ```
- Test: `pytest -q`
- Lint: `ruff check .`
- Style: black defaults. No PII in logs. Timeouts on HTTP calls (≤15s). Idempotency on creates.

## iOS (SwiftUI)
- iOS 17, Swift 5.9, RTL/ar_SA. No 3rd-party.
- Create project under `ios/FrovaDriver` with schemes: FrovaDriver, FrovaDriverTests.
- Build guidance only (don’t run Xcode here). Ensure code compiles locally for Swift 5.9.

## Definition of Done (backend)
- Endpoint + tests passing + docstring + error handling.

## PR rules
- Branch: `codex/<task-id>-<slug>`
- Commits: imperative, small. Include reasoning in PR body.
