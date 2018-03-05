# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateFeature do
    subject { described_class.new(manifest, form, participatory_process) }

    let(:manifest) { Decidim.find_feature_manifest(:dummy) }
    let(:form) do
      instance_double(
        FeatureForm,
        name: {
          en: "My feature",
          ca: "La meva funcionalitat",
          es: "Mi funcionalidad"
        },
        invalid?: !valid,
        valid?: valid,
        current_user: current_user,
        weight: 2,
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

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:step) { participatory_process.steps.first }
    let(:current_user) { create :user, organization: participatory_process.organization }

    describe "when valid" do
      let(:valid) { true }

      it "broadcasts :ok and creates the feature" do
        expect do
          subject.call
        end.to broadcast(:ok)

        expect(participatory_process.features).not_to be_empty

        feature = participatory_process.features.first
        expect(feature.settings.dummy_global_attribute_1).to eq(true)
        expect(feature.settings.dummy_global_attribute_2).to eq(false)
        expect(feature.weight).to eq 2

        step_settings = feature.step_settings[step.id.to_s]
        expect(step_settings.dummy_step_attribute_1).to eq(true)
        expect(step_settings.dummy_step_attribute_2).to eq(false)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::Feature, current_user, a_kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "create"
      end

      it "fires the hooks" do
        results = {}

        manifest.on(:create) do |feature|
          results[:feature] = feature
        end

        subject.call

        feature = results[:feature]
        expect(feature.name["en"]).to eq("My feature")
        expect(feature).to be_persisted
      end
    end

    describe "when invalid" do
      let(:valid) { false }

      it "creates the feature" do
        expect do
          subject.call
        end.to broadcast(:invalid)

        expect(participatory_process.features).to be_empty
      end
    end
  end
end
