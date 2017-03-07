@testable import Spots
import Foundation
import XCTest

class ListCompositeTests: XCTestCase {

  func testListComposite() {
    let view = ListComposite()
    var item = Item()
    let gridSpot = CompositeComponent(component: GridComponent(model: ComponentModel(span: 1)), itemIndex: 0)
    view.configure(&item, compositeComponents: [gridSpot])

    XCTAssertTrue(view.contentView.subviews.count == 1)

    let carouselSpot = CompositeComponent(component: CarouselComponent(model: ComponentModel(span: 1)), itemIndex: 0)
    let listSpot = CompositeComponent(component: ListComponent(model: ComponentModel(span: 1)), itemIndex: 0)
    view.configure(&item, compositeComponents: [carouselSpot, listSpot])

    XCTAssertTrue(view.contentView.subviews.count == 3)
    XCTAssertTrue(view.contentView.subviews[0] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[1] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[2] is UITableView)

    view.prepareForReuse()
    XCTAssertTrue(view.contentView.subviews.count == 0)

    view.configure(&item, compositeComponents: nil)
    XCTAssertTrue(view.contentView.subviews.count == 0)

    view.configure(&item, compositeComponents: [carouselSpot, listSpot])
    XCTAssertTrue(view.contentView.subviews.count == 2)
    XCTAssertTrue(view.contentView.subviews[0] is UICollectionView)
    XCTAssertTrue(view.contentView.subviews[1] is UITableView)

    let customView = UIView()
    view.contentView.addSubview(customView)
    view.prepareForReuse()
    XCTAssertTrue(view.contentView.subviews.count == 1)
  }
}
