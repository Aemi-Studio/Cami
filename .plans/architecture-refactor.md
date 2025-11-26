# Architecture Refactoring Plan

## Executive Summary

The current architecture has several critical issues:
1. **Broken calendar filtering** - UI not wired to state
2. **Fragmented state management** - AppState, SingleDayContext, DayViewModel all hold overlapping concerns
3. **No persistence** for user preferences (calendar selection, visibility toggles)
4. **Memory concerns** with 731-day pager preload
5. **Undefined navigation methods** causing potential runtime issues

This plan proposes a clean, testable architecture with clear ownership of state.

---

## Proposed Architecture

### Core Principles

1. **Single Source of Truth**: Each piece of state has exactly one owner
2. **Unidirectional Data Flow**: State flows down, actions flow up
3. **Separation of Concerns**: UI state vs. data state vs. persistence
4. **Actor Isolation**: Thread-safe state management
5. **Testability**: Dependencies injectable, state observable

### New Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CamiApp                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    AppCoordinator                           ││
│  │  (orchestrates state, handles app lifecycle)                ││
│  └─────────────────────────────────────────────────────────────┘│
│           │                    │                    │           │
│           ▼                    ▼                    ▼           │
│  ┌─────────────┐     ┌─────────────────┐    ┌──────────────┐   │
│  │ AppSettings │     │  CalendarStore  │    │  Navigation  │   │
│  │  (actor)    │     │    (actor)      │    │   Router     │   │
│  │             │     │                 │    │              │   │
│  │ • calendar  │     │ • events cache  │    │ • path stack │   │
│  │   selection │     │ • reminders     │    │ • modals     │   │
│  │ • view prefs│     │   cache         │    │ • deep links │   │
│  │ • completed │     │ • subscriptions │    │              │   │
│  │   onboarding│     │                 │    │              │   │
│  └─────────────┘     └─────────────────┘    └──────────────┘   │
│           │                    │                                │
│           ▼                    ▼                                │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                      DayStore                               ││
│  │  (observable, provides filtered data for current day)      ││
│  │                                                             ││
│  │  • selectedDate                                             ││
│  │  • filteredEvents (computed from CalendarStore + settings)  ││
│  │  • filteredReminders                                        ││
│  │  • visibilityToggles (events/reminders shown)               ││
│  └─────────────────────────────────────────────────────────────┘│
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                        Views                                ││
│  │  (read-only access to stores, send actions)                 ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Micro-Step Implementation Plan

### Phase 1: Foundation (New State Architecture)

#### Step 1.1: Create AppSettings Actor
**Goal**: Centralize all user preferences in a persistent, thread-safe store

**Files to create**:
- `Cami/Core/Settings/AppSettings.swift`

**What it holds**:
- `selectedCalendarIDs: Set<String>` - which calendars are enabled
- `showEvents: Bool` - visibility toggle
- `showReminders: Bool` - visibility toggle
- `hasCompletedOnboarding: Bool`
- `completedOnboardingSteps: Set<OnboardingStep>`

**Persistence**: UserDefaults via Codable

**Actions**:
```swift
actor AppSettings {
    func toggleCalendar(_ id: String) async
    func setCalendarEnabled(_ id: String, enabled: Bool) async
    func setShowEvents(_ show: Bool) async
    func setShowReminders(_ show: Bool) async
    func completeOnboardingStep(_ step: OnboardingStep) async
}
```

---

#### Step 1.2: Create CalendarStore Actor
**Goal**: Single source of truth for calendar data with efficient caching

**Files to create**:
- `Cami/Core/Store/CalendarStore.swift`

**What it holds**:
- `allCalendars: [EKCalendar]` - all available calendars
- `eventCache: [Date: [EKEvent]]` - cached events by day
- `reminderCache: [Date: [EKReminder]]` - cached reminders by day

**Responsibilities**:
- Subscribe to EventKit changes
- Invalidate cache on changes
- Provide filtered data based on AppSettings

**Actions**:
```swift
actor CalendarStore {
    func events(for date: Date, calendars: Set<String>) async -> [EKEvent]
    func reminders(for date: Date, calendars: Set<String>) async -> [EKReminder]
    func refresh() async
    func invalidateCache() async
}
```

---

#### Step 1.3: Create DayStore Observable
**Goal**: Provide reactive, filtered data for the current day view

**Files to create**:
- `Cami/Core/Store/DayStore.swift`

**What it holds**:
- `selectedDate: Date` (bindable)
- `events: [EKEvent]` (filtered, sorted)
- `reminders: [EKReminder]` (filtered, sorted)
- `isLoading: Bool`

**Computed properties**:
- `combinedItems: [CalendarDisplayItem]` - merged and sorted
- `isViewingToday: Bool`

