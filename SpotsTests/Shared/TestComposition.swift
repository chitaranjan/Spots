@testable import Spots
import Foundation
import XCTest

class CompositionTests: XCTestCase {

  #if os(tvOS)
  let heightOffset: CGFloat = 0
  #elseif os(iOS)
  let heightOffset: CGFloat = 0
  #else
  let heightOffset: CGFloat = 2
  #endif

  func testComponentModelCreation() {
    var model = ComponentModel(
      kind: .grid,
      span: 1.0
    )

    model.add(child: ComponentModel(kind: .list, span: 1.0))

    XCTAssertEqual(model.items.count, 1)

    model.add(children: [
      ComponentModel(kind: .list, span: 1.0),
      ComponentModel(kind: .list, span: 1.0)
      ]
    )

    XCTAssertEqual(model.items.count, 3)
  }

  func testCoreComponentCreation() {
    let layout = Layout().mutate { $0.span = 2.0 }
    var model = ComponentModel(kind: .grid, layout: layout)

    model.add(children: [
      ComponentModel(
        kind: .list,
        span: 1.0,
        items: [
          Item(title: "foo"),
          Item(title: "bar")
        ]
      ),
      ComponentModel(
        kind: .list,
        span: 1.0,
        items: [
          Item(title: "baz"),
          Item(title: "bal")
        ]
      )
      ]
    )

    let component = GridComponent(model: model)
    component.setup(with: CGSize(width: 100, height: 100))

    XCTAssertEqual(component.model.items.count, 2)

    guard component.compositeComponents.count == 2 else {
      XCTFail("Could not find composite components")
      return
    }

    XCTAssertEqual(component.compositeComponents.count, 2)
    XCTAssertEqual(component.compositeComponents[0].component.model.kind, ComponentKind.list)
    XCTAssertEqual(component.compositeComponents[0].component.model.items.count, 2)
    XCTAssertEqual(component.compositeComponents[0].component.model.items[0].title, "foo")
    XCTAssertEqual(component.compositeComponents[0].component.model.items[1].title, "bar")

    XCTAssertEqual(component.compositeComponents[1].component.model.kind, ComponentKind.list)
    XCTAssertEqual(component.compositeComponents[1].component.model.items.count, 2)
    XCTAssertEqual(component.compositeComponents[1].component.model.items[0].title, "baz")
    XCTAssertEqual(component.compositeComponents[1].component.model.items[1].title, "bal")
  }

  func testUICreation() {
    var model = ComponentModel(kind: .grid, span: 2.0)

    model.add(children: [
      ComponentModel(
        kind: .list,
        span: 1,
        items: [
          Item(title: "foo"),
          Item(title: "bar")
        ]
      ),
      ComponentModel(
        kind: .list,
        span: 1,
        items: [
          Item(title: "baz"),
          Item(title: "bal")
        ]
      )
      ]
    )

    let component = Component(model: model)
    component.setup(with: CGSize(width: 200, height: 200))

    var composite: Composable?
    var itemConfigurable: ItemConfigurable?

    composite = component.ui(at: 0)

    guard component.compositeComponents.count > 1 else {
      XCTFail("Unable to find composite components.")
      return
    }

    itemConfigurable = component.compositeComponents[0].component.ui(at: 0)

    guard itemConfigurable != nil else {
      XCTFail("Unable to resolve view.")
      return
    }

    XCTAssertNotNil(composite)
    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(component.compositeComponents[0].parentComponent!.model == component.model)
    XCTAssertTrue(component.compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(component.compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(component.compositeComponents[0].component.model.items.count))

    composite = component.ui(at: 1)
    itemConfigurable = component.compositeComponents[0].component.ui(at: 1)

    XCTAssertNotNil(composite)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(component.compositeComponents[1].parentComponent!.model == component.model)
    XCTAssertTrue(component.compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(component.compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(component.compositeComponents[1].component.model.items.count))

    composite = component.ui(at: 2)
    XCTAssertNil(composite)
  }

  func testReloadWithComponentModelsUsingCompositionTriggeringReplaceComponent() {
    let initialComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = SpotsController(components: Parser.parse(initialComponentModels))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let components = controller.components

    XCTAssertEqual(components.count, 2)

    guard components.count == 2 else {
      XCTFail("Component count is incorrect.")
      return
    }

    guard components[0].compositeComponents.count == 2 else {
      XCTFail("Could not find composite components.")
      return
    }

    var composite: Composable? = components[0].ui(at: 0)
    var itemConfigurable: ItemConfigurable? = components[0].compositeComponents[0].component.ui(at: 0)

    guard itemConfigurable != nil else {
      XCTFail("Unable to resolve view.")
      return
    }

    XCTAssertNotNil(composite)
    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[0].compositeComponents[0].parentComponent!.model == components[0].model)
    XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 10)
    XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

    itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
    XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
    XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[1].compositeComponents[0].parentComponent!.model == components[1].model)
    XCTAssertTrue(components[1].compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(components[1].compositeComponents[0].component.model.items.count, 10)
    XCTAssertEqual(components[1].compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[1].compositeComponents[0].component.model.items.count))

    itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[1].compositeComponents[1].parentComponent!.model == components[1].model)
    XCTAssertTrue(components[1].compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(components[1].compositeComponents[1].component.model.items.count, 10)
    XCTAssertEqual(components[1].compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[1].compositeComponents[1].component.model.items.count))

    let newComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 1.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 3.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let expectation = self.expectation(description: "Reload controller with components replaceSpot")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponentModels) {

      reloadTimes += 1

      let components = controller.components

      composite = components[0].ui(at: 0)
      itemConfigurable = components[0].compositeComponents[0].component.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertNotNil(composite?.contentView)

      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[0].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[1].compositeComponents[0].parentComponent!.model == components[1].model)
      XCTAssertTrue(components[1].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[1].compositeComponents[0].component.model.items.count, 10)
      XCTAssertEqual(components[1].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[1].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[1].compositeComponents[1].parentComponent!.model == components[1].model)
      XCTAssertTrue(components[1].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[1].compositeComponents[1].component.model.items.count, 10)
      XCTAssertEqual(components[1].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[1].compositeComponents[1].component.model.items.count))

      XCTAssertEqual(reloadTimes, 1)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadWithComponentModelsUsingCompositionTriggeringNewComponent() {
    let initialComponentModels: [ComponentModel] = []
    let controller = SpotsController(components: Parser.parse(initialComponentModels))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let components = controller.components

    XCTAssertEqual(components.count, 0)

    var composite: Composable?
    var itemConfigurable: ItemConfigurable?

    let newComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 1.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 3.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let expectation = self.expectation(description: "Reload controller with components newSpot")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponentModels) {
      reloadTimes += 1

      let components = controller.components

      composite = components[0].ui(at: 0)

      guard components.count == 2 else {
        XCTFail("Component count is incorrect.")
        return
      }

      guard components[0].compositeComponents.count == 2 else {
        XCTFail("Could not find composite components.")
        return
      }

      itemConfigurable = components[0].compositeComponents[0].component.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[0].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

      guard components[1].compositeComponents.count == 2 else {
        XCTFail("Could not find composite components.")
        return
      }

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[1].compositeComponents[0].parentComponent!.model == components[1].model)
      XCTAssertTrue(components[1].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[1].compositeComponents[0].component.model.items.count, 10)
      XCTAssertEqual(components[1].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[1].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[1].compositeComponents[1].parentComponent!.model == components[1].model)
      XCTAssertTrue(components[1].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[1].compositeComponents[1].component.model.items.count, 10)
      XCTAssertEqual(components[1].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[1].compositeComponents[1].component.model.items.count))

      XCTAssertEqual(reloadTimes, 1)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadWithComponentModelsUsingCompositionTriggeringReloadMore() {
    let initialComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = SpotsController(components: Parser.parse(initialComponentModels))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let components = controller.components

    XCTAssertEqual(components.count, 2)

    var composite: Composable?
    var itemConfigurable: ItemConfigurable?

    composite = components[0].ui(at: 0)

    guard components.count == 2 else {
      XCTFail("Component count is incorrect.")
      return
    }

    guard components[0].compositeComponents.count == 2 else {
      XCTFail("Could not find composite components.")
      return
    }

    itemConfigurable = components[0].compositeComponents[0].component.ui(at: 0)

    guard itemConfigurable != nil else {
      XCTFail("Unable to resolve view.")
      return
    }

    XCTAssertNotNil(composite)
    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[0].compositeComponents[0].parentComponent!.model == components[0].model)
    XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 10)
    XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

    itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
    XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
    XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[1].compositeComponents[0].parentComponent!.model == components[1].model)
    XCTAssertTrue(components[1].compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(components[1].compositeComponents[0].component.model.items.count, 10)
    XCTAssertEqual(components[1].compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[1].compositeComponents[0].component.model.items.count))

    itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[1].compositeComponents[1].parentComponent!.model == components[1].model)
    XCTAssertTrue(components[1].compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(components[1].compositeComponents[1].component.model.items.count, 10)
    XCTAssertEqual(components[1].compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[1].compositeComponents[1].component.model.items.count))

    let newComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10"),
                        Item(title: "Item 11")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let expectation: XCTestExpectation = self.expectation(description: "Reload controller with components triggering reloadMore")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponentModels) {
      reloadTimes += 1

      let components = controller.components

      XCTAssertEqual(components.count, 3)

      composite = components[0].ui(at: 0)
      itemConfigurable = components[0].compositeComponents[0].component.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[0].parentComponent?.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 11)
      XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

      itemConfigurable = components[1].compositeComponents[0].component.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[1].compositeComponents[0].parentComponent?.model == components[1].model)
      XCTAssertTrue(components[1].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[1].compositeComponents[0].component.model.items.count, 11)
      XCTAssertEqual(components[1].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[1].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[1].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[1].compositeComponents[1].parentComponent!.model == components[1].model)
      XCTAssertTrue(components[1].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[1].compositeComponents[1].component.model.items.count, 11)
      XCTAssertEqual(components[1].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[1].compositeComponents[1].component.model.items.count))

      XCTAssertEqual(reloadTimes, 1)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }

  func testReloadWithComponentModelsUsingCompositionTriggeringReloadLess() {
    let initialComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = SpotsController(components: Parser.parse(initialComponentModels))
    controller.prepareController()
    controller.view.layoutIfNeeded()

    let components = controller.components

    XCTAssertEqual(components.count, 2)

    var composite: Composable?
    var itemConfigurable: ItemConfigurable?

    composite = components[0].ui(at: 0)

    guard components.count == 2 else {
      XCTFail("Could not find all components.")
      return
    }

    guard components[0].compositeComponents.count == 2 else {
      XCTFail("Unable to find composite components.")
      return
    }

    let ui: View? = components[0].compositeComponents[0].component.ui(at: 0)
    itemConfigurable = components[0].compositeComponents[0].component.ui(at: 0)

    guard ui != nil else {
      XCTFail("Unable to find composite components.")
      return
    }

    XCTAssertNotNil(composite)

    guard itemConfigurable != nil else {
      XCTFail("Unable to resolve item configurable view.")
      return
    }

    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[0].compositeComponents[0].parentComponent!.model == components[0].model)
    XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 10)
    XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

    itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
    XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
    XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[1].compositeComponents[0].parentComponent!.model == components[1].model)
    XCTAssertTrue(components[1].compositeComponents[0].component.userInterface is TableView)
    XCTAssertEqual(components[1].compositeComponents[0].component.model.items.count, 10)
    XCTAssertEqual(components[1].compositeComponents[0].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[1].compositeComponents[0].component.model.items.count))

    itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

    XCTAssertNotNil(itemConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(components[1].compositeComponents[1].parentComponent!.model == components[1].model)
    XCTAssertTrue(components[1].compositeComponents[1].component.userInterface is TableView)
    XCTAssertEqual(components[1].compositeComponents[1].component.model.items.count, 10)
    XCTAssertEqual(components[1].compositeComponents[1].component.view.frame.size.height,
                   (itemConfigurable!.preferredViewSize.height + heightOffset) * CGFloat(components[1].compositeComponents[1].component.model.items.count))

    let newComponentModels: [ComponentModel] = [
      ComponentModel(kind: .grid,
                span: 2.0,
                items: [
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: CompositeComponent.identifier, children:
                    [
                      ComponentModel(kind: .list, span: 1.0, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let expectation = self.expectation(description: "Reload controller with components  triggering reloadLess")
    var reloadTimes: Int = 0

    controller.reloadIfNeeded(newComponentModels) {
      reloadTimes += 1

      let components = controller.components

      XCTAssertEqual(components.count, 1)

      composite = components[0].ui(at: 0)
      itemConfigurable = components[0].compositeComponents[0].component.ui(at: 0)

      XCTAssertNotNil(composite)
      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[0].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[0].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[0].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[0].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[0].component.model.items.count))

      itemConfigurable = components[0].compositeComponents[1].component.ui(at: 0)

      XCTAssertNotNil(itemConfigurable)
      XCTAssertEqual(composite?.contentView.subviews.count, 1)
      XCTAssertTrue(components[0].compositeComponents[1].parentComponent!.model == components[0].model)
      XCTAssertTrue(components[0].compositeComponents[1].component.userInterface is TableView)
      XCTAssertEqual(components[0].compositeComponents[1].component.model.items.count, 10)
      XCTAssertEqual(components[0].compositeComponents[1].component.view.frame.size.height,
                     ((itemConfigurable?.preferredViewSize.height ?? 0.0) + self.heightOffset) * CGFloat(components[0].compositeComponents[1].component.model.items.count))

      XCTAssertEqual(reloadTimes, 1)

      expectation.fulfill()
    }
    waitForExpectations(timeout: 10.0, handler: nil)
  }
}
