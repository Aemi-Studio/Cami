# RFC-001: Cami Widgets-First Calendar Product Requirements

- Status: Proposed
- Version: 1.0.0
- Last Updated: 2026-02-14
- Target Release: v1.0 (MVP) with forward-compatible iOS 26+ enhancements
- Owners:
  - Product: Product Manager
  - Engineering: iOS Lead Engineer
  - Quality: QA Lead
  - Security: Security Engineer
  - Accessibility: Design Systems Engineer

## 1. Summary

This RFC defines greenfield product and engineering requirements for a widgets-first iOS calendar application. The app must provide fast, glanceable daily awareness and direct actions from Home Screen widgets, Lock Screen Live Activities, and Dynamic Island, while preserving privacy, accessibility, and reliability.

This document is the authoritative baseline for:

1. Scope and priorities
2. Functional and non-functional requirements
3. Security and privacy requirements
4. Edge-case behavior contracts
5. Development readiness and risk assessment
6. Traceability from requirements to test cases and owners

## 2. Product Intent

Build a calendar experience where the widget is the primary interface for daily planning, and the app is the secondary deep-detail surface.

### 2.1 Goals

1. Deliver complete day-at-a-glance context (events, reminders, all-day items, birthdays).
2. Support meaningful, low-friction widget actions (open item, complete reminder, create item).
3. Keep behavior deterministic under permissions, EventKit updates, and lifecycle transitions.
4. Maintain strict local-first privacy posture.
5. Ship App Store-ready quality for accessibility, performance, and reliability.

### 2.2 Non-Goals (v1)

1. Cross-platform parity outside iOS.
2. Proprietary cloud sync backend.
3. Team collaboration workflows.
4. Generative AI planning features in widget surfaces.

## 3. Scope

### 3.1 In Scope

1. iOS app and widget extension.
2. AppIntent-configurable standard widget.
3. Widget families: small, medium, large, extra large.
4. Reminder completion directly from widget.
5. Ongoing event Live Activity with Dynamic Island variants.
6. In-app widget settings and preview simulator.
7. Widget support tutorial and manual refresh controls.
8. Deep linking from widget surfaces to app and system destinations.
9. Localization and accessibility requirements.

### 3.2 Out of Scope

1. watchOS complications.
2. macOS/iPadOS standalone widget variants beyond standard families.
3. Server-side scheduling APIs.
4. Full CRUD editing UI in widgets.

## 4. Platform and Technical Baseline

| Area | Requirement |
|---|---|
| Language | Swift 6.2+ |
| UI | SwiftUI (latest stable) |
| Minimum iOS | iOS 18+ |
| Forward compatibility | Adopt iOS 26+ APIs with `#available` gating |
| Concurrency | Strict Concurrency checking enabled |
| Architecture | SOLID, DRY, KISS, Law of Demeter, composition-first |
| Core frameworks | WidgetKit, AppIntents, ActivityKit, EventKit, Contacts |

## 5. User Personas and Core Jobs

| Persona | Job To Be Done | Success Metric |
|---|---|---|
| Calendar-heavy professional | See what matters next without app launch | User can identify next relevant action in under 3 seconds |
| Reminder-driven user | Complete tasks from widget | Reminder completion from widget succeeds and refreshes content |
| Personal-life planner | Track birthdays and all-day events | Birthday and all-day signals appear accurately |
| Privacy-sensitive user | Keep personal data local | No remote transmission of calendar/contact/reminder content |
| Accessibility user | Operate all key flows with assistive tech | VoiceOver, Dynamic Type, and contrast compliance across critical paths |

## 6. Functional Requirements

## 6.1 Permissions and Setup

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-001 | Request and honor calendar permission before event features are active | Must | Event surfaces degrade safely when denied |
| FR-002 | Request and honor reminders permission before reminder features are active | Must | Reminder rows disabled or hidden when denied |
| FR-003 | Request and honor contacts permission for birthday enrichment | Should | Birthday fallback UI works without contact names/ages |
| FR-004 | Permission state changes trigger widget refresh workflow | Must | Updated widget state visible after permission transition |
| FR-005 | Expose user-facing widget setup tutorial entry point | Should | Tutorial link reachable from settings |

