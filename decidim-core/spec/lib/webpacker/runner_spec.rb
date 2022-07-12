# frozen_string_literal: true

require "spec_helper"
require "gem_overrides/webpacker/runner"

module Webpacker
  describe Runner do
    subject { described_class.new(argv) }

    let(:argv) { [] }
    let(:app_path) { Rails.application.root.to_s }

    describe ".initialize" do
      let(:runtime_config_path) do
        Rails.application.root.join("tmp/webpacker_runtime.yml")
      end
      let(:runtime_config) { YAML.load_file(runtime_config_path) }

      it "generates the runtime configuration" do
        create_instance

        expect(File.exist?(runtime_config_path)).to be(true)
      end

      it "adds the core additional paths and entrypoints to the runtime configuration" do
        create_instance

        core_gem = Bundler.load.specs.find { |spec| spec.name == "decidim-core" }
        core_path = core_gem.full_gem_path

        expect(runtime_config["default"]["additional_paths"]).to include("node_modules")
        expect(runtime_config["default"]["additional_paths"]).to include("app/packs")
        expect(runtime_config["default"]["additional_paths"]).to include("#{core_path}/app/packs")
        expect(runtime_config["default"]["entrypoints"]).to include(
          "decidim_core" => "#{core_path}/app/packs/entrypoints/decidim_core.js",
          "decidim_sw" => "#{core_path}/app/packs/entrypoints/decidim_sw.js",
          "decidim_conference_diploma" => "#{core_path}/app/packs/entrypoints/decidim_conference_diploma.js",
          "decidim_email" => "#{core_path}/app/packs/entrypoints/decidim_email.js",
          "decidim_map" => "#{core_path}/app/packs/entrypoints/decidim_map.js",
          "decidim_geocoding_provider_photon" => "#{core_path}/app/packs/entrypoints/decidim_geocoding_provider_photon.js",
          "decidim_geocoding_provider_here" => "#{core_path}/app/packs/entrypoints/decidim_geocoding_provider_here.js",
          "decidim_map_provider_default" => "#{core_path}/app/packs/entrypoints/decidim_map_provider_default.js",
          "decidim_map_provider_here" => "#{core_path}/app/packs/entrypoints/decidim_map_provider_here.js",
          "decidim_widget" => "#{core_path}/app/packs/entrypoints/decidim_widget.js"
        )
        expect(runtime_config["default"]["stylesheet_imports"].keys).to include("imports")
        expect(runtime_config["default"]["stylesheet_imports"]["imports"].keys).to include("app")
        expect(runtime_config["default"]["stylesheet_imports"]["imports"]["app"]).to include(
          "stylesheets/decidim/accountability/accountability",
          "stylesheets/decidim/budgets/budgets",
          "stylesheets/decidim/proposals/proposals",
          "stylesheets/decidim/surveys/surveys",
          "stylesheets/decidim/conferences/conferences",
          "stylesheets/decidim/consultations/consultations",
          "stylesheets/decidim/elections/elections",
          "stylesheets/decidim/votings/votings",
          "stylesheets/decidim/initiatives/initiatives"
        )
      end

      it "calls assets generate runtime configuration for Tailwind" do
        expect(Decidim::Assets::Tailwind).to receive(:write_runtime_configuration)
        create_instance
      end
    end

    private

    def create_instance
      allow(Dir).to receive(:pwd).and_return(app_path)

      subject
    end
  end
end
