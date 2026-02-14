# RFC-002: Cami UI/UX Design Requirements and Assessment

- Status: Proposed
- Version: 1.0.0
- Last Updated: 2026-02-14
- Scope: Greenfield UI/UX requirements for a widgets-first iOS calendar app
- Companion Document: `docs/WidgetProductRequirements.md`
- Owners:
  - Product Design Lead
  - iOS Design Engineer
  - Accessibility Lead
  - Product Manager
  - QA Lead

## 1. Summary

This RFC defines the UI/UX design system, interaction model, and quality requirements for a widgets-first calendar app. It translates Dieter Rams principles into concrete design constraints and measurable acceptance criteria.

The goal is to ensure the product ships with:

1. Clear, low-friction daily workflows
2. Calm and unobtrusive visual hierarchy
3. Honest and trustworthy permission/data UX
4. High accessibility and localization readiness
5. Consistent quality across app, widget, and Live Activity surfaces

## 2. Design Vision

### 2.1 Core UX Promise

Users should be able to:

1. Understand their day within 3 seconds
2. Take an action within 1 tap from key surfaces
3. Recover from confusion or failure states without dead ends

### 2.2 UX Pillars

1. Glanceability first
2. Action without friction
3. Clarity over novelty
4. Calm hierarchy and visual restraint
5. Trust through transparent behavior

## 3. Dieter Rams Principle Matrix (Infused Requirements)

| Principle | Design Translation | Enforcement |
|---|---|---|
| RAMS-1 Good design is innovative | Use platform-native capabilities to reduce interaction cost (widgets, Live Activities, adaptive transitions), not novelty for novelty | Feature must reduce taps/time-to-task versus baseline |
| RAMS-2 Good design makes a product useful | Every primary screen has a task-oriented outcome (view day, filter, complete reminder, configure widget) | No primary screen without defined user job |
| RAMS-3 Good design is aesthetic | Establish coherent typography, spacing rhythm, and chroma hierarchy | Visual consistency review and snapshot checks |
| RAMS-4 Good design makes a product understandable | Strong information architecture, clear labels, predictable actions | Heuristic review: no ambiguous primary action labels |
| RAMS-5 Good design is unobtrusive | Content must dominate; chrome and decoration are secondary | Decorative elements must not outrank content contrast/weight |
| RAMS-6 Good design is honest | Do not imply data freshness/capability that is not true; expose permission limitations clearly | Honest state labels for stale/empty/denied conditions |
| RAMS-7 Good design is long-lasting | Avoid trend-driven visual gimmicks that age quickly | Tokenized system with controlled evolution |
| RAMS-8 Good design is thorough down to the last detail | Handle all empty/error/loading/restricted states | No critical flow missing one of these states |
| RAMS-9 Good design is environmentally friendly | Minimize unnecessary rendering work, animations, and refresh churn | Battery/perf budget and motion throttling policies |
| RAMS-10 Good design is as little design as possible | Remove non-essential surfaces and controls | Subtraction test required in design review |

## 4. UX Scope

## 4.1 In Scope

1. First-run onboarding and permission journeys
2. Main day timeline and daily navigation
3. Event/reminder detail interactions
4. Calendar filtering and settings
5. Widget settings and preview UX
6. Knowledge base and support UX
7. Empty/loading/error state design
8. Visual language and motion system
9. Accessibility and localization design standards

## 4.2 Out of Scope (v1)

1. watchOS-specific UI patterns
2. macOS-specific layout system
3. Brand redesign exploration beyond functional styling
4. Experimental 3D/AR interaction patterns

## 5. Information Architecture Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| IAR-001 | Primary app IA must center around “Today” and adjacent days | Must | Root view defaults to current day and supports day paging |
| IAR-002 | Settings IA must group by intent (General, Permissions, Widgets, Advanced) | Must | Users can find target setting in <= 2 taps |
| IAR-003 | Widget settings must be distinct from general app preferences | Must | Dedicated Widget Settings screen exists |
| IAR-004 | Deep links must resolve to deterministic destinations | Must | Invalid routes fail with user-safe fallback |
| IAR-005 | Navigation transitions must communicate hierarchy (push/sheet/full screen semantics) | Should | Transition choice aligns with information depth |
| IAR-006 | Modal stacks must support nested drill-down without losing context | Should | Modal navigation preserves breadcrumb intent |

