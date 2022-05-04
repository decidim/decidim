# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Map, configures_map: true do
    let(:config) { { provider: :osm } }

    before do
      allow(Decidim).to receive(:maps).and_return(config)
    end

    describe ".configured?" do
      context "when configuration is present" do
        it "returns true" do
          expect(subject.configured?).to be(true)
        end
      end

      context "when configuration is empty" do
        let(:config) { {} }

        it "returns true" do
          expect(subject.configured?).to be(false)
        end
      end

      context "when configuration is not present" do
        let(:config) { nil }

        it "returns false" do
          expect(subject.configured?).to be(false)
        end
      end
    end

    describe ".available?" do
      it "returns true for all the available utilities" do
        expect(subject.available?(:dynamic)).to be(true)
        expect(subject.available?(:static)).to be(true)
        expect(subject.available?(:geocoding)).to be(true)
      end

      it "returns true for a list of available utilities" do
        expect(subject.available?(:dynamic, :static, :geocoding)).to be(true)
      end

      it "returns false for an unavailable utility" do
        expect(subject.available?(:foobar)).to be(false)
      end

      it "returns false for a list of utilities of which one is unavailable" do
        expect(subject.available?(:dynamic, :static, :geocoding, :foobar)).to be(false)
      end

      context "when the categories are unregistered" do
        it "returns false for the previously available utilities" do
          subject.unregister_category(:dynamic)
          subject.unregister_category(:static)
          subject.unregister_category(:geocoding)

          expect(subject.available?(:dynamic)).to be(false)
          expect(subject.available?(:static)).to be(false)
          expect(subject.available?(:geocoding)).to be(false)
        end
      end

      context "when the provider has not been configured" do
        let(:config) { {} }

        it "returns false for the registered utilities" do
          expect(subject.available?(:dynamic)).to be(false)
          expect(subject.available?(:static)).to be(false)
          expect(subject.available?(:geocoding)).to be(false)
        end
      end

      context "when the dynamic provider has been disabled configured" do
        let(:config) { { provider: :osm, dynamic: false } }

        it "returns true for all the non-disabled utilities and false for the dynamic utility" do
          expect(subject.available?(:dynamic)).to be(false)
          expect(subject.available?(:static)).to be(true)
          expect(subject.available?(:geocoding)).to be(true)
        end
      end
    end

    describe ".configuration" do
      let(:config) { double }

      it "returns the result of Decidim.maps" do
        expect(subject.configuration).to be(config)
      end
    end

    describe ".utility" do
      let(:options) { { organization: create(:organization), locale: "en" } }

      it "returns a new instance of the configured utility" do
        expect(subject.utility(:dynamic, **options)).to be_a(Decidim::Map::Provider::DynamicMap::Osm)
        expect(subject.utility(:static, **options)).to be_a(Decidim::Map::Provider::StaticMap::Osm)
        expect(subject.utility(:geocoding, **options)).to be_a(Decidim::Map::Provider::Geocoding::Osm)
      end

      context "when the categories are unregistered" do
        it "returns nil for the previously available utilities" do
          subject.unregister_category(:dynamic)
          subject.unregister_category(:static)
          subject.unregister_category(:geocoding)

          expect(subject.utility(:dynamic, options)).to be_nil
          expect(subject.utility(:static, options)).to be_nil
          expect(subject.utility(:geocoding, options)).to be_nil
        end
      end

      context "when the provider has not been configured" do
        let(:config) { {} }

        it "returns nil for the registered utilities" do
          expect(subject.utility(:dynamic, options)).to be_nil
          expect(subject.utility(:static, options)).to be_nil
          expect(subject.utility(:geocoding, options)).to be_nil
        end
      end

      context "when the dynamic provider has been disabled" do
        let(:config) { { provider: :osm, dynamic: false } }

        it "returns a new instance for all the non-disabled utilities and nil for the dynamic utility" do
          expect(subject.utility(:dynamic, options)).to be_nil
          expect(subject.utility(:static, options)).to be_a(Decidim::Map::Provider::StaticMap::Osm)
          expect(subject.utility(:geocoding, options)).to be_a(Decidim::Map::Provider::Geocoding::Osm)
        end
      end
    end

    describe ".utility_modules" do
      it "returns all the registered modules" do
        expect(subject.utility_modules).to eq(
          dynamic: Decidim::Map::Provider::DynamicMap,
          static: Decidim::Map::Provider::StaticMap,
          geocoding: Decidim::Map::Provider::Geocoding,
          autocomplete: Decidim::Map::Provider::Autocomplete
        )
      end

      context "when the modules are unregistered" do
        it "returns an empty hash" do
          subject.unregister_category(:dynamic)
          subject.unregister_category(:static)
          subject.unregister_category(:geocoding)
          subject.unregister_category(:autocomplete)

          expect(subject.utility_modules).to eq({})
        end
      end
    end

    describe ".register_category" do
      let(:options) { { organization: create(:organization), locale: "en" } }

      before do
        subject.unregister_category(:dynamic)
        subject.unregister_category(:static)
        subject.unregister_category(:geocoding)
        subject.unregister_category(:autocomplete)
      end

      it "registers a category with the given module and defines the category method" do
        expect(subject.respond_to?(:dynamic)).to be(false)
        expect(
          subject.register_category(:dynamic, Decidim::Map::Provider::DynamicMap)
        ).to be(Decidim::Map::Provider::DynamicMap)
        expect(subject.respond_to?(:dynamic)).to be(true)
        expect(subject.dynamic(options)).to be_a(Decidim::Map::Provider::DynamicMap::Osm)
      end
    end

    describe ".unregister_category" do
      it "unregisters an existing category undefines the category method" do
        expect(subject.respond_to?(:dynamic)).to be(true)
        expect(subject.unregister_category(:dynamic)).to be(Decidim::Map::Provider::DynamicMap)
        expect(subject.respond_to?(:dynamic)).to be(false)
      end
    end

    describe ".utility_configuration" do
      let(:config) do
        {
          provider: :osm,
          api_key: "apikey",
          global_conf: "value",
          dynamic: {
            tile_layer: {
              url: "https://tiles.example.org/{z}/{x}/{y}.png?{foo}",
              foo: "bar"
            }
          },
          static: {
            url: "https://staticmap.example.org/"
          },
          geocoding: {
            provider: :alternative,
            api_key: "gc_apikey",
            host: "https://nominatim.example.org/"
          }
        }
      end

      context "when called without a category" do
        it "returns the whole configuration hash" do
          expect(subject.utility_configuration).to eq(
            dynamic: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value",
              tile_layer: {
                url: "https://tiles.example.org/{z}/{x}/{y}.png?{foo}",
                foo: "bar"
              }
            },
            static: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value",
              url: "https://staticmap.example.org/"
            },
            geocoding: {
              provider: :alternative,
              api_key: "gc_apikey",
              global_conf: "value",
              host: "https://nominatim.example.org/"
            },
            autocomplete: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value"
            }
          )
        end
      end

      context "when called with a category" do
        it "returns the configuration hash for the given category" do
          expect(subject.utility_configuration(:dynamic)).to eq(
            provider: :osm,
            api_key: "apikey",
            global_conf: "value",
            tile_layer: {
              url: "https://tiles.example.org/{z}/{x}/{y}.png?{foo}",
              foo: "bar"
            }
          )
          expect(subject.utility_configuration(:static)).to eq(
            provider: :osm,
            api_key: "apikey",
            global_conf: "value",
            url: "https://staticmap.example.org/"
          )
          expect(subject.utility_configuration(:geocoding)).to eq(
            provider: :alternative,
            api_key: "gc_apikey",
            global_conf: "value",
            host: "https://nominatim.example.org/"
          )
        end
      end

      context "when the dynamic maps are disabled" do
        let(:config) do
          {
            provider: :osm,
            api_key: "apikey",
            global_conf: "value",
            dynamic: false,
            static: {
              url: "https://staticmap.example.org/"
            },
            geocoding: {
              provider: :alternative,
              api_key: "gc_apikey",
              host: "https://nominatim.example.org/"
            },
            autocomplete: {
              url: "https://photon.example.org/api/"
            }
          }
        end

        it "returns the configuration hash without the dynamic key" do
          expect(subject.utility_configuration).to eq(
            static: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value",
              url: "https://staticmap.example.org/"
            },
            geocoding: {
              provider: :alternative,
              api_key: "gc_apikey",
              global_conf: "value",
              host: "https://nominatim.example.org/"
            },
            autocomplete: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value",
              url: "https://photon.example.org/api/"
            }
          )
        end
      end

      context "when the map configurations are not hashes" do
        let(:config) do
          {
            provider: :osm,
            api_key: "apikey",
            global_conf: "value",
            dynamic: %w(foo bar),
            static: "baz",
            geocoding: true,
            autocomplete: nil
          }
        end

        it "returns only the global configurations" do
          expect(subject.utility_configuration).to eq(
            dynamic: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value"
            },
            static: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value"
            },
            geocoding: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value"
            },
            autocomplete: {
              provider: :osm,
              api_key: "apikey",
              global_conf: "value"
            }
          )
        end
      end
    end

    describe ".utility_class" do
      it "returns the configured utility classes for each registered category of utilities" do
        expect(subject.utility_class(:dynamic)).to be(Decidim::Map::Provider::DynamicMap::Osm)
        expect(subject.utility_class(:static)).to be(Decidim::Map::Provider::StaticMap::Osm)
        expect(subject.utility_class(:geocoding)).to be(Decidim::Map::Provider::Geocoding::Osm)
        expect(subject.utility_class(:autocomplete)).to be(Decidim::Map::Provider::Autocomplete::Osm)
      end

      context "when the utility has not been registered" do
        it "returns nil" do
          expect(subject.utility_class(:foobar)).to be_nil
        end
      end

      context "when the configuration is blank" do
        let(:config) { {} }

        it "returns nil" do
          expect(subject.utility_class(:dynamic)).to be_nil
        end
      end

      context "when the configured provider class does not exist for the utility category" do
        let(:config) { { provider: :osm, dynamic: { provider: :foobar } } }

        it "returns nil" do
          expect(subject.utility_class(:dynamic)).to be_nil
          expect(subject.utility_class(:static)).to be(Decidim::Map::Provider::StaticMap::Osm)
          expect(subject.utility_class(:geocoding)).to be(Decidim::Map::Provider::Geocoding::Osm)
          expect(subject.utility_class(:autocomplete)).to be(Decidim::Map::Provider::Autocomplete::Osm)
        end
      end
    end
  end
end
