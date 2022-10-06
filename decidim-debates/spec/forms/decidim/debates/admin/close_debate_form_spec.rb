# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::CloseDebateForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "debates" }
  let(:context) do
    {
      current_organization: organization
    }
  end
  let(:debate) { create :debate, :official, component: current_component }
  let(:conclusions) { Decidim::Faker::Localized.localized { "We found a conlcusion." } }
  let(:attributes) do
    {
      id: debate.id,
      conclusions:
    }
  end

  context "when the conclusions exceeds the permited length" do
    let(:conclusions) { Decidim::Faker::Localized.localized { "c" * 10_001 } }

    it { is_expected.to be_invalid }

    context "with carriage return characters that cause it to exceed" do
      let(:conclusions) { Decidim::Faker::Localized.localized { "#{"c" * 5000}\r\n#{"c" * 4999}" } }

      it { is_expected.to be_valid }
    end
  end
end