## 6. Interaction Design Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| UXR-001 | Day navigation must be horizontal, fluid, and stateful | Must | Users can swipe days without context loss |
| UXR-002 | Header behavior must adapt to scroll while retaining legibility | Should | Title/actions remain readable and tappable |
| UXR-003 | Summary controls must toggle event/reminder visibility with immediate feedback | Must | Toggle effect reflected within same frame cycle |
| UXR-004 | Calendar item cards must support quick expand/collapse details | Should | Expanded details animate and remain discoverable |
| UXR-005 | Permission cards must communicate status, action, and consequence clearly | Must | Users can infer next step without external help |
| UXR-006 | Widget preference controls must be understandable for non-technical users | Must | Preference labels avoid implementation jargon |
| UXR-007 | “Open in App vs System” behavior must be explicit in UI copy | Must | Copy states destination behavior truthfully |
| UXR-008 | Interactive controls must provide tactile or visual confirmation | Should | Press, selection, and completion feedback is perceivable |
| UXR-009 | Loading placeholders must indicate temporary state, not fake data certainty | Must | Shimmer/skeleton usage is semantically appropriate |
| UXR-010 | Empty states must provide contextual guidance, not generic dead-end text | Must | Every empty state includes reason + recommended next action |

## 7. Visual Design System Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| VIS-001 | Use semantic colors rather than hardcoded palette literals for primary UI | Must | Core surfaces use tokenized semantic colors |
| VIS-002 | Define spacing/radius/stroke tokens for all reusable components | Must | No untracked magic numbers in shared components |
| VIS-003 | Typography scale must preserve hierarchy and readability | Must | Headline, body, caption usage follows documented scale |
| VIS-004 | Support light and dark mode parity | Must | No critical contrast or visual loss in either mode |
| VIS-005 | Calendar color accents must aid recognition without overpowering text | Should | Accent usage is bounded to badges, highlights, and focus cues |
| VIS-006 | Glass/blur effects must remain subtle and functional | Should | Effects must not reduce text contrast below acceptable limits |
| VIS-007 | Primary actions must be visually distinct from secondary and destructive actions | Must | Action classes are unambiguous in button styles |
| VIS-008 | Component borders and backgrounds must reinforce grouping, not visual noise | Should | Section and card boundaries improve scanability |
| VIS-009 | List and card layouts must maintain consistent vertical rhythm | Must | Spacing deltas remain within tokenized range |
| VIS-010 | Widget previews in app must visually match system placement expectations | Should | Preview corner radius, frame, and contrast are realistic |

## 8. Motion and Feedback Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| MOT-001 | Motion must clarify state change, not decorate | Must | Each animation maps to a user-perceivable state transition |
| MOT-002 | Staggered and spring animations must stay within comfort thresholds | Should | Duration and damping avoid jitter and fatigue |
| MOT-003 | Scroll-linked effects must not impair readability | Must | Blur/scale effects preserve content legibility |
| MOT-004 | Respect Reduce Motion accessibility setting | Must | Reduced-motion mode disables or simplifies non-essential animations |
| MOT-005 | Haptic feedback must be purposeful and sparse | Should | Haptics used for discrete success/selection moments only |
| MOT-006 | Long-running periodic animations must be budgeted for power | Must | Background/perpetual animations can be paused or throttled |

## 9. Content and Microcopy Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| CNT-001 | Labels must be task-first and plain-language | Must | Users can parse action intent at first glance |
| CNT-002 | Permission copy must include why + what happens if denied | Must | Each permission surface explains value and fallback |
| CNT-003 | Error copy must be specific and recovery-oriented | Must | Message includes actionable next step |
| CNT-004 | Empty-state copy must be contextual and non-alarming | Must | Tone remains neutral and useful |
| CNT-005 | Widget-related copy must clarify destination behavior | Must | “Open in App” semantics are explicit |
| CNT-006 | Strings must be localization-safe (no brittle concatenation) | Must | Localizable with pluralization and grammar support |

