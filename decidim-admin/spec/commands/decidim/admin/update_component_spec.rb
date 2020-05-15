# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateComponent do
    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:step) { participatory_process.steps.first }
    let!(:component) { create(:component, :with_one_step, participatory_space: participatory_process) }
    let(:manifest) { component.manifest }

    let(:form) do
      instance_double(
        ComponentForm,
        name: {
          en: "My component",
          ca: "La meva funcionalitat",
          es: "Mi funcionalidad"
        },
        weight: 3,
        invalid?: !valid,
        valid?: valid,
        settings: {
          dummy_global_attribute_1: true,
          dummy_global_attribute_2: false,
          readonly_attribute: false
        },
        default_step_settings: {
          step.id.to_s => {
            dummy_step_attribute_1: true,
            dummy_step_attribute_2: false,
            readonly_step_attribute: false
          }
        },
        step_settings: {
          step.id.to_s => {
            dummy_step_attribute_1: true,
            dummy_step_attribute_2: false,
            readonly_step_attribute: false
          }
        }
      )
    end

    describe "when valid" do
      let(:valid) { true }

      it "broadcasts :ok and updates the component (except the readonly attribute)" do
        expect do
          described_class.call(form, component)
        end.to broadcast(:ok)

        expect(component["name"]["en"]).to eq("My component")
        expect(component.weight).to eq(3)
        expect(component.settings.dummy_global_attribute_1).to eq(true)
        expect(component.settings.dummy_global_attribute_2).to eq(false)
        expect(component.settings.readonly_attribute).to eq(true)

        step_settings = component.step_settings[step.id.to_s]
        expect(step_settings.dummy_step_attribute_1).to eq(true)
        expect(step_settings.dummy_step_attribute_2).to eq(false)
        expect(step_settings.readonly_step_attribute).to eq(true)
      end

      it "fires the hooks" do
        results = {}

        manifest.on(:update) do |component|
          results[:component] = component
        end

        described_class.call(form, component)

        component = results[:component]
        expect(component.name["en"]).to eq("My component")
        expect(component).to be_persisted
      end

      it "broadcasts the previous and current settings" do
        expect do
          described_class.call(form, component)
        end.to broadcast(
          :ok,
          true,
          hash_including(
            "global" => kind_of(Hash),
            "default_step" => kind_of(Hash)
          ),
          hash_including(
            "global" => kind_of(Hash),
            "default_step" => kind_of(Hash),
            "steps" => kind_of(Hash)
          )
        )
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "does not update the component" do
        expect do
          described_class.call(form, component)
        end.to broadcast(:invalid)

        component.reload
        expect(component.name["en"]).not_to eq("My component")
      end
    end
  end
end
