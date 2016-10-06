# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe TranslatableAttributes do
    let(:klass) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Virtus.model
        include TranslatableAttributes
      end
    end

    let(:available_locales) { %w(en ca) }

    before do
      allow(I18n).to receive(:available_locales).and_return available_locales
    end

    let(:model) { klass.new }

    describe "#translatable_attribute do" do
      before do
        klass.class_eval do
          translatable_attribute :name, String
        end
      end

      it "creates a getter for each locale" do
        model.name = { "en" => "Hello", "ca" => "Hola" }

        expect(model.name_en).to eq("Hello")
        expect(model.name_ca).to eq("Hola")
      end

      it "creates a setter for each locale" do
        model.name_en = "Hello"
        model.name_ca = "Hola"

        expect(model.name).to include("en" => "Hello")
        expect(model.name).to include("ca" => "Hola")
      end

      it "coerces values" do
        model.name_en = 1
        expect(model.name_en).to eq("1")
      end
    end

    describe "#translatable_validates" do
      before do
        klass.class_eval do
          translatable_attribute :name, String
          translatable_attribute :summary, String
          translatable_attribute :description, String

          translatable_validates :name, :summary, presence: true
          translatable_validates :description, length: { maximum: 10 }
        end
      end

      it "validates the presence in each locale" do
        model.name_en = "Hola"
        model.description_ca = "Una descripció mooooolt llarga"

        expect(model.valid?).to eq(false)

        expect(model.errors).to include(:name_ca, :summary_en, :summary_ca, :description_ca)
        expect(model.errors).to_not include(:name_en, :description_en)
      end
    end
  end
end
