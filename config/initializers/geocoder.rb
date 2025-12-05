Geocoder.configure(
  # Geocoding options
  timeout: 5,                 # geocoding service timeout (secs)
  lookup: :nominatim,         # OpenStreetMap Nominatim (free, no API key)
  language: :fr,              # ISO-639 language code
  use_https: true,            # use HTTPS for lookup requests

  # Calculation options
  units: :km,                 # :km for kilometers or :mi for miles
  distances: :spherical       # :spherical or :linear
)
