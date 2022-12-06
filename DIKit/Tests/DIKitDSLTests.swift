// DIKitDSLTests.swift
//
// - Authors:
// Ben John
//
// - Date: 27.08.20
// Copyright © 2020 Ben John. All rights reserved.

import XCTest
@testable import DIKit

class DIKitDSLTests: XCTestCase {
    func testDependencyContainerDeriveDSL() {
        struct ComponentA {}
        struct ComponentB {}
        struct ComponentC {}

        let dependencyContainerA = module {
            single { ComponentA() }
        }
        let dependencyContainerB = module {
            single { ComponentB() }
        }
        let dependencyContainerC = module {
            single { ComponentC() }
        }
        let dependencyContainerD = module {
            single(tag: "tag") { ComponentC() }
        }

        let dependencyContainer = modules {
            dependencyContainerA
            dependencyContainerB
            dependencyContainerC
            dependencyContainerD
        }

        let componentA: ComponentA = dependencyContainer.resolve()
        XCTAssertNotNil(componentA)

        let componentB: ComponentB = dependencyContainer.resolve()
        XCTAssertNotNil(componentB)

        let componentC: ComponentC = dependencyContainer.resolve()
        XCTAssertNotNil(componentC)

        let taggedComponentC: ComponentC = dependencyContainer.resolve(tag: "tag")
        XCTAssertNotNil(taggedComponentC)
    }

    func testFactoryOfComponentsDSL() {
        class ComponentA {}

        let dependencyContainer = module {
            factory { ComponentA() }
        }

        let componentAinstanceA: ComponentA = dependencyContainer.resolve()
        XCTAssertNotNil(componentAinstanceA)
        func testDependencyContainerDeriveDSL() {
            struct ComponentA {}
            struct ComponentB {}
            struct ComponentC {}

            let dependencyContainerA = module {
                single { ComponentA() }
            }
            let dependencyContainerB = module {
                single { ComponentB() }
            }
            let dependencyContainerC = module {
                single { ComponentC() }
            }
            let dependencyContainerD = module {
                single(tag: "tag") { ComponentC() }
            }

            let dependencyContainer = modules {
                dependencyContainerA
                dependencyContainerB
                dependencyContainerC
                dependencyContainerD
            }

            let componentA: ComponentA = dependencyContainer.resolve()
            XCTAssertNotNil(componentA)

            let componentB: ComponentB = dependencyContainer.resolve()
            XCTAssertNotNil(componentB)

            let componentC: ComponentC = dependencyContainer.resolve()
            XCTAssertNotNil(componentC)

            let taggedComponentC: ComponentC = dependencyContainer.resolve(tag: "tag")
            XCTAssertNotNil(taggedComponentC)
        }

        func testFactoryOfComponentsDSL() {
            class ComponentA {}

            let dependencyContainer = module {
                factory { ComponentA() }
            }

            let componentAinstanceA: ComponentA = dependencyContainer.resolve()
            XCTAssertNotNil(componentAinstanceA)

            let componentAinstanceB: ComponentA = dependencyContainer.resolve()
            XCTAssertNotNil(componentAinstanceB)

            let componentAinstanceAobjectIdA = ObjectIdentifier(componentAinstanceA)
            let componentAinstanceAobjectIdB = ObjectIdentifier(componentAinstanceA)
            let componentAinstanceBobjectId = ObjectIdentifier(componentAinstanceB)

            XCTAssertEqual(componentAinstanceAobjectIdA, componentAinstanceAobjectIdB)
            XCTAssertNotEqual(componentAinstanceAobjectIdA, componentAinstanceBobjectId)
        }

        func testSingletonLifetimeOfComponentsDSL() {
            class ComponentA {}

            let dependencyContainer = module {
                single { ComponentA() }
            }

            let componentAinstanceA: ComponentA = dependencyContainer.resolve()
            XCTAssertNotNil(componentAinstanceA)

            let componentAinstanceB: ComponentA = dependencyContainer.resolve()
            XCTAssertNotNil(componentAinstanceB)

            let componentAinstanceAobjectIdA = ObjectIdentifier(componentAinstanceA)
            let componentAinstanceAobjectIdB = ObjectIdentifier(componentAinstanceA)
            let componentAinstanceBobjectId = ObjectIdentifier(componentAinstanceB)

            XCTAssertEqual(componentAinstanceAobjectIdA, componentAinstanceAobjectIdB)
            XCTAssertEqual(componentAinstanceAobjectIdA, componentAinstanceBobjectId)
        }
        let componentAinstanceB: ComponentA = dependencyContainer.resolve()
        XCTAssertNotNil(componentAinstanceB)

        let componentAinstanceAobjectIdA = ObjectIdentifier(componentAinstanceA)
        let componentAinstanceAobjectIdB = ObjectIdentifier(componentAinstanceA)
        let componentAinstanceBobjectId = ObjectIdentifier(componentAinstanceB)

        XCTAssertEqual(componentAinstanceAobjectIdA, componentAinstanceAobjectIdB)
        XCTAssertNotEqual(componentAinstanceAobjectIdA, componentAinstanceBobjectId)
    }