**Actions**:
```swift
@Observable
@MainActor
final class DayStore {
    func selectDate(_ date: Date)
    func navigateToToday()
    func navigateByDays(_ offset: Int)
    func refresh() async
}
```

---

#### Step 1.4: Create NavigationRouter
**Goal**: Simplify navigation with clear, testable routing

**Files to create**:
- `Cami/Core/Navigation/NavigationRouter.swift`
- `Cami/Core/Navigation/Route.swift`

**Routes enum**:
```swift
enum Route: Hashable {
    case main
    case settings
    case calendarSelection(kind: CalendarItemKind)
    case eventDetail(id: String)
    case createItem(kind: CalendarItemKind)
    case onboarding
    case permissions
}
```

**Router**:
```swift
@Observable
@MainActor
final class NavigationRouter {
    var path: [Route] = []
    var sheet: Route?
    var fullScreenCover: Route?

    func push(_ route: Route)
    func pop()
    func popToRoot()
    func present(_ route: Route, style: PresentationStyle)
    func dismiss()
}
```

---

### Phase 2: Migration (Gradual Replacement)

#### Step 2.1: Wire AppSettings to CalendarToggleButton
**Goal**: Make calendar selection actually work

**Files to modify**:
- `Cami/UI/Calendar/CalendarToggleButton.swift`
- `Cami/UI/Calendar/CalendarSelectionView.swift`

**Changes**:
1. Replace `.constant(true)` with binding to AppSettings
2. Add toggle action that calls `appSettings.toggleCalendar(id)`
3. Read enabled state from AppSettings

---

#### Step 2.2: Connect CalendarStore to DayStore
**Goal**: Filtered data flows from CalendarStore through DayStore

**Files to modify**:
- `Cami/Core/Store/DayStore.swift`

**Changes**:
1. DayStore observes AppSettings for filter changes
2. DayStore fetches from CalendarStore with current filters
3. Automatic refresh when settings change

---

#### Step 2.3: Replace SingleDayContext with DayStore
**Goal**: Simplify day data management

**Files to modify**:
- `Cami/UI/SingleDayView.swift`
- `Cami/UI/_Refactored/Main/DayPagerView.swift`

**Changes**:
1. SingleDayView reads from DayStore instead of SingleDayContext
2. DayPagerView updates DayStore.selectedDate on scroll
3. Remove SingleDayContext (or deprecate)

---

#### Step 2.4: Replace DayViewModel with DayStore Visibility
**Goal**: Visibility toggles persist and are centralized

**Files to modify**:
- `Cami/UI/SingleDayView.swift`
- `Cami/UI/DaySummary.swift`

**Changes**:
1. Remove DayViewModel
2. Visibility toggles read/write AppSettings.showEvents/showReminders
3. DayStore filters based on visibility settings

---

#### Step 2.5: Migrate AppState to New Architecture
**Goal**: AppState becomes a thin coordinator

**Files to modify**:
- `Cami/UI/_Refactored/AppState/AppState.swift`

**Changes**:
1. Remove `selectedDate` (now in DayStore)
2. Remove `dayContextCache` (now in CalendarStore)
3. Remove `currentScrollOffset` (move to view-local state)
4. Keep only: `navigation`, `storage` references
5. Rename to `AppCoordinator` for clarity

---

### Phase 3: Optimization

#### Step 3.1: Optimize DayPagerView
**Goal**: Reduce memory usage, improve performance

**Files to modify**:
- `Cami/UI/_Refactored/Main/DayPagerView.swift`

**Changes**:
1. Reduce preload range from ±365 to ±30 days
2. Implement dynamic loading when approaching edges
3. Use `id` modifier for efficient view recycling
4. Move scroll offset tracking to view-local state

---

#### Step 3.2: Implement Smart Caching in CalendarStore
**Goal**: Only cache what's needed, invalidate intelligently

**Files to modify**:
- `Cami/Core/Store/CalendarStore.swift`

**Changes**:
1. LRU cache with max 60 days (±30 from today)
2. Prefetch adjacent days on scroll
3. Batch cache invalidation on EventKit changes
4. Background refresh with priority for visible day

---

#### Step 3.3: Add Loading States
**Goal**: Better UX during data fetching

**Files to modify**:
- `Cami/UI/SingleDayView.swift`
- `Cami/Core/Store/DayStore.swift`

**Changes**:
1. DayStore tracks loading state per date
2. SingleDayView shows skeleton/placeholder while loading
3. Smooth transitions between loading and loaded states

---

### Phase 4: Polish

#### Step 4.1: Implement Missing Navigation Flows
**Goal**: Fix undefined methods, complete onboarding

**Files to modify**:
- `Cami/Core/Navigation/NavigationRouter.swift`
- `Cami/UI/_Refactored/Onboarding/OnboardingView.swift`

