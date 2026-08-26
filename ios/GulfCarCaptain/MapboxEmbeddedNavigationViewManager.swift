import React

@objc(MapboxEmbeddedNavigationViewManager)
final class MapboxEmbeddedNavigationViewManager: RCTViewManager {
  override func view() -> UIView! { MapboxEmbeddedNavigationView() }
  override static func requiresMainQueueSetup() -> Bool { true }
}
