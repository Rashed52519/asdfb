# TASKS.md — Backlog (MVP)

## T1 — /codex/eligible (Shopify filter)
- GraphQL: list OPEN, UNFULFILLED/PARTIALLY_FULFILLED with fulfillableQuantity>0.
- Paid OR COD (PENDING + gateway contains "cash" and "delivery").
- Output array ready for delivery creation with `cod_sar` = totalOutstanding when COD.

## T2 — /codex/sync
- Create deliveries in `dispatch` from T1 result.
- Idempotent by `shop_order_gid`.

## T3 — /webhooks/shopify/order-paid
- Upsert and re-check eligibility using T1 logic.

## T4 — courier driver auth
- `POST /driver/auth/issue` JWT, store in Keychain on iOS (client later).

## T5 — notifications
- `POST /push/register` save APNs token; handle 410 cleanup on feedback.

## T6 — tests
- Pytest for T1–T3 happy/edge paths. HTTP mocked. No network.

## T7 — iOS scaffold (driver)
- Create SwiftUI app with screens: JobsList, JobDetail, POD (signature/photos), Settings.
- Arabic/RTL. Accessibility labels. No external libs.
- Networking layer with JWT storage in Keychain placeholder.

## T8 — docs
- Minimal README per service with run commands.