**Changes**:
1. Implement onboarding flow in NavigationRouter
2. Add completion handler for onboarding
3. Automatic navigation to main on completion

---

#### Step 4.2: Add Error Handling
**Goal**: Graceful degradation when EventKit fails

**Files to create**:
- `Cami/Core/Error/CalendarError.swift`

**Files to modify**:
- `Cami/Core/Store/CalendarStore.swift`
- `Cami/UI/SingleDayView.swift`

**Changes**:
1. CalendarStore surfaces errors as published state
2. Views show appropriate error UI
3. Retry mechanisms for transient failures

---

#### Step 4.3: Clean Up Legacy Code
**Goal**: Remove deprecated code paths

**Files to delete**:
- `Cami/UI/SingleDayContext.swift` (replaced by DayStore)
- `Cami/UI/CalendarItemType.swift` (DayViewModel moved to DayStore)

**Files to simplify**:
- `Cami/UI/_Refactored/AppState/AppState.swift` → `AppCoordinator.swift`
- `Multiplatform/ModalSheetContext.swift` (consolidate with NavigationRouter)

---

## Implementation Order (Recommended)

```
Week 1: Foundation
├── Step 1.1: AppSettings actor
├── Step 1.2: CalendarStore actor
├── Step 1.3: DayStore observable
└── Step 1.4: NavigationRouter

Week 2: Migration
├── Step 2.1: Wire calendar toggles
├── Step 2.2: Connect stores
├── Step 2.3: Replace SingleDayContext
├── Step 2.4: Replace DayViewModel
└── Step 2.5: Migrate AppState

Week 3: Optimization
├── Step 3.1: Optimize pager
├── Step 3.2: Smart caching
└── Step 3.3: Loading states

Week 4: Polish
├── Step 4.1: Navigation flows
├── Step 4.2: Error handling
└── Step 4.3: Clean up
```

---

## File Structure After Refactor

```
Cami/
├── Core/
│   ├── Settings/
│   │   └── AppSettings.swift          # User preferences (actor)
│   ├── Store/
│   │   ├── CalendarStore.swift        # Calendar data (actor)
│   │   └── DayStore.swift             # Current day state (observable)
│   ├── Navigation/
│   │   ├── NavigationRouter.swift     # Navigation state
│   │   └── Route.swift                # Route definitions
│   ├── Error/
│   │   └── CalendarError.swift        # Error types
│   └── Coordinator/
│       └── AppCoordinator.swift       # App lifecycle (replaces AppState)
│
├── UI/
│   ├── Root/
│   │   ├── RootView.swift             # Entry point (replaces AppRootView)
│   │   └── MainContentView.swift      # Main layout
│   ├── Day/
│   │   ├── DayPagerView.swift         # Horizontal pager
│   │   ├── DayView.swift              # Single day (replaces SingleDayView)
│   │   └── DaySummary.swift           # Event/reminder counts
│   ├── Calendar/
│   │   ├── CalendarSelectionView.swift
│   │   └── CalendarToggleRow.swift    # (replaces CalendarToggleButton)
│   ├── Item/
│   │   ├── CalendarItemRow.swift      # List row
│   │   └── CalendarItemDetail.swift   # Expanded view
│   ├── Header/
│   │   └── AppHeader.swift            # Top bar
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Onboarding/
│       └── OnboardingFlow.swift
│
├── CamiApp.swift                       # App entry, DI setup
│
Multiplatform/
├── DataContext/                        # Keep as EventKit abstraction
├── Services/                           # Keep service layer
└── Filters/                            # Keep filter definitions
```

---

## Testing Strategy

### Unit Tests
- `AppSettingsTests`: Persistence, toggle logic
- `CalendarStoreTests`: Caching, filtering, invalidation
- `DayStoreTests`: Date navigation, combined items sorting
- `NavigationRouterTests`: Route transitions, modal lifecycle

### Integration Tests
- Settings → CalendarStore → DayStore data flow
- EventKit changes → cache invalidation → UI update
- Deep link → navigation → correct view

### UI Tests
- Calendar toggle → events filter correctly
- Day navigation → correct data displayed
- Pull to refresh → data updates

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing functionality | Parallel implementation, feature flags |
| Data loss during migration | Migrate persistence format carefully |
| Performance regression | Benchmark before/after each phase |
| Incomplete migration | Each step is independently shippable |

---

## Success Metrics

1. **Calendar filtering works**: User can toggle calendars on/off
2. **Preferences persist**: Restart app → same selection
3. **Memory reduced**: < 100MB for day pager (from current ~300MB)
4. **No undefined methods**: All navigation flows complete
5. **Testable**: > 80% coverage on Core layer
