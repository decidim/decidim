# frozen_string_literal: true

module GeocoderHelpers
  def stub_geocoding(address, coordinates)
    result = coordinates.blank? ? [] : [{ "coordinates" => [latitude, longitude] }]

    unless @stub_geocoding
      @stub_geocoding = true
      self.class.after do
        # Clear the autocomplete stubs
        Decidim::Map::Provider::Autocomplete::Test.clear_stubs
      end
    end

    Geocoder::Lookup::Test.add_stub(
      address,
      result
    )
    Decidim::Map::Provider::Autocomplete::Test.add_stub(
      address,
      coordinates
    )
  end

  def stub_geocoding_coordinates(coordinates)
    geocoder_request_url = "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=#{coordinates[0]}&lon=#{coordinates[1]}"
    geocoder_response = File.read(Decidim::Dev.asset("geocoder_result_here.json"))

    stub_request(:get, geocoder_request_url).with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "User-Agent" => "Ruby"
      }
    ).to_return(body: geocoder_response)
  end

  # Waits for the front-end geocoding request to finish in order to ensure there
  # are no pending requests when proceeding.
  def fill_in_geocoding(attribute, options = {})
    fill_in attribute, **options
    expect(page).to have_css(".autoComplete_wrapper ul#autoComplete_list_1", count: 1)
    find("li#autoComplete_result_0").click
  end

  module_function

  public def configure_maps
    # Set maps configuration in test mode
    Decidim.maps = {
      provider: :test,
      api_key: "1234123412341234",
      dynamic: {
        tile_layer: {
          url: Decidim::Dev::Test::MapServer.url(:tiles)
        }
      },
      static: { url: Decidim::Dev::Test::MapServer.url(:static) },
      autocomplete: { url: Decidim::Dev::Test::MapServer.url(:autocomplete) }
    }
  end
end

module Decidim::Map::Provider
  module Geocoding
    class Test < ::Decidim::Map::Geocoding; end
  end

  module Autocomplete
    class Test < ::Decidim::Map::Autocomplete
      def self.stubs
        @stubs ||= []
      end

      def self.add_stub(address, coordinates)
        stubs.push(
          properties: address.is_a?(Hash) ? address : { street: address },
          geometry: { coordinates: coordinates.reverse }
        )
      end

      def self.clear_stubs
        @stubs = []
      end

      def builder_options
        { url: configuration.fetch(:url, nil) }.compact
      end

      class Builder < Decidim::Map::Autocomplete::Builder
        def append_assets
          template.append_javascript_pack_tag("decidim_geocoding_provider_photon")
        end
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

  config.before(:each, :configures_map) do
    # Make sure that every spec starts with the default configuration. Otherwise
    # this can cause issues with randomized test order.
    Decidim::Map.reset_utility_configuration!
    configure_maps
  end

  config.after(:each, :configures_map) do
    # Ensure the initializer is always re-run after the examples because
    # otherwise the utilities could remain unregistered which causes issues with
    # further tests.
    Decidim::Core::Engine.initializers.each do |i|
      next unless i.name == "decidim_core.maps"

      i.run
      break
    end

    # Ensure the utility configuration is reset after each example for it to be
    # reloaded the next time, as the next test may be outside of the
    # `configures_map` context.
    Decidim::Map.reset_utility_configuration!
    configure_maps
  end
end