## 6.2 Widget Configuration (AppIntent)

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-010 | Provide AppIntent widget configuration schema | Must | Configuration options are visible in system editor |
| FR-011 | Complication options: hidden, birthdays, summary | Must | Header corner behavior matches selected mode |
| FR-012 | Calendar selection for standard event feed | Must | Event rows filtered to selected calendars |
| FR-013 | Inline all-day calendar selection | Must | Inline indicators filtered to selected inline calendars |
| FR-014 | All-day style: hidden, event, bordered | Must | All-day row treatment matches selected style |
| FR-015 | Group similar events toggle | Should | Grouped or ungrouped behavior is consistent and testable |
| FR-016 | Ongoing events visibility toggle | Must | Ongoing date section appears only when enabled |
| FR-017 | Show reminders toggle | Must | Reminder rows included/excluded by setting |
| FR-018 | Reminder display mode: today only, today+overdue, upcoming | Must | Reminder filter logic aligns with mode definition |
| FR-019 | Mixed list toggle (events + reminders) | Should | Unified or split ordering applies predictably |
| FR-020 | Header visibility toggle | Must | Header can be fully disabled |

## 6.3 Standard Widget Rendering and Interaction

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-030 | Support small/medium/large/extra-large widget families | Must | No clipping or critical overlap across families |
| FR-031 | Header date opens destination for reference date | Must | Tap opens correct target based on navigation preference |
| FR-032 | Header includes create-item action | Should | Create action launches valid route |
| FR-033 | Birthdays complication shows today birthday or next birthday state | Should | Correct branch shown given available birthday data |
| FR-034 | Summary complication shows count of today timed events | Should | Count excludes all-day and non-event item types |
| FR-035 | Main content grouped by relevant dates in chronological order | Must | Date sections render sorted with stable identity |
| FR-036 | Inline all-day summary adapts by family (count/title variants) | Should | Small and non-small variants conform to design |
| FR-037 | Event rows deep-link correctly | Must | Tapping event opens expected destination |
| FR-038 | Reminder rows complete reminders via intent | Must | Intent marks reminder complete and refreshes timelines |
| FR-039 | Time metadata shown as start time or remaining time | Should | Ongoing and upcoming time display rules are consistent |
| FR-040 | Provide explicit empty-state rendering | Must | Widget never appears as unexplained blank surface |

## 6.4 Data Rules and Filtering

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-050 | Bound event query horizon and count for performance | Must | Query windows and limits are enforced |
| FR-051 | Exclude completed reminders | Must | Completed reminders are absent in all modes |
| FR-052 | Define policy for reminders without due dates | Must | Inclusion/exclusion rule documented and tested |
| FR-053 | Birthday query window configurable with safe default | Should | Default window and override capability exist |
| FR-054 | Define deterministic mapping for ongoing/multi-day items | Must | Ongoing bucket logic remains stable |
| FR-055 | Deduplicate merged content across sources | Must | Duplicate rows are not visible |

## 6.5 Live Activity and Dynamic Island

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-060 | Support ongoing-event Live Activity | Must | Eligible events start activity successfully |
| FR-061 | Lock Screen Live Activity includes title, timing, progress | Must | Data updates over lifecycle |
| FR-062 | Dynamic Island supports expanded, compact, minimal layouts | Must | Layouts render correctly across states |
| FR-063 | Do not start Live Activity for all-day events | Must | Eligibility filter enforces exclusion |
| FR-064 | End activity automatically at event end | Must | Activity closes without manual intervention |
| FR-065 | Activity tap deep-links to event destination | Should | Tap opens event detail context |

## 6.6 Settings, Preview, and Support

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-070 | Provide in-app widget settings section | Must | Settings page accessible via app navigation |
| FR-071 | Support destination preference (Open in App vs System Apps) | Must | Toggle deterministically switches routing behavior |
| FR-072 | Manual widget refresh control | Should | Trigger requests timeline reload |
| FR-073 | Multi-family widget preview simulator | Should | User can inspect all supported families |
| FR-074 | Support link to official widget setup guidance | Could | User can open external support tutorial safely |

## 6.7 Deep Link and Navigation Contract

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| FR-080 | Define canonical URL grammar and versioning | Must | Routing spec exists and is implemented |
| FR-081 | Accept and normalize legacy URL formats | Should | Backward compatibility tests pass |
| FR-082 | Invalid links must fail closed | Must | Invalid URLs do not crash or misroute |
| FR-083 | Routes supported: event, reminder, day, create, settings, permissions | Must | Route matrix fully covered by tests |

## 7. Non-Functional Requirements