## 10. Accessibility Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| A11Y-001 | All interactive controls must expose labels and hints where needed | Must | VoiceOver can identify purpose and action |
| A11Y-002 | Focus order must follow visual and task hierarchy | Must | Swipe navigation is logical and predictable |
| A11Y-003 | Dynamic Type must avoid critical truncation and overlap | Must | Usable through accessibility text sizes |
| A11Y-004 | Touch targets must be >= 44x44pt | Must | All tappable controls satisfy minimum target size |
| A11Y-005 | Color contrast must meet WCAG AA baseline | Must | Body text >= 4.5:1, large text >= 3:1 |
| A11Y-006 | Status changes (completion/toggle state) must be announced | Should | Assistive tech receives meaningful updates |
| A11Y-007 | Icon-only actions must include semantic accessibility labels | Must | No unlabeled icon control in production surfaces |
| A11Y-008 | Motion-heavy surfaces must provide reduced-motion alternatives | Must | Equivalent information available without motion dependency |

## 11. Trust, Honesty, and Privacy UX Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| TRU-001 | Data freshness must be represented truthfully | Must | No implication of real-time sync when stale |
| TRU-002 | Permission restrictions must be visible, not hidden | Must | Restricted/denied states clearly indicated |
| TRU-003 | Completion actions must visibly confirm success/failure | Must | User can tell whether action completed |
| TRU-004 | External links (privacy/tutorial) must be clearly marked as external | Should | User understands app context switch |
| TRU-005 | Widget preview must be clearly identified as preview simulation | Should | Distinct from live widget state representation |

## 12. Performance and Responsiveness UX Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|---|---|---|---|
| PRF-001 | Main timeline interactions must remain smooth on representative devices | Must | Scrolling and transitions feel stable at target frame rates |
| PRF-002 | Initial content and placeholders must avoid blank white/black flashes | Must | First meaningful paint includes stable scaffold |
| PRF-003 | Expanding details should not block gestures | Should | Interaction remains responsive during animation |
| PRF-004 | Heavy visual effects must degrade gracefully under load | Must | Fallback styling applied when performance dips |
| PRF-005 | View updates should be scoped to changed state only | Should | No visible unnecessary re-render jitter |

## 13. Screen-Level UX Contracts

## 13.1 Onboarding

1. Must sequence welcome -> permission education -> completion.
2. Must use progressive disclosure and avoid dumping all permissions at once.
3. Must support restricted and denied states with route to system settings.
4. Must block destructive dismissal only when required for app viability.

## 13.2 Main Day Experience

1. Must prioritize today context and nearby day navigation.
2. Must expose event/reminder visibility filters as persistent controls.
3. Must render list items with quick metadata, then optional deep details.
4. Must preserve context when navigating to details and back.

## 13.3 Settings and Widget Configuration

1. Must expose permissions, widget behavior, and support actions in one coherent settings area.
2. Must isolate advanced/debug toggles from standard user controls.
3. Must provide manual refresh and educational path for widget setup.

## 13.4 Details and Drill-Down

1. Must include loading and not-found states.
2. Must provide explicit close/done actions in sheet contexts.
3. Must keep metadata readable and grouped (title, date, notes, list, priority).

## 14. Rams Compliance Gate (Release Checklist)

All items below must be pass/fail checked before release:

1. RAMS-1: Each major interaction saves time or cognitive load.
2. RAMS-2: Every top-level screen maps to a user job.
3. RAMS-3: Visual hierarchy is coherent across light/dark and sizes.
4. RAMS-4: No ambiguous labels on primary actions.
5. RAMS-5: Decorative effects never outcompete content.
6. RAMS-6: No misleading freshness or capability representation.
7. RAMS-7: Tokenized system supports evolution without redesign churn.
8. RAMS-8: Empty/loading/error/restricted states complete.
9. RAMS-9: Motion and refresh policies respect power budgets.
10. RAMS-10: Subtraction review completed and documented.

## 15. UI/UX Requirements Assessment

## 15.1 Completeness Scorecard

