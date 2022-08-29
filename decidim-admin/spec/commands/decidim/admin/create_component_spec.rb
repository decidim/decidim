# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateComponent do
    subject { described_class.new(form) }

    let(:manifest) { Decidim.find_component_manifest(:dummy) }
    let(:form) do
      instance_double(
        ComponentForm,
        name: {
          en: "My component",
          ca: "La meva funcionalitat",
          es: "Mi funcionalidad"
        },
        invalid?: !valid,
        valid?: valid,
        current_user:,
        weight: 2,
        manifest:,
        participatory_space: participatory_process,
        settings: {
          dummy_global_attribute1: true,
          dummy_global_attribute2: false
        },
        default_step_settings: {
          step.id.to_s => {
            dummy_step_attribute1: true,
            dummy_step_attribute2: false
          }
        },
        step_settings: {
          step.id.to_s => {
            dummy_step_attribute1: true,
            dummy_step_attribute2: false
          }
        }
      )
    end

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:step) { participatory_process.steps.first }
    let(:current_user) { create :user, organization: participatory_process.organization }

    describe "when valid" do
      let(:valid) { true }

      it "broadcasts :ok and creates the component" do
        expect do
          subject.call
        end.to broadcast(:ok)

        expect(participatory_process.components).not_to be_empty

        component = participatory_process.components.first
        expect(component.settings.dummy_global_attribute1).to be(true)
        expect(component.settings.dummy_global_attribute2).to be(false)
        expect(component.weight).to eq 2

        step_settings = component.step_settings[step.id.to_s]
        expect(step_settings.dummy_step_attribute1).to be(true)
        expect(step_settings.dummy_step_attribute2).to be(false)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::Component, current_user, a_kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "create"
      end

      it "fires the hooks" do
        results = {}

        manifest.on(:create) do |component|
          results[:component] = component
        end

        subject.call

        component = results[:component]
        expect(component.name["en"]).to eq("My component")
        expect(component).to be_persisted
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "broadcasts invalid and does not create the component" do
        expect do
          subject.call
        end.to broadcast(:invalid)

        expect(participatory_process.components).to be_empty
      end
    end
  end
end
