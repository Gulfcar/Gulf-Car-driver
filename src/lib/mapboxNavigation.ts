import { NativeModules } from 'react-native';

type MapboxNavigationModule = {
  startNavigation: (originLat: number, originLng: number, destinationLat: number, destinationLng: number, simulation: boolean) => void;
};

export default NativeModules.MapboxNavigation as MapboxNavigationModule | undefined;
