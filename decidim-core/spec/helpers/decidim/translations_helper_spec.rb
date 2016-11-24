# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe TranslationsHelper do
    describe "#translated_attribute" do
      it "translates the attribute against the current locale" do
        attribute = { "ca" => "Hola", "zh-CN" => "你好" }
        I18n.locale = :'zh-CN'

        expect(helper.translated_attribute(attribute)).to eq("你好")
      end
    end

    describe "#multi_translation" do
      context "when given a key and a list of locales" do
        it "returns a hash scoped to that list of locales" do
          result = TranslationsHelper.multi_translation("booleans.true", [:en, :ca])
          expect(result.keys.length).to eq(2)
          expect(result).to include(en: "Yes", ca: "Sí")
        end
      end

      context "when given only a key" do
        it "returns a hash scoped to the available list of locales" do
          result = TranslationsHelper.multi_translation("booleans.true")
          expect(result.keys.length).to eq(3)
          expect(result).to include(en: "Yes", ca: "Sí", es: "Sí")
        end
      end
    end
  end
end
