import { requireNativeComponent, type ViewProps } from 'react-native';

export default requireNativeComponent<ViewProps & {
  originLat: number;
  originLng: number;
  destinationLat: number;
  destinationLng: number;
  simulation: boolean;
  onNavigationReady?: (event: { ready: boolean }) => void;
}>('MapboxEmbeddedNavigationView');
