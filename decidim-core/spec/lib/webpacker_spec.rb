# frozen_string_literal: true

require "spec_helper"
require "decidim/webpacker"

module Decidim
  describe Webpacker do
    before do
      # Use a local configuration object for easier testing
      allow(subject).to receive(:configuration).and_return(
        Decidim::Webpacker::Configuration.new
      )
    end

    describe ".configuration" do
      it "returns the configuration object" do
        expect(subject.configuration).to be_a(Decidim::Webpacker::Configuration)
      end
    end

    describe ".register_path" do
      after do
        described_class.configuration.additional_paths.slice!(
          0,
          described_class.configuration.additional_paths.length
        )
      end

      it "registers additional path for webpacker" do
        described_class.register_path("test")

        expect(described_class.configuration.additional_paths).to eq(%w(test))
      end

      context "with prepend" do
        it "adds the additional path to the beginning" do
          described_class.register_path("test")
          described_class.register_path("test2", prepend: true)

          expect(described_class.configuration.additional_paths).to eq(%w(test2 test))
        end
      end
    end

    describe ".register_entrypoints" do
      after do
        described_class.configuration.entrypoints.clear
      end

      it "registers the defined entrypoints" do
        described_class.register_entrypoints(
          test_entry: "entrypath",
          other_entry: "otherpath"
        )

        expect(described_class.configuration.entrypoints).to eq(
          "test_entry" => "entrypath",
          "other_entry" => "otherpath"
        )
      end
    end

    describe ".register_stylesheet_import" do
      after do
        described_class.configuration.stylesheet_imports.clear
      end

      it "registers the defined entrypoints for the 'app' group by default" do
        described_class.register_stylesheet_import("stylesheets/decidim/test")

        expect(described_class.configuration.stylesheet_imports["imports"]["app"]).to eq(
          %w(stylesheets/decidim/test)
        )
      end

      context "with a group provided" do
        it "registers the defined entrypoints for the defined group" do
          described_class.register_stylesheet_import("stylesheets/decidim/test", group: :admin)

          expect(described_class.configuration.stylesheet_imports["imports"]["admin"]).to eq(
            %w(stylesheets/decidim/test)
          )
        end
      end

      context "with a type provided" do
        it "registers the defined entrypoints for the defined type and 'app' group by default" do
          described_class.register_stylesheet_import("stylesheets/decidim/test", type: :settings)

          expect(described_class.configuration.stylesheet_imports["settings"]["app"]).to eq(
            %w(stylesheets/decidim/test)
          )
        end
      end

      context "with a type and a group provided" do
        it "registers the defined entrypoints for the defined type and group" do
          described_class.register_stylesheet_import("stylesheets/decidim/test", type: :settings, group: :admin)

          expect(described_class.configuration.stylesheet_imports["settings"]["admin"]).to eq(
            %w(stylesheets/decidim/test)
          )
        end
      end
    end
  end
end
