# frozen_string_literal: true

module GeocoderHelpers
  def stub_geocoding(address, coordinates)
    result = coordinates.blank? ? [] : [{ "coordinates" => [latitude, longitude] }]

    Geocoder::Lookup::Test.add_stub(
      address,
      result
    )
    Decidim::Map::Provider::Autocomplete::Test.add_stub(
      address,
      coordinates
    )
  end

  # Waits for the front-end geocoding request to finish in order to ensure there
  # are no pending requests when proceeding.
  def fill_in_geocoding(attribute, options = {})
    fill_in attribute, **options
    expect(page).to have_selector(".autoComplete_wrapper ul#autoComplete_list_1", count: 1)
    find("li#autoComplete_result_0").click
  end

  module_function

  public def configure_maps
    # Set maps configuration in test mode
    Decidim.maps = {
      provider: :test,
      api_key: "1234123412341234",
      static: { url: "https://www.example.org/my_static_map" },
      autocomplete: { url: "/photon_api" } # Locally drawn route for the tests
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
          geometry: { coordinates: coordinates }
        )
      end

      def self.clear_stubs
        @stubs = []
      end

      def builder_options
        { url: configuration.fetch(:url, nil) }.compact
      end

      class Builder < Decidim::Map::Autocomplete::Builder
        def javascript_snippets
          template.javascript_pack_tag("decidim_geocoding_provider_photon", defer: false)
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
  end

  config.before(:each, :serves_geocoding_autocomplete) do
    # Clear the autocomplete stubs
    Decidim::Map::Provider::Autocomplete::Test.clear_stubs

    photon_response = lambda do
      {
        features: [
          {
            properties: {
              name: "Park",
              street: "Street1",
              housenumber: "1",
              postcode: "123456",
              city: "City1",
              state: "State1",
              country: "Country1"
            },
            geometry: {
              coordinates: [1.123, 2.234]
            }
          },
          {
            properties: {
              street: "Street2",
              postcode: "654321",
              city: "City2",
              country: "Country2"
            },
            geometry: {
              coordinates: [3.345, 4.456]
            }
          },
          {
            properties: {
              street: "Street3",
              housenumber: "3",
              postcode: "142536",
              city: "City3",
              country: "Country3"
            },
            geometry: {
              coordinates: [5.567, 6.678]
            }
          }
        ]
      }.tap do |response|
        Decidim::Map::Provider::Autocomplete::Test.stubs.length.positive? &&
          response[:features] = Decidim::Map::Provider::Autocomplete::Test.stubs
      end
    end

    # The Photon API path needs to be mounted in the application itself because
    # otherwise we would have to run a separate server for the API itself.
    # Mocking the request would not work here because the call to the Photon API
    # is initialized by the front-end to the URL specified for the maps
    # geocoding autocompletion configuration which is not proxied by the
    # headless browser running the Capybara tests.
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get "photon_api", to: ->(_) { [200, { "Content-Type" => "application/json" }, [photon_response.call.to_json.to_s]] }
    end
    Rails.application.routes.disable_clear_and_finalize = false
  end

  config.after(:each, :serves_geocoding_autocomplete) do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end
end
