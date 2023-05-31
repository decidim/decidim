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
        include Decidim::AttributeObject::Model
        include TranslatableAttributes
      end
    end

    let(:available_locales) { %w(en ca pt-BR) }

    let(:model) { klass.new }

    before do
      allow(Decidim).to receive(:available_locales).and_return available_locales
    end

    describe "#translatable_attribute" do
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

      context "when the stored value is a string" do
        before do
          allow(model).to receive(:name).and_return("Hello")
        end

        it "returns the stored value for the locale specific getters" do
          expect(model.name_en).to eq("Hello")
          expect(model.name_ca).to eq("Hello")
          expect(model.name_pt__BR).to eq("Hello")
        end
      end
    end
  end
end