| Dimension | Status | Assessment |
|---|---|---|
| Information architecture | Complete | Route hierarchy and modal patterns defined |
| Interaction design | Complete | Core tasks and state transitions specified |
| Visual system | Complete | Tokenization and hierarchy requirements defined |
| Accessibility | Complete | Standards and measurable criteria provided |
| Content design | Complete | Microcopy constraints and honesty rules defined |
| Motion and feedback | Complete | Purpose, comfort, and reduced-motion policies defined |
| Performance UX | Complete | Responsiveness and degradation behavior specified |
| Rams principle infusion | Complete | 10-principle mapping with enforceable gates |

## 15.2 Risk Register

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| Overuse of visual effects reduces clarity | High | Medium | VIS-006 and MOT-003 gate in design QA |
| Dense card interactions overwhelm users | Medium | Medium | UXR-004 and CNT-001 usability testing |
| Permission UX confusion decreases activation | High | Medium | UXR-005 and CNT-002 guided messaging |
| Accessibility regressions in animated surfaces | High | Medium | A11Y-003/A11Y-008 automated checks |
| Inconsistent copy across app/widget settings | Medium | High | CNT-005 terminology governance |
| Preview and real widget behavior divergence | Medium | Medium | TRU-005 review and periodic parity audits |

## 15.3 Go/No-Go Recommendation

Go for implementation when:

1. Design tokens and typography scale are finalized.
2. Canonical microcopy glossary is approved.
3. Accessibility QA scripts and snapshot baselines exist.
4. Rams compliance checklist is integrated into release review.

## 16. Traceability Model

Format:

1. Requirement IDs:
   - IA: `IAR-*`
   - Interaction: `UXR-*`
   - Visual: `VIS-*`
   - Motion: `MOT-*`
   - Content: `CNT-*`
   - Accessibility: `A11Y-*`
   - Trust: `TRU-*`
   - Performance UX: `PRF-*`
2. Validation IDs:
   - Heuristic inspection: `VAL-HI-*`
   - Usability testing: `VAL-UT-*`
   - Visual audit/snapshot: `VAL-VA-*`
   - Accessibility audit: `VAL-AX-*`
   - Performance UX checks: `VAL-PX-*`
   - Content review: `VAL-CR-*`
3. Owner roles:
   - DGN: Product Design Lead
   - IOS: iOS Design Engineer
   - PM: Product Manager
   - QA: QA Lead
   - A11Y: Accessibility Lead
   - REL: Release Manager

## 17. Requirement-to-Validation-to-Owner Matrix

