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
  end
end
