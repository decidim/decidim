# frozen_string_literal: true

module GeocoderHelpers
  def stub_geocoding(address, coordinates)
    result = coordinates.blank? ? [] : [{ "coordinates" => [latitude, longitude] }]

    Geocoder::Lookup::Test.add_stub(
      address,
      result
    )
  end

  module_function

  public def configure_maps
    # Set maps configuration in test mode
    Decidim.maps = {
      provider: :test,
      api_key: "1234123412341234",
      static: { url: "https://www.example.org/my_static_map" },
      autocomplete: { url: "https://photon.example.org/api/" }
    }
  end
end

module Decidim::Map::Provider
  module Geocoding
    class Test < ::Decidim::Map::Geocoding; end
  end
  module Autocomplete
    class Test < ::Decidim::Map::Autocomplete
      def builder_options
        { url: configuration.fetch(:url, nil) }.compact
      end
    end
  end
  module DynamicMap
    class Test < ::Decidim::Map::DynamicMap; end
  end
  module StaticMap
    class Test < ::Decidim::Map::StaticMap; end
  end
end

RSpec.configure do |config|
  config.include GeocoderHelpers

  config.before(:suite) do
    GeocoderHelpers.configure_maps
  end

  config.after(:each, :configures_map) do
    # Ensure the initializer is always re-run after the examples because
    # otherwise the utilities could remain unregistered which causes issues with
    # further tests.
    Decidim::Core::Engine.initializers.each do |i|
      next unless i.name == "decidim.maps"

      i.run
      break
    end

    # Ensure the utility configuration is reset after each example for it to be
    # reloaded the next time.
    Decidim::Map.reset_utility_configuration!
    configure_maps
  end

  config.before(:each, :serves_map) do
    stub_request(:get, %r{https://www\.example\.org/my_static_map})
      .to_return(body: "map_data")
    stub_request(:get, %r{https://photon\.example\.org/api/})
      .to_return(body: { results: [] }.to_json.to_s)
  end
end
