# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateFeature do
    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:step) { participatory_process.steps.first }
    let!(:feature) { create(:feature, participatory_space: participatory_process) }
    let(:manifest) { feature.manifest }

    let(:form) do
      instance_double(
        FeatureForm,
        name: {
          en: "My feature",
          ca: "La meva funcionalitat",
          es: "Mi funcionalidad"
        },
        weight: 3,
        invalid?: !valid,
        valid?: valid,
        settings: {
          dummy_global_attribute_1: true,
          dummy_global_attribute_2: false
        },
        default_step_settings: {
          step.id.to_s => {
            dummy_step_attribute_1: true,
            dummy_step_attribute_2: false
          }
        },
        step_settings: {
          step.id.to_s => {
            dummy_step_attribute_1: true,
            dummy_step_attribute_2: false
          }
        }
      )
    end

    describe "when valid" do
      let(:valid) { true }

      it "broadcasts :ok and updates the feature" do
        expect do
          described_class.call(form, feature)
        end.to broadcast(:ok)

        expect(feature["name"]["en"]).to eq("My feature")
        expect(feature.weight).to eq(3)
        expect(feature.settings.dummy_global_attribute_1).to eq(true)
        expect(feature.settings.dummy_global_attribute_2).to eq(false)

        step_settings = feature.step_settings[step.id.to_s]
        expect(step_settings.dummy_step_attribute_1).to eq(true)
        expect(step_settings.dummy_step_attribute_2).to eq(false)
      end

      it "fires the hooks" do
        results = {}

        manifest.on(:update) do |feature|
          results[:feature] = feature
        end

        described_class.call(form, feature)

        feature = results[:feature]
        expect(feature.name["en"]).to eq("My feature")
        expect(feature).to be_persisted
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "creates the feature" do
        expect do
          described_class.call(form, feature)
        end.to broadcast(:invalid)

        feature.reload
        expect(feature.name["en"]).not_to eq("My feature")
      end
    end
  end
end
