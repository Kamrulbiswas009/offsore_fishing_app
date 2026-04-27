import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

const String kDefaultMapboxAccessToken =
    'pk.eyJ1Ijoib250aGViaXRlIiwiYSI6ImNtb2VheTVndjA3YzAycXE0NnJkcXFremQifQ.KLolpMGFvBjx0-zJe4njCA';

const String kMapboxAccessToken = String.fromEnvironment(
  'MAPBOX_ACCESS_TOKEN',
  defaultValue: kDefaultMapboxAccessToken,
);

void initializeMapbox() {
  if (kMapboxAccessToken.isNotEmpty) {
    mapbox.MapboxOptions.setAccessToken(kMapboxAccessToken);
  }
}
