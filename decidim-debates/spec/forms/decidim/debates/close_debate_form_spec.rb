# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CloseDebateForm do
  subject(:form) { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "debates" }
  let(:user) { create :user, organization: }
  let(:context) do
    {
      current_user: user
    }
  end
  let(:debate) { create :debate, :participant_author, component: current_component, author: user }
  let(:conclusions) { "We found a conlcusion." }
  let(:attributes) do
    {
      id: debate.id,
      conclusions:
    }
  end

  context "when the conclusions exceeds the permited length" do
    let(:conclusions) { "c" * 10_001 }

    it { is_expected.to be_invalid }

    context "with carriage return characters that cause it to exceed" do
      let(:conclusions) { "#{"c" * 5000}\r\n#{"c" * 4999}" }

      it { is_expected.to be_valid }
    end
  end
end