| ID | Requirement | Target |
|---|---|---|
| NFR-001 | Timeline generation latency | p95 < 1.5s |
| NFR-002 | Widget memory budget compliance | Pass on all supported families |
| NFR-003 | Battery efficiency for periodic updates | No unnecessary high-frequency refresh outside approved views |
| NFR-004 | Main-thread contention | No long-running EventKit work on main actor hot paths |
| NFR-005 | Crash-free rate | >= 99.9% monthly |
| NFR-006 | Refresh reliability | Widget state updates on major triggers |
| NFR-007 | Accessibility labels and hints | 100% interactive controls labeled |
| NFR-008 | Dynamic Type resilience | No critical truncation through accessibility sizes |
| NFR-009 | Contrast and touch targets | WCAG AA and >= 44pt targets |
| NFR-010 | Localization completeness | All user-facing strings localizable |
| NFR-011 | Privacy posture | Local-first processing, no unauthorized export |
| NFR-012 | Deep-link and entitlement security | Strict validation and least privilege |
| NFR-013 | Observability quality | Structured logs and actionable diagnostics |
| NFR-014 | Test coverage baseline | Critical path unit, integration, and UI coverage |

## 8. Security and Privacy Requirements

| ID | Requirement | Priority |
|---|---|---|
| SEC-001 | Apply least-privilege entitlements | Must |
| SEC-002 | No hardcoded secrets | Must |
| SEC-003 | Validate deep links with strict allowlist rules | Must |
| SEC-004 | Reject invalid deep links safely | Must |
| SEC-005 | Exclude PII from telemetry and logs | Must |
| SEC-006 | Privacy copy must match runtime behavior | Must |
| SEC-007 | Use explicit app-group storage for cross-target settings sync | Must |

## 9. Edge Case and Exception Requirements

| ID | Scenario | Required Behavior |
|---|---|---|
| EX-001 | Calendar access denied | Event surfaces degrade safely with clear messaging |
| EX-002 | Reminders access denied | Reminder actions unavailable without errors |
| EX-003 | Contacts access denied | Birthday fallback without contact enrichment |
| EX-004 | No selected calendars | Apply documented fallback policy consistently |
| EX-005 | Duplicate calendar display names | Identity must rely on stable calendar IDs |
| EX-006 | All-day overlap across normal and inline sources | No confusing duplication in UI |
| EX-007 | Reminders without due date | Respect documented policy from FR-052 |
| EX-008 | DST/timezone shifts | Date/time labels remain correct |
| EX-009 | Live Activities disabled | Feature degrades without crash/noise |
| EX-010 | Post-action stale UI | Forced refresh path ensures consistency |

## 10. Canonical Deep Link Specification

Canonical scheme: `camical://`

| Use Case | Canonical Format |
|---|---|
| Event detail | `camical://event/{eventID}` |
| Reminder detail | `camical://reminder/{reminderID}` |
| Day focus | `camical://day?time={timeIntervalSinceReferenceDate}` |
| Create event | `camical://create/event` |
| Create reminder | `camical://create/reminder` |
| Settings | `camical://settings` |
| Permissions | `camical://permissions` |

Legacy support: non-hierarchical forms such as `camical:event?id=...` and `camical:day?...` must be parsed and normalized into canonical route models.

## 11. Architecture Requirements

1. Use actor-isolated service boundaries for shared mutable state.
2. Use dedicated widget data service distinct from full app contexts.
3. Use immutable widget display models for rendering.
4. Keep AppIntent mapping deterministic and versioned.
5. Centralize deep-link generation and parsing in one route package.
6. Centralize widget refresh orchestration with explicit triggers.
7. Use app-group-backed shared storage abstraction for extension/app parity.
8. Gate iOS 26+ APIs with compatibility fallbacks.

## 12. Testing Requirements and Strategy

### 12.1 Mandatory Test Suites

1. Unit: filtering, grouping, date bucketing, deduplication, routing.
2. Intent: parameter mapping and reminder completion intent.
3. Integration: permissions + EventKit state transitions.
4. UI/Snapshot: all families, all complication modes, empty/error states, Dynamic Type.
5. Live Activity: lifecycle start/update/end and eligibility.
6. Accessibility: VoiceOver labels, hints, focus, and large text compatibility.

### 12.2 Release Gates

1. No open P0/P1 defects.
2. All mandatory test suites passing in CI.
3. NFR thresholds met on representative devices.
4. Security and privacy sign-off completed.
5. Accessibility review approved.

