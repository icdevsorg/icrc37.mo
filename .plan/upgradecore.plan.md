# ICRC-37 Core Upgrade & Feature Expansion Plan

This document outlines the discrete tasks to refactor `icrc37.mo` to universally use the `mo:core` library (instead of `mo:base` and standalone `map9`/`vector` packages), introduce interceptor patterns (`Interface.mo`), and improve robustness via Edge Case Testing.

## Phase 1: Dependency Upgrade & Foundation

- [ ] **Task 1.1:** Update `mops.toml` to remove deprecated packages (`map9`, `map`, `vector`, `base-0.7.3`).
- [ ] **Task 1.2:** Add `core = "2.1.0"` to `mops.toml` dependencies. Bump standard libraries (`base = "0.16.0"`, `candy = "0.3.1"`, `class-plus = "0.2.1"`, `icrc7-mo = "0.5.0"` or later). Ensure `moc = "1.3.0"` in `[toolchain]`.
- [ ] **Task 1.3:** Universally replace `mo:base` imports with `mo:core` across the entire `src/` directory.
- [ ] **Task 1.4:** Replace all instances of `import Map "mo:map9/..."` and `import Map "mo:map/..."` with `import Map "mo:core/Map"` in `src/`. Refactor associated data types from `map9.Map<K, V>` to `Map.Map<K, V>`.
- [ ] **Task 1.5:** Replace all instances of `import Vector "mo:vector/... "` with `mo:core/List` or `mo:core/Array` across the `src/` directory. Refactor state structures that used `Vector` to instead utilize scalable `List` or immutable `Array` paradigms equivalent to the updated standard.

## Phase 2: Convenience Features & Interceptors

- [ ] **Task 2.1:** Create `src/Inspect.mo` to introduce `guard` functions protecting against cycle-drain attacks (sizing checks for arrays and payload bounds). Specific to ICRC-37 operations (e.g., `approve_tokens`, `transfer_from`, `revoke_token_approvals`, `is_approved`).
- [ ] **Task 2.2:** Create `src/Interface.mo` to define hook structures for the ICRC-37 context (e.g., `beforeApprove`, `afterApprove`, `beforeTransferFrom`, `afterTransferFrom`).
- [ ] **Task 2.3:** Refactor `src/mixin.mo` (and update endpoints in `src/lib.mo` / `src/service.mo` as applicable) to wrap standard lifecycle methods in `Interface.executeQuery` and `Interface.execute(...)`, ensuring consuming canisters can intercept and log specific actions natively.

## Phase 3: Integrity & Edge Case Testing

- [ ] **Task 3.1:** Map/List Transition Validation: Ensure that the testing suite fully passes under `mo:core`, validating that token approvals map structures initialize, load, and preserve referential integrity properly.
- [ ] **Task 3.2:** Batch Size Limit Boundary Test: Validate maximum array sizes in `approve_tokens` and `revoke_token_approvals` throw intentional traps/hard limits using the new `Inspect.mo` limits.
- [ ] **Task 3.3:** Subaccount bounds: Ensure `{owner = X; subaccount = null}` vs `{owner = X; subaccount = ?[0,0...]}` canonical equality resolves properly for approvals and checks.
- [ ] **Task 3.4:** Deep Expiration Validation: Test expiration boundary guarantees using mocked time environments or precise timestamp structures to ensure lapsed approvals are thoroughly rejected.
