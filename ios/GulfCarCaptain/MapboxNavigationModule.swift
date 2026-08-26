import CoreLocation
import MapboxNavigationCore
import MapboxNavigationUIKit
import UIKit

@objc(MapboxNavigation)
final class MapboxNavigationModule: NSObject {
  @objc(startNavigation:originLng:destinationLat:destinationLng:simulation:)
  func startNavigation(_ originLat: NSNumber, originLng: NSNumber, destinationLat: NSNumber, destinationLng: NSNumber, simulation: NSNumber) {
      let origin = CLLocationCoordinate2D(latitude: originLat.doubleValue, longitude: originLng.doubleValue)
      let destination = CLLocationCoordinate2D(latitude: destinationLat.doubleValue, longitude: destinationLng.doubleValue)

      DispatchQueue.main.async {
        let locationSource: LocationSource = simulation.boolValue ? .simulation() : .live
        let provider = MapboxNavigationProvider(coreConfig: .init(locationSource: locationSource))
        provider.routeVoiceController.speechSynthesizer.muted = true
        let options = NavigationRouteOptions(coordinates: [origin, destination])
        let request = provider.mapboxNavigation.routingProvider().calculateRoutes(options: options)

        Task { @MainActor in
          guard case .success(let routes) = await request.result else { return }
          let navigationOptions = NavigationOptions(
            mapboxNavigation: provider.mapboxNavigation,
            voiceController: provider.routeVoiceController,
            eventsManager: provider.eventsManager()
          )
          let controller = NavigationViewController(navigationRoutes: routes, navigationOptions: navigationOptions)
          controller.modalPresentationStyle = .fullScreen
          controller.overrideUserInterfaceStyle = .dark
          controller.automaticallyAdjustsStyleForTimeOfDay = false
          controller.usesNightStyleInDarkMode = true
          controller.routeLineTracksTraversal = true
          Self.topViewController()?.present(controller, animated: true)
        }
      }
  }

  private static func topViewController(_ root: UIViewController? = UIApplication.shared.connectedScenes
    .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
    .first) -> UIViewController? {
    if let presented = root?.presentedViewController { return topViewController(presented) }
    if let navigation = root as? UINavigationController { return topViewController(navigation.visibleViewController) }
    if let tab = root as? UITabBarController { return topViewController(tab.selectedViewController) }
    return root
  }
}
