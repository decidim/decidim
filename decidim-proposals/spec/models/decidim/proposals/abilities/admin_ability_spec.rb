# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Abilities::AdminAbility do
  subject { described_class.new(user, context) }

  let(:user) { build(:user, :admin) }
  let(:context) { {} }

  context "when the user is not an admin" do
    let(:user) { build(:user) }

    it "doesn't have any permission" do
      expect(subject.permissions[:can]).to be_empty
      expect(subject.permissions[:cannot]).to be_empty
    end
  end

  it { is_expected.to be_able_to(:manage, Decidim::Proposals::Proposal) }

  context "when creation is disabled" do
    let(:context) do
      {
        current_settings: double(creation_enabled?: false),
        feature_settings: double(official_proposals_enabled: true)
      }
    end

    it { is_expected.not_to be_able_to(:create, Decidim::Proposals::Proposal) }
  end

  context "when official proposals are disabled" do
    let(:context) do
      {
        current_settings: double(creation_enabled?: true),
        feature_settings: double(official_proposals_enabled: false)
      }
    end

    it { is_expected.not_to be_able_to(:create, Decidim::Proposals::Proposal) }
  end

  context "when proposal_answering is disabled in step level" do
    let(:context) do
      {
        current_settings: double(proposal_answering_enabled: false)
      }
    end

    it { is_expected.not_to be_able_to(:update, Decidim::Proposals::Proposal) }
  end

  context "when proposal_answering is disabled in feature level" do
    let(:context) do
      {
        feature_settings: double(proposal_answering_enabled: false)
      }
    end

    it { is_expected.not_to be_able_to(:update, Decidim::Proposals::Proposal) }
  end
end