| Requirement ID | Validation ID(s) | Primary Owner |
|---|---|---|
| IAR-001 | VAL-HI-001, VAL-UT-001 | DGN |
| IAR-002 | VAL-HI-002, VAL-UT-002 | DGN |
| IAR-003 | VAL-HI-003 | IOS |
| IAR-004 | VAL-HI-004, VAL-UT-003 | IOS |
| IAR-005 | VAL-HI-005 | DGN |
| IAR-006 | VAL-UT-004 | IOS |
| UXR-001 | VAL-UT-005, VAL-PX-001 | IOS |
| UXR-002 | VAL-VA-001, VAL-UT-006 | DGN |
| UXR-003 | VAL-UT-007 | IOS |
| UXR-004 | VAL-UT-008, VAL-VA-002 | IOS |
| UXR-005 | VAL-UT-009, VAL-CR-001 | PM |
| UXR-006 | VAL-UT-010, VAL-CR-002 | PM |
| UXR-007 | VAL-CR-003, VAL-HI-006 | PM |
| UXR-008 | VAL-UT-011, VAL-AX-001 | IOS |
| UXR-009 | VAL-HI-007, VAL-UT-012 | DGN |
| UXR-010 | VAL-CR-004, VAL-UT-013 | PM |
| VIS-001 | VAL-VA-003 | IOS |
| VIS-002 | VAL-VA-004 | IOS |
| VIS-003 | VAL-VA-005, VAL-AX-002 | DGN |
| VIS-004 | VAL-VA-006 | DGN |
| VIS-005 | VAL-VA-007 | DGN |
| VIS-006 | VAL-VA-008, VAL-AX-003 | DGN |
| VIS-007 | VAL-HI-008, VAL-UT-014 | PM |
| VIS-008 | VAL-VA-009 | DGN |
| VIS-009 | VAL-VA-010 | DGN |
| VIS-010 | VAL-VA-011 | IOS |
| MOT-001 | VAL-HI-009 | DGN |
| MOT-002 | VAL-UT-015, VAL-PX-002 | IOS |
| MOT-003 | VAL-VA-012, VAL-AX-004 | DGN |
| MOT-004 | VAL-AX-005 | A11Y |
| MOT-005 | VAL-UT-016 | IOS |
| MOT-006 | VAL-PX-003 | REL |
| CNT-001 | VAL-CR-005, VAL-UT-017 | PM |
| CNT-002 | VAL-CR-006, VAL-UT-018 | PM |
| CNT-003 | VAL-CR-007 | PM |
| CNT-004 | VAL-CR-008 | PM |
| CNT-005 | VAL-CR-009 | PM |
| CNT-006 | VAL-CR-010 | PM |
| A11Y-001 | VAL-AX-006 | A11Y |
| A11Y-002 | VAL-AX-007, VAL-UT-019 | A11Y |
| A11Y-003 | VAL-AX-008 | A11Y |
| A11Y-004 | VAL-AX-009 | A11Y |
| A11Y-005 | VAL-AX-010 | A11Y |
| A11Y-006 | VAL-AX-011 | A11Y |
| A11Y-007 | VAL-AX-012 | A11Y |
| A11Y-008 | VAL-AX-013 | A11Y |
| TRU-001 | VAL-HI-010, VAL-CR-011 | PM |
| TRU-002 | VAL-HI-011, VAL-UT-020 | PM |
| TRU-003 | VAL-UT-021 | IOS |
| TRU-004 | VAL-CR-012 | PM |
| TRU-005 | VAL-HI-012, VAL-UT-022 | DGN |
| PRF-001 | VAL-PX-004 | REL |
| PRF-002 | VAL-PX-005, VAL-VA-013 | IOS |
| PRF-003 | VAL-PX-006 | IOS |
| PRF-004 | VAL-PX-007 | REL |
| PRF-005 | VAL-PX-008 | IOS |

## 18. Validation Catalog (Minimal)

