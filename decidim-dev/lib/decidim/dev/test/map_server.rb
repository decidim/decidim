# frozen_string_literal: true

module Decidim
  module Dev
    module Test
      # The test map server serves all map related requests for the app.
      #
      # Works as a rack middleware that is mounted to the Rails app during
      # tests (at the decidim-dev module's engine).
      class MapServer
        def self.host
          "http://#{hostname}:#{Capybara.server_port}"
        end

        def self.hostname
          "maps.lvh.me"
        end

        def self.url(endpoint)
          case endpoint
          when :tiles
            "#{host}/maptiles/{z}/{x}/{y}.png"
          when :static
            "#{host}/static"
          when :autocomplete
            "#{host}/photon_api"
          end
        end

        def initialize(app)
          @app = app
        end

        def call(env)
          request = Rack::Request.new(env)
          return @app.call(env) unless request.host == self.class.hostname

          if (match = request.path.match(%r{^/maptiles/([0-9]+)/([0-9]+)/([0-9]+).png$}))
            return serve_maptiles(request, { z: match[1], x: match[2], y: match[3] })
          elsif request.path == "/static"
            return serve_static(request)
          elsif request.path == "/photon_api"
            return serve_autocomplete(request)
          end

          not_found
        end

        private

        def tile_image_content
          @tile_image_content ||= File.read(Decidim::Dev.asset("icon.png"))
        end

        def serve_maptiles(_request, _properties)
          [200, { "Content-Type" => "image/png" }, [tile_image_content]]
        end

        def serve_static(_request)
          [200, { "Content-Type" => "image/png" }, [tile_image_content]]
        end

        def serve_autocomplete(_request)
          photon_response = {
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
                  coordinates: [2.234, 1.123]
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
                  coordinates: [4.456, 3.345]
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
                  coordinates: [6.678, 5.567]
                }
              }
            ]
          }.tap do |response|
            Decidim::Map::Provider::Autocomplete::Test.stubs.length.positive? &&
              response[:features] = Decidim::Map::Provider::Autocomplete::Test.stubs
          end

          [
            200,
            {
              "Content-Type" => "application/json",
              "Access-Control-Allow-Origin" => "*"
            },
            [photon_response.to_json.to_s]
          ]
        end

        def not_found
          [404, { "Content-Type" => "text/plain" }, ["Not found."]]
        end
      end
    end
  end
end
