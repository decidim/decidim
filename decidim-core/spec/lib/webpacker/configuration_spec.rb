# frozen_string_literal: true

require "spec_helper"
require "decidim/webpacker/shakapacker"

module Decidim
  module Webpacker
    describe Configuration do
      before do
        # When the asset configurations are called through Decidim::Webpacker,
        # return always the subject being tested.
        allow(Decidim::Webpacker).to receive(:configuration).and_return(subject)
      end

      describe "#configuration_file" do
        let(:runtime_config_path) do
          Rails.application.root.join("tmp/webpacker_runtime.yml")
        end
        let(:runtime_config) { YAML.load_file(runtime_config_path, aliases: true) }
        let(:core_path) do
          core_gem = Bundler.load.specs.find { |spec| spec.name == "decidim-core" }
          core_gem.full_gem_path
        end
        let!(:config_file) { subject.configuration_file }

        it "returns the runtime configuration path" do
          expect(config_file).to eq(runtime_config_path.to_s)
        end

        it "adds the core additional paths to the webpacker runtime configuration" do
          expect(runtime_config["default"]["additional_paths"]).to include("node_modules")
          expect(runtime_config["default"]["additional_paths"]).to include("app/packs")
          expect(runtime_config["default"]["additional_paths"]).to include("#{core_path}/app/packs")
        end

        it "adds the core entrypoints to the webpacker runtime configuration" do
          expect(runtime_config["default"]["entrypoints"]).to include(
            "decidim_core" => "#{core_path}/app/packs/entrypoints/decidim_core.js",
            "decidim_sw" => "#{core_path}/app/packs/entrypoints/decidim_sw.js",
            "decidim_conference_diploma" => "#{core_path}/app/packs/entrypoints/decidim_conference_diploma.js",
            "decidim_email" => "#{core_path}/app/packs/entrypoints/decidim_email.js",
            "decidim_map" => "#{core_path}/app/packs/entrypoints/decidim_map.js",
            "decidim_geocoding_provider_photon" => "#{core_path}/app/packs/entrypoints/decidim_geocoding_provider_photon.js",
            "decidim_geocoding_provider_here" => "#{core_path}/app/packs/entrypoints/decidim_geocoding_provider_here.js",
            "decidim_map_provider_default" => "#{core_path}/app/packs/entrypoints/decidim_map_provider_default.js",
            "decidim_map_provider_here" => "#{core_path}/app/packs/entrypoints/decidim_map_provider_here.js"
          )
        end
      end
    end
  end
end
