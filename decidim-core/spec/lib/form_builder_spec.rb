# frozen_string_literal: true
require "spec_helper"
require "nokogiri"

module Decidim
  describe FormBuilder do
    let(:helper) { Class.new(ActionView::Base).new }
    let(:available_locales) { %w(ca en de-CH) }

    let(:resource) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Virtus.model
        include TranslatableAttributes

        translatable_attribute :name, String
      end.new
    end

    before do
      allow(I18n).to receive(:available_locales).and_return available_locales
    end

    let(:builder) { FormBuilder.new(:resource, resource, helper, {}) }

    let(:output) do
      builder.translated :text_area, :name
    end
    let(:parsed) { Nokogiri::HTML(output) }

    it "renders a tabbed input for each field" do
      expect(parsed.css("label[for='resource_name']").first).to be

      expect(parsed.css("li.tabs-title a").count).to eq 3

      expect(parsed.css(".tabs-panel textarea[name='resource[name_en]']").first).to be
      expect(parsed.css(".tabs-panel textarea[name='resource[name_en]']").first).to be
      expect(parsed.css(".tabs-panel textarea[name='resource[name_de__CH]']").first).to be
    end

    context "with a single locale" do
      let(:available_locales) { %w(en) }

      it "renders a single input" do
        expect(parsed.css("label[for='resource_name_en']").first).to be
        expect(parsed.css("textarea[name='resource[name_en]']").first).to be
      end
    end
  end
end
