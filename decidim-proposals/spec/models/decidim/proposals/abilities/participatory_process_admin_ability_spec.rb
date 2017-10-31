# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Abilities::ParticipatoryProcessAdminAbility do
  subject { described_class.new(user, context) }

  let(:user) { build(:user) }
  let(:user_process) { create :participatory_process, organization: user.organization }
  let!(:user_process_role) { create :participatory_process_user_role, user: user, participatory_process: user_process, role: :admin }
  let(:feature) { create :proposal_feature, participatory_space: user_process }
  let(:proposals) { create_list :proposal, 3, feature: feature }
  let(:other_proposals) { create_list :proposal, 3 }
  let(:context) { { current_participatory_process: user_process } }

  context "when the user is an admin" do
    let(:user) { build(:user, :admin) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:manage, Decidim::Proposals::Proposal) }

  context "when creation is disabled" do
    let(:context) do
      {
        current_participatory_process: user_process,
        current_settings: double(creation_enabled?: false),
        feature_settings: double(official_proposals_enabled: true)
      }
    end

    it { is_expected.not_to be_able_to(:create, Decidim::Proposals::Proposal) }
  end

  context "when official proposals are disabled" do
    let(:context) do
      {
        current_participatory_process: user_process,
        current_settings: double(creation_enabled?: true),
        feature_settings: double(official_proposals_enabled: false)
      }
    end

    it { is_expected.not_to be_able_to(:create, Decidim::Proposals::Proposal) }
  end

  context "when proposal_answering is disabled in step level" do
    let(:context) do
      {
        current_participatory_process: user_process,
        current_settings: double(proposal_answering_enabled: false)
      }
    end

    it { is_expected.not_to be_able_to(:update, Decidim::Proposals::Proposal) }
  end

  context "when proposal_answering is disabled in feature level" do
    let(:context) do
      {
        current_participatory_process: user_process,
        feature_settings: double(proposal_answering_enabled: false)
      }
    end

    it { is_expected.not_to be_able_to(:update, Decidim::Proposals::Proposal) }
  end
end
