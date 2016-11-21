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

    let(:available_locales) { %w(en ca pt-BR) }

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
    end

    let(:model) { klass.new }

    describe "#translatable_attribute do" do
      before do
        klass.class_eval do
          translatable_attribute :name, String
        end
      end

      it "creates a getter for each locale" do
        model.name = { "en" => "Hello", "pt-BR" => "Olá", "ca" => "Hola" }

        expect(model.name_en).to eq("Hello")
        expect(model.name_ca).to eq("Hola")
        expect(model.name_pt__BR).to eq("Olá")
      end

      it "creates a setter for each locale" do
        model.name_en = "Hello"
        model.name_ca = "Hola"
        model.name_pt__BR = "Olá"

        expect(model.name).to include("en" => "Hello")
        expect(model.name).to include("ca" => "Hola")
        expect(model.name).to include("pt-BR" => "Olá")
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
        model.summary_pt__BR = "Um resumo"

        expect(model.valid?).to eq(false)

        expect(model.errors).to include(
          :name_ca,
          :name_pt__BR,
          :summary_en,
          :summary_ca,
        )
        expect(model.errors).to_not include(:name_en, :description_en, :description_pt__BR)
      end
    end
  end
end
