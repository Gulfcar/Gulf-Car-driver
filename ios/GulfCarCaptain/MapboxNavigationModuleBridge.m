#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(MapboxNavigation, NSObject)
RCT_EXTERN_METHOD(startNavigation:(nonnull NSNumber *)originLat
                  originLng:(nonnull NSNumber *)originLng
                  destinationLat:(nonnull NSNumber *)destinationLat
                  destinationLng:(nonnull NSNumber *)destinationLng
                  simulation:(nonnull NSNumber *)simulation)
@end