## 13. Requirements Assessment

## 13.1 Completeness Assessment

| Dimension | Status | Assessment |
|---|---|---|
| Functional coverage | Complete | End-user flows are fully specified |
| Reliability/performance | Complete | Budgets and reliability thresholds defined |
| Security/privacy | Complete | Controls and compliance checks are explicit |
| Accessibility | Complete | Operability and visual criteria are measurable |
| Architecture | Complete | Greenfield module contracts are clear |
| Testability | Complete | Requirement-level traceability established |

## 13.2 Risk Register

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| EventKit freshness/latency variability | High | Medium | Bounded queries, cache policy, stale fallback state |
| Deep-link grammar drift between builder and parser | High | Medium | Canonical spec + contract tests |
| App/extension setting desynchronization | High | Medium | App-group storage abstraction + integration tests |
| Excessive refresh frequency affects battery | Medium | Medium | Trigger policy and periodic cadence constraints |
| Dense widget content accessibility regressions | Medium | Medium | Dedicated accessibility CI checks |
| Empty-state ambiguity reduces trust | Medium | High | Explicit empty-state requirement (FR-040) |

## 13.3 Dependencies

1. EventKit permissions and store responsiveness.
2. Contacts framework for birthday enrichment.
3. WidgetKit/AppIntents/ActivityKit platform behavior.
4. CI infrastructure capable of UI and integration testing on iOS simulators/devices.

## 13.4 Go/No-Go Recommendation

Go for implementation kickoff after these preconditions are complete:

1. Route grammar approved and frozen.
2. FR-052 reminder due-date policy approved.
3. Empty-state UX copy approved by Product and Design.
4. Test harness skeleton created with traceability IDs.

## 14. Traceability Model

Format:

1. Requirement IDs: `FR-*`, `NFR-*`, `SEC-*`, `EX-*`
2. Test Case IDs:
   - Functional: `TC-FR-*`
   - Non-functional: `TC-NFR-*`
   - Security: `TC-SEC-*`
   - Exception: `TC-EX-*`
3. Owner roles:
   - PM: Product Manager
   - iOS: iOS Engineer
   - WGT: Widget Engineer
   - QA: QA Automation Engineer
   - SEC: Security Engineer
   - A11Y: Accessibility Engineer
   - REL: Release Engineer

## 15. Requirement-to-Test-to-Owner Matrix

