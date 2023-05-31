# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

module Decidim
  describe Admin::SearchFormBuilder do
    subject { Nokogiri::HTML(output) }

    let(:body) { subject.at("body").inner_html }
    let(:helper) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

    let(:resource) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Decidim::AttributeObject::Model

        attribute :category_id, Integer

        def translate(attribute, options = {})
          return "Test #{attribute}" if options[:test] == true

          "Custom #{attribute}"
        end
      end.new
    end

    let(:builder) { described_class.new(:resource, resource, helper, {}) }

    describe "#text_field" do
      let(:output) { builder.text_field(:category_id, options) }
      let(:options) { {} }

      it "correctly translates an object attribute for objects that respond to translate" do
        expect(body).to include(%(<label for="resource_category_id">Custom category_id<input))
      end

      context "with :i18n key provided in the label options" do
        let(:options) { { label_options: { i18n: { test: true } } } }

        it "provides the :i18n options for the translate method" do
          expect(body).to include(%(<label for="resource_category_id">Test category_id<input))
        end
      end

      context "with custom text provided as the label" do
        let(:options) { { label: "My label" } }

        it "shows the custom text as the label" do
          expect(body).to include(%(<label for="resource_category_id">My label<input))
        end
      end
    end
  end
end
