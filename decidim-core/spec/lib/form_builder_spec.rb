# frozen_string_literal: true
require "spec_helper"
require "nokogiri"

module Decidim
  describe FormBuilder do
    let(:helper) { Class.new(ActionView::Base).new }

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
      allow(I18n).to receive(:available_locales).and_return %w(ca en de-CH)
    end

    let(:builder) { FormBuilder.new(:resource, resource, helper, {}) }

    let(:output) do
      builder.translated :text_area, :name
    end

    it "renders an input for each field" do
      parsed = Nokogiri::HTML(output)

      expect(parsed.css("textarea[name='resource[name_en]']").first).to be
      expect(parsed.css("textarea[name='resource[name_en]']").first).to be
      expect(parsed.css("textarea[name='resource[name_de__CH]']").first).to be

      expect(parsed.css("label[for='resource_name_en']").first).to be
      expect(parsed.css("label[for='resource_name_ca']").first).to be
      expect(parsed.css("label[for='resource_name_de__CH']").first).to be
    end
  end
end
