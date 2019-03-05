# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe JsonbAttributes do
    let(:klass) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model
        include Virtus.model
        include JsonbAttributes
      end
    end

    let(:model) { klass.new }

    describe "#jsonb_attribute do" do
      before do
        klass.class_eval do
          jsonb_attribute :settings, [
            [:custom_setting, String],
            [:another_setting, String]
          ]
        end
      end

      it "creates a getter for each attribute" do
        model.settings = { custom_setting: "demo", another_setting: "random" }

        expect(model.custom_setting).to eq("demo")
        expect(model.another_setting).to eq("random")
      end

      it "creates a setter for each attribute" do
        model.custom_setting = "new setting"
        model.another_setting = "random setting"

        expect(model.settings).to include(custom_setting: "new setting")
        expect(model.settings).to include(another_setting: "random setting")
      end

      it "coerces values" do
        model.custom_setting = 1
        expect(model.custom_setting).to eq("1")
      end
    end
  end
end
