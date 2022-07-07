# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

module Decidim
  describe Admin::FormBuilder do
    subject { Nokogiri::HTML(output) }

    let(:helper) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
    let(:available_locales) { %w(ca en de-CH) }

    let(:resource) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Decidim::AttributeObject::Model

        attribute :category_id, Integer
      end.new
    end

    let(:builder) { Admin::FormBuilder.new(:resource, resource, helper, {}) }

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
      allow(I18n.config).to receive(:enforce_available_locales).and_return(false)
    end

    describe "#autocomplete_select" do
      let(:category) { nil }
      let(:selected) { category }
      let(:options) { {} }
      let(:prompt_options) { { url: "/some/url", text: "Pick a category", change_url: "/some/other/url" } }
      let(:output) { builder.autocomplete_select(:category_id, selected, options, prompt_options) }
      let(:autocomplete_data) { JSON.parse(subject.xpath("//div[@data-autocomplete]/@data-autocomplete").first.value) }

      it "sets the plugin data attribute" do
        expect(subject.css("div[data-plugin='autocomplete']")).not_to be_empty
      end

      it "sets the autocomplete data attribute" do
        expect(subject.css("div[data-autocomplete]")).not_to be_empty
      end

      it "sets the autocomplete_for data attribute" do
        expect(subject.css("div[data-autocomplete-for='category_id']")).not_to be_empty
      end

      context "without selected value" do
        it "renders autocomplete data attribute correctly" do
          expect(autocomplete_data).to eq(
            "changeURL" => "/some/other/url",
            "name" => "resource[category_id]",
            "noResultsText" => t("autocomplete.no_results", scope: "decidim.admin"),
            "options" => [],
            "placeholder" => nil,
            "searchPromptText" => t("autocomplete.search_prompt", scope: "decidim.admin"),
            "searchURL" => "/some/url",
            "selected" => ""
          )
        end
      end

      context "with selected value" do
        let!(:component) { create(:component) }
        let!(:category) { create(:category, name: { "en" => "Nice category" }, participatory_space: component.participatory_space) }
        let(:output) do
          builder.autocomplete_select(:category_id, selected, options, prompt_options) do |category|
            { value: category.id, label: category.name["en"] }
          end
        end

        it "renders autocomplete data attribute correctly" do
          expect(autocomplete_data["options"]).to eq [{ "value" => category.id, "label" => "Nice category" }]
          expect(autocomplete_data["selected"]).to eq category.id
        end
      end

      context "with custom class" do
        let(:options) { { class: "autocomplete-field--results-inline" } }

        it "sets the class attribute" do
          expect(subject.css(".autocomplete-field--results-inline")).not_to be_empty
        end
      end

      context "with custom name" do
        let(:options) { { name: "custom[name]" } }

        it "configures the select with the custom name" do
          expect(autocomplete_data["name"]).to eq "custom[name]"
        end
      end

      context "with custom label" do
        let(:options) { { label: "custom label" } }

        it "outputs a custom label" do
          expect(subject.xpath("//label").first.text).to eq "custom label"
        end
      end

      context "with label disabled" do
        let(:options) { { label: false } }

        it "doesn't output the label" do
          expect(subject.xpath("//label")).to be_empty
        end
      end
    end
  end
end
