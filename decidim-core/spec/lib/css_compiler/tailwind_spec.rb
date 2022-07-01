# frozen_string_literal: true

require "spec_helper"
require "decidim/css_compiler/tailwind"

module Decidim
  module CssCompiler
    describe Tailwind do
      let(:app_path) { Rails.application.root.to_s }

      describe ".write_runtime_configuration" do
        let(:runtime_config_path) do
          Rails.application.root.join("tailwind.config.js")
        end

        it "generates the runtime configuration" do
          create_instance

          expect(File.exist?(runtime_config_path)).to be(true)
        end

        it "adds decidim gems" do
          create_instance

          configuration = File.read(runtime_config_path)
          expect(configuration).to include("decidim-core")
        end
      end

      private

      def create_instance
        allow(Dir).to receive(:pwd).and_return(app_path)

        subject
      end
    end
  end
end
