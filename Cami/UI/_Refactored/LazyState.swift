//
//  LazyState.swift
//  Cami
//
//  Created by Guillaume Coquard on 28.09.25.
//

import SwiftUI

@MainActor
@propertyWrapper
public struct LazyState<Value>: DynamicProperty {

    /// A private, heap-allocated storage container that manages the lazy initialization logic.
    ///
    /// This class uses an enum for its storage to safely handle initialization and prevent
    /// issues with double optionals when the `Value` type is itself an optional.
    private final class Holder {
        private enum Storage {
            case uninitialized(() -> Value)
            case initialized(Value)
        }

        private var storage: Storage

        init(thunk: @autoclosure @escaping () -> Value) {
            self.storage = .uninitialized(thunk)
        }

        func value() -> Value {
            // If the value is already initialized, return it directly.
            if case let .initialized(value) = storage {
                return value
            }

            // Ensure we are in the uninitialized state before proceeding.
            guard case let .uninitialized(thunk) = storage else {
                // This state is logically unreachable and indicates a flaw in the logic.
                fatalError("LazyState entered an invalid state. This should not happen.")
            }

            // Execute the thunk to create the value, update the storage to .initialized, and return.
            let newValue = thunk()
            storage = .initialized(newValue)
            return newValue
        }
    }

    @State private var holder: Holder

    /// The lazily initialized value.
    ///
    /// The underlying value is created only once, the first time this property is accessed.
    public var wrappedValue: Value {
        holder.value()
    }

    /// A read-only binding to the wrapped value.
    public var projectedValue: Binding<Value> {
        Binding(get: { wrappedValue }, set: { _ in
            // This binding is read-only to align with the immutable nature of lazy initialization.
            // To modify state, mutate the properties of the wrapped Observable object directly.
        })
    }

    /// Creates a lazy state for a **non-optional** `Observable` object.
    /// - Parameter thunk: An autoclosure that returns the initial value.
    public init(wrappedValue thunk: @autoclosure @escaping () -> Value) {
        _holder = State(initialValue: Holder(thunk: thunk()))
    }

    /// Creates a lazy state for an **optional** `Observable` object.
    /// - Parameter thunk: An autoclosure that returns the initial value, which can be `nil`.
    public init<T: Observable>(wrappedValue thunk: @autoclosure @escaping () -> T?) where Value == T? {
        _holder = State(initialValue: Holder(thunk: thunk()))
    }
}
