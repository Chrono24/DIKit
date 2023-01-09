// DependencyContainer+Resolve.swift
//
// - Authors:
// Ben John
//
// - Date: 17.08.18
// Copyright © 2018 Ben John. All rights reserved.

extension DependencyContainer {
    /// Resolves nil safe a `Component<T>`.
    ///
    /// - Parameter tag: An optional *tag* to identify the Component. `nil` per default.
    /// - Returns: The resolved `Optional<Component<T>>`.
    func _resolve<T>(tag: AnyHashable? = nil) -> T? {
        var result: T?
        threadSafe {
            let identifier = ComponentIdentifier(tag: tag, type: T.self)

            if let foundComponent = self.componentStack[identifier] {
                if foundComponent.lifetime == .factory {
                    result = foundComponent.componentFactory() as? T
                } else {
                    if let instanceOfComponent = self.instanceStack[identifier] as? T {
                        result = instanceOfComponent
                    } else {
                        instanceStack[identifier] = foundComponent.componentFactory()
                        result = instanceStack[identifier] as? T
                    }
                }
            }
        }
        return result
    }

    /// Checks whether `Component<T>` is resolvable by looking it up in the
    /// `componentStack`.
    ///
    /// - Parameters:
    ///     - type: The generic *type* of the `Component`.
    ///     - tag: An optional *tag* to identify the Component. `nil` per default.
    ///
    /// - Returns: `Bool` whether `Component<T>` is resolvable or not.
    func resolvable<T>(type: T.Type, tag: AnyHashable? = nil) -> Bool {
        let identifier = ComponentIdentifier(tag: tag, type: T.self)
        return self.componentStack[identifier] != nil
    }

    /// Resolves a `Component<T>`.
    /// Implicitly assumes that the `Component` can be resolved.
    /// Throws a fatalError if the `Component` is not registered.
    ///
    /// - Parameter tag: An optional *tag* to identify the Component. `nil` per default.
    ///
    /// - Returns: The resolved `Component<T>`.
    public func resolve<T>(tag: AnyHashable? = nil) -> T {
        if let t: T = _resolve(tag: tag) {
            return t
        }
        fatalError("Component `\(String(describing: T.self))` could not be resolved.")
    }
}