| Requirement ID | Test Case ID(s) | Primary Owner |
|---|---|---|
| FR-001 | TC-FR-001 | iOS |
| FR-002 | TC-FR-002 | iOS |
| FR-003 | TC-FR-003 | iOS |
| FR-004 | TC-FR-004 | WGT |
| FR-005 | TC-FR-005 | PM |
| FR-010 | TC-FR-010 | WGT |
| FR-011 | TC-FR-011 | WGT |
| FR-012 | TC-FR-012 | WGT |
| FR-013 | TC-FR-013 | WGT |
| FR-014 | TC-FR-014 | WGT |
| FR-015 | TC-FR-015 | WGT |
| FR-016 | TC-FR-016 | WGT |
| FR-017 | TC-FR-017 | WGT |
| FR-018 | TC-FR-018 | WGT |
| FR-019 | TC-FR-019 | WGT |
| FR-020 | TC-FR-020 | WGT |
| FR-030 | TC-FR-030 | WGT |
| FR-031 | TC-FR-031 | WGT |
| FR-032 | TC-FR-032 | WGT |
| FR-033 | TC-FR-033 | WGT |
| FR-034 | TC-FR-034 | WGT |
| FR-035 | TC-FR-035 | WGT |
| FR-036 | TC-FR-036 | WGT |
| FR-037 | TC-FR-037 | WGT |
| FR-038 | TC-FR-038, TC-FR-004 | WGT |
| FR-039 | TC-FR-039 | WGT |
| FR-040 | TC-FR-040 | PM |
| FR-050 | TC-FR-050, TC-NFR-001 | iOS |
| FR-051 | TC-FR-051 | iOS |
| FR-052 | TC-FR-052, TC-EX-007 | PM |
| FR-053 | TC-FR-053 | iOS |
| FR-054 | TC-FR-054, TC-EX-008 | WGT |
| FR-055 | TC-FR-055 | WGT |
| FR-060 | TC-FR-060 | iOS |
| FR-061 | TC-FR-061 | WGT |
| FR-062 | TC-FR-062 | WGT |
| FR-063 | TC-FR-063 | iOS |
| FR-064 | TC-FR-064 | iOS |
| FR-065 | TC-FR-065 | WGT |
| FR-070 | TC-FR-070 | iOS |
| FR-071 | TC-FR-071, TC-SEC-007 | iOS |
| FR-072 | TC-FR-072 | WGT |
| FR-073 | TC-FR-073 | WGT |
| FR-074 | TC-FR-074 | PM |
| FR-080 | TC-FR-080, TC-SEC-003 | iOS |
| FR-081 | TC-FR-081 | iOS |
| FR-082 | TC-FR-082, TC-SEC-004 | SEC |
| FR-083 | TC-FR-083 | iOS |
| NFR-001 | TC-NFR-001 | QA |
| NFR-002 | TC-NFR-002 | QA |
| NFR-003 | TC-NFR-003 | REL |
| NFR-004 | TC-NFR-004 | iOS |
| NFR-005 | TC-NFR-005 | REL |
| NFR-006 | TC-NFR-006 | QA |
| NFR-007 | TC-NFR-007 | A11Y |
| NFR-008 | TC-NFR-008 | A11Y |
| NFR-009 | TC-NFR-009 | A11Y |
| NFR-010 | TC-NFR-010 | PM |
| NFR-011 | TC-NFR-011 | SEC |
| NFR-012 | TC-NFR-012 | SEC |
| NFR-013 | TC-NFR-013 | REL |
| NFR-014 | TC-NFR-014 | QA |
| SEC-001 | TC-SEC-001 | SEC |
| SEC-002 | TC-SEC-002 | SEC |
| SEC-003 | TC-SEC-003, TC-FR-080 | SEC |
| SEC-004 | TC-SEC-004, TC-FR-082 | SEC |
| SEC-005 | TC-SEC-005 | SEC |
| SEC-006 | TC-SEC-006 | PM |
| SEC-007 | TC-SEC-007, TC-FR-071 | iOS |
| EX-001 | TC-EX-001, TC-FR-001 | QA |
| EX-002 | TC-EX-002, TC-FR-002 | QA |
| EX-003 | TC-EX-003, TC-FR-003 | QA |
| EX-004 | TC-EX-004 | QA |
| EX-005 | TC-EX-005 | QA |
| EX-006 | TC-EX-006 | QA |
| EX-007 | TC-EX-007, TC-FR-052 | QA |
| EX-008 | TC-EX-008, TC-FR-054 | QA |
| EX-009 | TC-EX-009 | QA |
| EX-010 | TC-EX-010, TC-FR-004 | QA |

## 16. Test Case Catalog (Minimal Definitions)

