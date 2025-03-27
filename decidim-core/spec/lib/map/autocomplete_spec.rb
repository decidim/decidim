# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/shared_examples/form_builder_examples"

module Decidim
  module Map
    describe Autocomplete, configures_map: true do
      include_context "with map utility" do
        subject { utility }
      end

      describe "#create_builder" do
        let(:template) { double }
        let(:options) { {} }

        it "creates a new builder instance" do
          expect(Decidim::Map::Autocomplete::Builder).to receive(:new).with(
            template,
            {}
          ).and_call_original

          builder = subject.create_builder(template, options)
          expect(builder).to be_a(Decidim::Map::Autocomplete::Builder)
        end
      end

      describe "#builder_class" do
        it "returns the Builder class under the given module" do
          expect(utility.builder_class).to be(Decidim::Map::Autocomplete::Builder)
        end
      end

      describe "#builder_options" do
        it "prepares and returns the correct builder options" do
          expect(utility.builder_options).to eq({})
        end
      end
    end

    describe Autocomplete::FormBuilder do
      include_context "with frontend map builder"

      let(:form_markup) do
        template.form_for :test, url: "/test" do |form|
          form.geocoding_field(:address)
        end
      end

      before do
        allow(template).to receive(:current_organization).and_return(organization)
      end

      it "creates the geocoding field markup" do
        config = escaped_html(
          { url: "#{Decidim::Dev::Test::MapServer.host}/photon_api" }.to_json
        )
        expect(form_markup).to include(%(
      <input autocomplete="off" data-decidim-geocoding="#{config}" type="text" name="test[address]" id="test_address" />
    ).strip)
      end

      context "when object responds to latitude and longitude" do
        let(:object) do
          double(
            latitude: nil,
            longitude: nil
          )
        end

        let(:form_markup) do
          template.form_for :test, url: "/test" do |form|
            allow(form).to receive(:object).and_return(object)
            form.geocoding_field(:address)
          end
        end

        it "does not add empty values" do
          expect(form_markup).not_to include(%(data-coordinates=).strip)
        end
      end

      context "when a help text is defined" do
        let(:field) { "input" }
        let(:help_text_text) { "This is the help text" }
        let(:output) do
          template.form_for :test, url: "/test" do |form|
            form.geocoding_field(:address, help_text: help_text_text)
          end
        end
        let(:parsed) { Nokogiri::HTML(output) }

        it_behaves_like "having a help text"
      end
    end
  end
end
