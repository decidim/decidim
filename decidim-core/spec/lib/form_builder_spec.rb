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

        attribute :slug, String
        translatable_attribute :name, String
        translatable_attribute :short_description, String
      end.new
    end

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
    end

    let(:builder) { FormBuilder.new(:resource, resource, helper, {}) }

    context "#editor" do
      context "using default toolbar" do
        let(:output) do
          builder.editor :slug
        end
        let(:parsed) { Nokogiri::HTML(output) }

        it "renders a hidden field and a container for the editor" do
          expect(parsed.css(".editor input[type='hidden'][name='resource[slug]']").first).to be
          expect(parsed.css(".editor label[for='resource_slug']").first).to be
          expect(parsed.css(".editor .editor-container[data-toolbar='basic']").first).to be
        end
      end

      context "using full toolbar" do
        let(:output) do
          builder.editor :slug, toolbar: :full
        end
        let(:parsed) { Nokogiri::HTML(output) }

        it "renders a hidden field and a container for the editor" do
          expect(parsed.css(".editor input[type='hidden'][name='resource[slug]']").first).to be
          expect(parsed.css(".editor label[for='resource_slug']").first).to be
          expect(parsed.css(".editor .editor-container[data-toolbar='full']").first).to be
        end
      end
    end

    context "#translated" do
      context "a text area field" do
        let(:output) do
          builder.translated :text_area, :name
        end
        let(:parsed) { Nokogiri::HTML(output) }

        it "renders a tabbed input for each field" do
          expect(parsed.css("label[for='resource_name']").first).to be

          expect(parsed.css("li.tabs-title a").count).to eq 3

          expect(parsed.css(".tabs-panel textarea[name='resource[name_ca]']").first).to be
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

      context "an editor field" do
        let(:output) do
          builder.translated :editor, :short_description
        end
        let(:parsed) { Nokogiri::HTML(output) }

        it "renders a tabbed input hidden for each field and a container for the editor" do
          expect(parsed.css("label[for='resource_short_description']").first).to be

          expect(parsed.css("li.tabs-title a").count).to eq 3

          expect(parsed.css(".editor label[for='resource_short_description_en']").first).to be_nil

          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_ca]']").first).to be
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_en]']").first).to be
          expect(parsed.css(".tabs-panel .editor input[type='hidden'][name='resource[short_description_de__CH]']").first).to be

          expect(parsed.css(".tabs-panel .editor .editor-container").count).to eq 3
        end

        context "with a single locale" do
          let(:available_locales) { %w(en) }

          it "renders a single input and a container for the editor" do
            expect(parsed.css(".editor input[type='hidden'][name='resource[short_description_en]']").first).to be
            expect(parsed.css(".editor label[for='resource_short_description_en']").first).to be
            expect(parsed.css(".editor .editor-container").first).to be
          end
        end
      end
    end
  end
end