    func testSingletonLifetimeOfComponentsDSL() {
        class ComponentA {}

        let dependencyContainer = module {
            single { ComponentA() }
        }

        let componentAinstanceA: ComponentA = dependencyContainer.resolve()
        XCTAssertNotNil(componentAinstanceA)

        let componentAinstanceB: ComponentA = dependencyContainer.resolve()
        XCTAssertNotNil(componentAinstanceB)

        let componentAinstanceAobjectIdA = ObjectIdentifier(componentAinstanceA)
        let componentAinstanceAobjectIdB = ObjectIdentifier(componentAinstanceA)
        let componentAinstanceBobjectId = ObjectIdentifier(componentAinstanceB)

        XCTAssertEqual(componentAinstanceAobjectIdA, componentAinstanceAobjectIdB)
        XCTAssertEqual(componentAinstanceAobjectIdA, componentAinstanceBobjectId)
    }

    func testSingletonCreatedAtStartDSL() {
        func ptr(_ object: AnyObject) -> UnsafeMutableRawPointer {
            Unmanaged.passUnretained(object).toOpaque()
        }

        var countA = 0
        var countB = 0
        var countD = 0
        var countE = 0

        class ComponentA {
            init(_ counter: inout Int) {
                counter += 1
            }
        }
        class ComponentB {
            init(_ counter: inout Int) {
                counter += 1
            }
        }
        class ComponentC { }
        class ComponentD {
            init(_ counter: inout Int) {
                counter += 1
            }
        }
        class ComponentE {
            init(_ counter: inout Int) {
                counter += 1
            }
        }

        let subModule2 = module {
            factory { ComponentD(&countD) }
            single(createdAtStart: true) { ComponentE(&countE) }
        }

        let subModule1 = modules {
            subModule2
            module { single { ComponentC() } }
        }

        let rootModule = modules {
            module {
                single(createdAtStart: true, tag: "test") { ComponentA(&countA) }
                single { ComponentB(&countB) }
            }
            subModule1
        }

        // if E is a singleton created at startup:
        // * the counter must be zero before the "defined" call
        // * 1 immediately after defining the containter
        // * stay 1 after every inject
        // * and each inject must be the same pointer
        XCTAssert(countA == 0)
        XCTAssert(countB == 0)
        XCTAssert(countD == 0)
        XCTAssert(countE == 0)
        DependencyContainer.defined(by: rootModule)
        XCTAssert(countA == 1)
        XCTAssert(countE == 1)

        @Inject var ce1: ComponentE
        @Inject var ce2: ComponentE
        XCTAssert(countE == 1)
        XCTAssert(ptr(ce1) == ptr(ce2))

        // countA must stay 1 since it is a singleton created at start
        XCTAssert(countA == 1)
        @Inject(tag: "test") var ca1: ComponentA
        XCTAssert(countA == 1)
        @Inject(tag: "test") var ca2: ComponentA
        XCTAssert(countA == 1)
        XCTAssert(ptr(ca1) == ptr(ca2))

        // B is a regular singleton and must not exist before first inject
        XCTAssert(countB == 0)
        @Inject var cb1: ComponentB
        XCTAssert(countB == 1)
        @Inject var cb2: ComponentB
        XCTAssert(countB == 1)
        XCTAssert(ptr(cb1) == ptr(cb2))

        // D is factory managed. Counter must increase.
        XCTAssert(countD == 0)
        @Inject var cd1: ComponentD
        XCTAssert(countD == 1)
        @Inject var cd2: ComponentD
        XCTAssert(countD == 2)
        XCTAssert(ptr(cd1) != ptr(cd2))
    }
}
