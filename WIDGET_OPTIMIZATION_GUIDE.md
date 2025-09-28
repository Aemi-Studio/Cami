# Widget Memory Optimization Guide

## Overview

This guide documents the memory optimization improvements implemented for the Cami widget to handle iOS's 30MB memory limit more efficiently.

## Architecture Changes

### 1. Service Layer Refactoring

**Before**: Monolithic `DataContext` handling all operations
**After**: Focused services with specific responsibilities

```swift
// New services
EventStoreService.shared     // Centralized store access
WidgetDataService()         // Widget-optimized data fetching
EventService()              // Event operations
ReminderService()           // Reminder operations
BirthdayService()           // Birthday operations
```

### 2. Memory-Optimized Data Types

**WidgetCalendarItem** vs **CalendarItem**:
- ~75% smaller memory footprint
- `UInt8` color index vs `CGColor` objects
- Only essential dates vs 4+ `Date` objects
- Compact enum representation

### 3. Lazy Loading Implementation

**StandardWidgetContent** now uses lazy properties:
- Data loaded on-demand, not at initialization
- Significant reduction in initial memory allocation
- Better performance for widget startup

## Usage Options

### Option 1: Automatic Hybrid Mode (Recommended)

```swift
// In your widget
HybridWidgetView(for: entry)
```

Benefits:
- Automatically switches to lightweight mode when memory usage > 20MB
- Fallback to standard mode when memory allows
- No configuration required

### Option 2: Force Lightweight Mode

```swift
// In StandardWidgetConfiguration
entry.configuration.useLightweightMode = true

// Then use
LightweightWidgetView(for: entry)
```

### Option 3: Manual Migration

Replace `CamiWidgetView` with `LightweightWidgetView` in your widget:

```swift
// Before
CamiWidgetView(for: entry)

// After
LightweightWidgetView(for: entry)
```

## Memory Profiling

### Enable Memory Monitoring

```swift
// Profile current widget
MemoryProfiler.shared.profileMemoryUsage("Widget Load")

// Check widget memory limit compliance
let isWithinLimit = MemoryProfiler.shared.checkWidgetMemoryLimit()

// Compare memory usage between implementations
MemoryProfiler.shared.compareWidgetContentCreation()
```

### Performance Comparison

Expected improvements:
- **60-70% reduction** in widget memory footprint
- **Eliminated eager loading** - data fetched on-demand
- **Faster widget startup** due to lazy loading
- **Better compliance** with 30MB widget memory limit

## Backward Compatibility

All changes maintain full backward compatibility:
- Existing `StandardWidgetContent` continues to work
- `DataContext` API unchanged
- No breaking changes to widget configurations

## Migration Timeline

### Phase 1: Test Integration ✅
- Created lightweight components
- Added memory profiling utilities
- Implemented hybrid mode switching

### Phase 2: Gradual Rollout
1. Enable `HybridWidgetView` in development
2. Monitor memory usage with `MemoryProfiler`
3. Test on various iOS devices
4. Gradually enable for production users

### Phase 3: Full Migration
1. Switch default to lightweight mode
2. Remove legacy components (optional)
3. Optimize further based on usage data

## Developer Settings Integration

Add to developer settings for easy testing:

```swift
// In DeveloperView or Settings
Toggle("Use Lightweight Widget Mode", isOn: $useLightweightMode)
    .onChange(of: useLightweightMode) { value in
        // Update widget configuration
        StandardWidgetConfiguration.default.useLightweightMode = value
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
```

## Streak Support

The new architecture supports streak calendar items:

```swift
// WidgetCalendarItem now supports .streak kind
enum Kind: UInt8 {
    case event = 0
    case reminder = 1
    case birthday = 2
    case streak = 3  // New!
}
```

## Troubleshooting

### Memory Issues
- Use `MemoryProfiler.shared.checkWidgetMemoryLimit()` to monitor
- Enable lightweight mode if approaching 30MB limit
- Consider reducing event fetch limits in `WidgetDataService`

### Performance Issues
- Check lazy loading is working with memory profiler
- Verify `EventStoreService` is preventing redundant refreshes
- Monitor widget reload frequency

### Data Issues
- Ensure services are providing same data as original implementation
- Use memory profiler to compare data consistency
- Check calendar permission handling

## Future Optimizations

Potential next steps:
1. **Image caching optimization** for contact photos
2. **Background app refresh tuning** for better widget updates
3. **Further data structure optimization** based on usage patterns
4. **Machine learning predictions** for relevant event prioritization

## Support

For questions or issues with the optimization:
1. Check memory usage with `MemoryProfiler`
2. Compare lightweight vs standard widget behavior
3. Review the atomic change history in git commits
4. Test with different widget configurations