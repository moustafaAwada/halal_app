/// Google Maps / Places configuration shared with native map SDKs.
abstract final class MapsConstants {
  /// Same key used in AndroidManifest and iOS AppDelegate.
  static const apiKey = 'AIzaSyBTYNJz-eZVaiaZDm3c5tdKoH8BfpiMnMw';

  static const placesAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  static const placeDetailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  /// Bias search results toward Egypt / Cairo by default.
  static const defaultCountry = 'eg';
  static const defaultLanguage = 'ar';
}
