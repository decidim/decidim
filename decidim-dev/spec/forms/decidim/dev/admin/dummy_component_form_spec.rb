# frozen_string_literal: true

require "spec_helper"

describe Decidim::Dev::Admin::DummyComponentForm do
  let(:form) { described_class.from_params(params).with_context(context) }
  let(:organization) { build(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:manifest) { Decidim.find_component_manifest("dummy") }
  let(:params) do
    {
      name: { en: "Dummy" },
      manifest:,
      participatory_space:,
      settings: Decidim::Component.build_settings(manifest, :global, base_global_settings.merge(global_settings), organization),
      step_settings: participatory_space.steps.to_h do |step|
        [step.id.to_s, Decidim::Component.build_settings(manifest, :step, base_step_settings.merge(step_settings), organization)]
      end
    }
  end
  let(:base_global_settings) do
    {
      dummy_global_translatable_text: { en: "Text" }
    }
  end
  let(:global_settings) { {} }
  let(:base_step_settings) do
    {
      dummy_step_translatable_text: { en: "Text" }
    }
  end
  let(:step_settings) { {} }
  let(:context) do
    {
      current_organization: organization
    }
  end

  describe "valid?" do
    subject { form.valid? }

    context "with valid error_honeypot_number" do
      let(:global_settings) { { error_honeypot_number: "0" } }

      it { is_expected.to be(true) }
    end

    context "with invalid error_honeypot_number" do
      let(:global_settings) { { error_honeypot_number: "1" } }

      it { is_expected.to be(false) }
    end
  end
end
