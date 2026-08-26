import CoreLocation
import MapboxMaps
import MapboxNavigationCore
import MapboxNavigationUIKit
import React
import UIKit

final class MapboxEmbeddedNavigationView: UIView {
  @objc dynamic var originLat: NSNumber = 0 { didSet { startIfReady() } }
  @objc dynamic var originLng: NSNumber = 0 { didSet { startIfReady() } }
  @objc dynamic var destinationLat: NSNumber = 0 { didSet { startIfReady() } }
  @objc dynamic var destinationLng: NSNumber = 0 { didSet { startIfReady() } }
  @objc dynamic var simulation: NSNumber = false { didSet { startIfReady() } }
  @objc dynamic var onNavigationReady: RCTDirectEventBlock?

  private var started = false
  private var controller: NavigationViewController?
  private var cameraAligned = false
  private var revealed = false
  private var locationCancelable: Cancelable?

  override func didMoveToWindow() {
    super.didMoveToWindow()
    startIfReady()
  }

  private func startIfReady() {
    guard window != nil, !started,
          originLat.doubleValue != 0, originLng.doubleValue != 0,
          destinationLat.doubleValue != 0, destinationLng.doubleValue != 0 else { return }
    started = true

    let origin = CLLocationCoordinate2D(latitude: originLat.doubleValue, longitude: originLng.doubleValue)
    let destination = CLLocationCoordinate2D(latitude: destinationLat.doubleValue, longitude: destinationLng.doubleValue)
    let source: LocationSource = simulation.boolValue ? .simulation(initialLocation: CLLocation(latitude: origin.latitude, longitude: origin.longitude)) : .live
    let provider = MapboxNavigationProvider(coreConfig: .init(locationSource: source))
    provider.routeVoiceController.speechSynthesizer.muted = true
    let request = provider.mapboxNavigation.routingProvider().calculateRoutes(options: NavigationRouteOptions(coordinates: [origin, destination]))

    Task { @MainActor in
      guard case .success(let routes) = await request.result else { return }
      let options = NavigationOptions(mapboxNavigation: provider.mapboxNavigation, voiceController: provider.routeVoiceController, eventsManager: provider.eventsManager())
      let navigation = NavigationViewController(navigationRoutes: routes, navigationOptions: options)
      navigation.automaticallyAdjustsStyleForTimeOfDay = false
      navigation.usesNightStyleInDarkMode = true
      navigation.floatingButtons = []
      navigation.view.frame = bounds
      navigation.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      // Keep the map hidden while the route loads and the camera settles,
      // so the user never sees the initial camera jumps.
      navigation.view.alpha = 0
      addSubview(navigation.view)
      controller = navigation

      guard let navigationMapView = navigation.navigationMapView else {
        reveal()
        return
      }

      navigationMapView.mapView.mapboxMap.setCamera(
        to: CameraOptions(center: origin, zoom: 16.5, bearing: 0, pitch: 0)
      )

      let mapView = navigationMapView.mapView
      locationCancelable = mapView.location.onLocationChange.observe { [weak self] (newLocations: [Location]) in
        guard let self, !self.cameraAligned, let location = newLocations.last else { return }
        self.cameraAligned = true
        self.locationCancelable?.cancel()
        mapView.camera.ease(
          to: CameraOptions(center: location.coordinate, zoom: 16.5),
          duration: 0.5
        )
        self.reveal()
      }

      // If no location fix ever arrives, still reveal so the map isn't blank.
      DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
        self?.reveal()
      }

      hideNavigationChrome(in: navigation.view)
    }
  }

  private func reveal() {
    guard !revealed, let controller else { return }
    revealed = true
    UIView.animate(withDuration: 0.45, animations: { controller.view.alpha = 1 }) { _ in
      self.onNavigationReady?(["ready": true])
    }
  }

  private func hideNavigationChrome(in view: UIView) {
    for child in view.subviews {
      let name = String(describing: type(of: child))
      if name.contains("Banner") || name.contains("Floating") || name.contains("Ornament") || name.contains("Button") {
        child.isHidden = true
      } else {
        hideNavigationChrome(in: child)
      }
    }
  }
}
