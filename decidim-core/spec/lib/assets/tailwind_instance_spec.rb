# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assets
    module Tailwind
      describe Instance do
        describe ".write_runtime_configuration" do
          let(:runtime_config_path) do
            Rails.application.root.join("tailwind.config.js")
          end

          before do
            subject.write_runtime_configuration
          end

          it "generates the runtime configuration" do
            expect(File.exist?(runtime_config_path)).to be(true)
          end

          it "adds decidim gems with the full path" do
            decidim_core_gem_path = Bundler.load.specs.find { |spec| spec.name == "decidim-core" }.full_gem_path

            configuration = File.read(runtime_config_path)
            expect(configuration).to include(decidim_core_gem_path)
          end
        end
      end
    end
  end
end
