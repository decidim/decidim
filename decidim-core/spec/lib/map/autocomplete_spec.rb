# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    describe Autocomplete do
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
        config = CGI.escapeHTML(
          { url: "/photon_api" }.to_json
        )
        expect(form_markup).to include(%(
          <input autocomplete="off" data-decidim-geocoding="#{config}" type="text" name="test[address]" id="test_address" />
        ).strip)
      end
    end
  end
end