| Test Case ID | Purpose |
|---|---|
| TC-FR-001 | Verify calendar permission denied/authorized behavior and UI gating |
| TC-FR-002 | Verify reminders permission denied/authorized behavior and action gating |
| TC-FR-003 | Verify contacts permission impact on birthday enrichment |
| TC-FR-004 | Verify refresh workflow after permission/action state changes |
| TC-FR-005 | Verify tutorial entry point discoverability |
| TC-FR-010 | Verify AppIntent configuration registration and availability |
| TC-FR-011 | Verify each complication mode renders expected UI |
| TC-FR-012 | Verify event filtering by selected calendars |
| TC-FR-013 | Verify inline all-day filtering by selected inline calendars |
| TC-FR-014 | Verify all-day style variants |
| TC-FR-015 | Verify grouped and ungrouped event row behavior |
| TC-FR-016 | Verify ongoing events section toggle |
| TC-FR-017 | Verify reminders visibility toggle |
| TC-FR-018 | Verify reminder display mode filtering logic |
| TC-FR-019 | Verify unified and split ordering behavior |
| TC-FR-020 | Verify header visibility toggle |
| TC-FR-030 | Verify rendering for all supported widget families |
| TC-FR-031 | Verify date tap opens correct destination |
| TC-FR-032 | Verify create action route |
| TC-FR-033 | Verify birthdays complication branch behavior |
| TC-FR-034 | Verify summary complication counting logic |
| TC-FR-035 | Verify section sorting and stable identity |
| TC-FR-036 | Verify family-adaptive inline all-day summary |
| TC-FR-037 | Verify event tap deep-link behavior |
| TC-FR-038 | Verify reminder completion intent execution |
| TC-FR-039 | Verify time display rules (upcoming vs ongoing) |
| TC-FR-040 | Verify explicit empty-state UI |
| TC-FR-050 | Verify bounded event fetch horizon and count |
| TC-FR-051 | Verify completed reminders are excluded |
| TC-FR-052 | Verify due-date policy behavior |
| TC-FR-053 | Verify birthday window configuration behavior |
| TC-FR-054 | Verify ongoing/multi-day bucketing logic |
| TC-FR-055 | Verify deduplication after merge |
| TC-FR-060 | Verify Live Activity start for eligible ongoing events |
| TC-FR-061 | Verify lock-screen content correctness over time |
| TC-FR-062 | Verify Dynamic Island variants |
| TC-FR-063 | Verify exclusion of all-day events from Live Activity |
| TC-FR-064 | Verify auto-end behavior at end time |
| TC-FR-065 | Verify Live Activity tap destination |
| TC-FR-070 | Verify in-app widget settings navigation |
| TC-FR-071 | Verify destination preference behavior consistency |
| TC-FR-072 | Verify manual widget refresh action |
| TC-FR-073 | Verify preview panel coverage for all families |
| TC-FR-074 | Verify support link behavior and validity |
| TC-FR-080 | Verify canonical URL generation/parsing contract |
| TC-FR-081 | Verify legacy URL compatibility |
| TC-FR-082 | Verify fail-closed behavior for invalid URLs |
| TC-FR-083 | Verify complete route matrix |
| TC-NFR-001 | Measure timeline generation latency p95 |
| TC-NFR-002 | Measure widget memory usage under representative data load |
| TC-NFR-003 | Measure battery impact of update schedules |
| TC-NFR-004 | Detect main-thread blocking regressions |
| TC-NFR-005 | Monitor crash-free rate over release window |
| TC-NFR-006 | Validate refresh reliability across triggers |
| TC-NFR-007 | Audit accessibility labeling |
| TC-NFR-008 | Validate Dynamic Type behavior at accessibility sizes |
| TC-NFR-009 | Validate contrast ratios and hit areas |
| TC-NFR-010 | Validate localization coverage |
| TC-NFR-011 | Validate privacy posture and data flow constraints |
| TC-NFR-012 | Validate deep-link security and entitlement posture |
| TC-NFR-013 | Validate observability and diagnostic signal quality |
| TC-NFR-014 | Validate minimum automated test coverage thresholds |
| TC-SEC-001 | Audit entitlement least-privilege conformance |
| TC-SEC-002 | Scan for hardcoded secret material |
| TC-SEC-003 | Validate strict deep-link allowlist parsing |
| TC-SEC-004 | Validate invalid-link rejection paths |
| TC-SEC-005 | Audit logs for PII and sensitive content leakage |
| TC-SEC-006 | Validate privacy copy against implemented behavior |
| TC-SEC-007 | Validate app-group shared storage behavior across app/extension |
| TC-EX-001 | Calendar denied edge case validation |
| TC-EX-002 | Reminders denied edge case validation |
| TC-EX-003 | Contacts denied edge case validation |
| TC-EX-004 | No selected calendars fallback validation |
| TC-EX-005 | Duplicate display-name calendar identity validation |
| TC-EX-006 | Overlap deduplication validation for all-day sources |
| TC-EX-007 | No-due-date reminder edge behavior validation |
| TC-EX-008 | DST/timezone transition validation |
| TC-EX-009 | Live Activities disabled behavior validation |
| TC-EX-010 | Stale post-action content recovery validation |

## 17. Milestone Plan (Implementation Guidance)

1. Milestone A: Architecture and contracts
   - Deep-link spec, settings abstraction, data service contracts, test harness IDs.
2. Milestone B: Standard widget MVP
   - Core rendering, AppIntent config, date/event/reminder listing, empty states.
3. Milestone C: Interactions and settings
   - Reminder completion intent, destination preference, manual refresh, preview.
4. Milestone D: Live Activity
   - Ongoing event lifecycle and Dynamic Island surfaces.
5. Milestone E: Hardening
   - Accessibility, performance profiling, security validation, launch criteria.

## 18. Change Management

Any change that impacts requirement IDs, deep-link grammar, or NFR targets must:

1. Update this RFC version.
2. Update traceability matrix rows.
3. Add or update matching test case IDs.
4. Receive sign-off from Product, Engineering, QA, and Security.

