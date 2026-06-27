/// API configuration for Google Places search.
/// 
/// To use Google Places for POI search (bait, gas, boat launches):
/// 1. Go to https://console.cloud.google.com
/// 2. Create a project or select existing
/// 3. Enable "Places API" (not Places SDK)
/// 4. Go to Credentials → Create API Key
/// 5. Paste your key below
/// 
/// Keep the key private — don't share it or commit to public repos.
class ApiConfig {
  ApiConfig._();

  /// Set this to your Google Places API key (optional, for better POI search)
  static const String googlePlacesApiKey = 'YOUR_API_KEY_HERE';

  /// Set this to your OpenWeatherMap API key (free, for weather on catches)
  /// Get one at: https://openweathermap.org/api
  static const String openWeatherApiKey = '34dfeae3007957e5d3ba01a471f2bd21';

  static bool get hasValidPlacesKey => googlePlacesApiKey.isNotEmpty && googlePlacesApiKey != 'YOUR_API_KEY_HERE';
  static bool get hasValidWeatherKey => openWeatherApiKey.isNotEmpty && openWeatherApiKey != 'YOUR_WEATHER_KEY_HERE';
}
