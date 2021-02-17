# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Voting do
  subject(:voting) { build(:voting, slug: "my-slug") }

  it { is_expected.to be_valid }
  it { is_expected.to be_versioned }

  include_examples "publicable"

  it "overwrites the log presenter" do
    expect(described_class.log_presenter_class_for(:foo))
      .to eq Decidim::Votings::AdminLog::VotingPresenter
  end

  context "when there's a voting with the same slug in the same organization" do
    let!(:another_voting) { create :voting, organization: voting.organization, slug: "my-slug" }

    it "is not valid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:slug]).to eq ["has already been taken"]
    end
  end

  context "when there's a voting with the same slug in another organization" do
    let!(:another_voting) { create :voting, slug: "my-slug" }

    it { is_expected.to be_valid }
  end
end
