#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(MapboxEmbeddedNavigationViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(originLat, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(originLng, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(destinationLat, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(destinationLng, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(simulation, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(onNavigationReady, RCTDirectEventBlock)
@end