| Validation ID | Description |
|---|---|
| VAL-HI-001 | IA heuristic: today-first discoverability |
| VAL-HI-002 | IA heuristic: settings grouping clarity |
| VAL-HI-003 | IA heuristic: widget settings separation |
| VAL-HI-004 | IA heuristic: deterministic route resolution |
| VAL-HI-005 | IA heuristic: transition semantic consistency |
| VAL-HI-006 | Heuristic: destination behavior copy clarity |
| VAL-HI-007 | Heuristic: placeholder honesty |
| VAL-HI-008 | Heuristic: action hierarchy clarity |
| VAL-HI-009 | Heuristic: motion purpose mapping |
| VAL-HI-010 | Heuristic: freshness honesty |
| VAL-HI-011 | Heuristic: restricted state visibility |
| VAL-HI-012 | Heuristic: preview realism and framing |
| VAL-UT-001 | Usability: find and use day navigation quickly |
| VAL-UT-002 | Usability: locate settings target in <= 2 taps |
| VAL-UT-003 | Usability: deep-link target expectation matching |
| VAL-UT-004 | Usability: nested modal flow coherence |
| VAL-UT-005 | Usability: day paging comfort and confidence |
| VAL-UT-006 | Usability: scroll-responsive header legibility |
| VAL-UT-007 | Usability: visibility toggle comprehension |
| VAL-UT-008 | Usability: item expand/collapse discoverability |
| VAL-UT-009 | Usability: permission card next-step clarity |
| VAL-UT-010 | Usability: widget settings comprehension |
| VAL-UT-011 | Usability: action feedback perception |
| VAL-UT-012 | Usability: loading-state interpretation |
| VAL-UT-013 | Usability: empty-state recovery success |
| VAL-UT-014 | Usability: primary/secondary action confusion rate |
| VAL-UT-015 | Usability: animation comfort/no fatigue |
| VAL-UT-016 | Usability: haptic appropriateness |
| VAL-UT-017 | Usability: command label comprehension |
| VAL-UT-018 | Usability: permission copy understanding |
| VAL-UT-019 | Usability: focus order for assistive navigation |
| VAL-UT-020 | Usability: restricted-state comprehension |
| VAL-UT-021 | Usability: completion success confidence |
| VAL-UT-022 | Usability: preview vs live understanding |
| VAL-VA-001 | Visual audit: header typography and readability |
| VAL-VA-002 | Visual audit: expandable card states |
| VAL-VA-003 | Visual audit: semantic color token usage |
| VAL-VA-004 | Visual audit: spacing/radius token conformance |
| VAL-VA-005 | Visual audit: type hierarchy consistency |
| VAL-VA-006 | Visual audit: light/dark parity |
| VAL-VA-007 | Visual audit: accent dominance boundaries |
| VAL-VA-008 | Visual audit: blur/glass contrast impact |
| VAL-VA-009 | Visual audit: grouping and border clarity |
| VAL-VA-010 | Visual audit: vertical rhythm consistency |
| VAL-VA-011 | Visual audit: widget preview realism |
| VAL-VA-012 | Visual audit: motion readability balance |
| VAL-VA-013 | Visual audit: first meaningful paint stability |
| VAL-AX-001 | Accessibility audit: feedback perceivability |
| VAL-AX-002 | Accessibility audit: typographic readability |
| VAL-AX-003 | Accessibility audit: effect-induced contrast risks |
| VAL-AX-004 | Accessibility audit: scroll effect readability |
| VAL-AX-005 | Accessibility audit: Reduce Motion behavior |
| VAL-AX-006 | Accessibility audit: control labels and hints |
| VAL-AX-007 | Accessibility audit: focus traversal order |
| VAL-AX-008 | Accessibility audit: large text clipping |
| VAL-AX-009 | Accessibility audit: touch target sizing |
| VAL-AX-010 | Accessibility audit: contrast compliance |
| VAL-AX-011 | Accessibility audit: announcement of state changes |
| VAL-AX-012 | Accessibility audit: icon-only semantics |
| VAL-AX-013 | Accessibility audit: reduced-motion alternatives |
| VAL-PX-001 | Performance UX: day paging responsiveness |
| VAL-PX-002 | Performance UX: animation cost profile |
| VAL-PX-003 | Performance UX: long-running animation power cost |
| VAL-PX-004 | Performance UX: smoothness under representative load |
| VAL-PX-005 | Performance UX: no initial flash/jank |
| VAL-PX-006 | Performance UX: non-blocking detail expansion |
| VAL-PX-007 | Performance UX: graceful visual degradation |
| VAL-PX-008 | Performance UX: state update scoping |
| VAL-CR-001 | Content review: permission card voice and actionability |
| VAL-CR-002 | Content review: settings language simplicity |
| VAL-CR-003 | Content review: destination preference copy truthfulness |
| VAL-CR-004 | Content review: empty-state guidance usefulness |
| VAL-CR-005 | Content review: action labels plain-language score |
| VAL-CR-006 | Content review: why/denied messaging completeness |
| VAL-CR-007 | Content review: error recovery quality |
| VAL-CR-008 | Content review: empty-state tone and clarity |
| VAL-CR-009 | Content review: widget settings terminology consistency |
| VAL-CR-010 | Content review: localization readiness checks |
| VAL-CR-011 | Content review: data freshness honesty |
| VAL-CR-012 | Content review: external-link disclosure clarity |

## 19. Delivery Milestones (UX Track)

1. Milestone UX-A: Foundations
   - IA map, design tokens, typography system, copy glossary.
2. Milestone UX-B: Core Flows
   - Onboarding, main day flow, settings baseline, accessibility baseline.
3. Milestone UX-C: Widget UX Parity
   - Widget preview fidelity, widget-setting clarity, cross-surface terminology.
4. Milestone UX-D: Motion and Polish
   - Scroll-linked behaviors, micro-interactions, reduced-motion tuning.
5. Milestone UX-E: Validation and Release
   - Full Rams gate, usability sessions, accessibility audits, final sign-off.

## 20. Change Control

Any change to IA, Rams compliance gates, or accessibility requirements must:

1. Update this RFC version and date.
2. Update affected matrix rows in Section 17.
3. Add or update validation entries in Section 18.
4. Receive sign-off from Design, PM, Engineering, and Accessibility leads.

