# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::EncryptedVoteForm do
  subject { described_class.from_params(params).with_context(context) }

  let(:params) do
    {
      encrypted_vote: "{ \"question_1\": \"aNsWeR 1\" }",
      encrypted_vote_hash: "f149b928f7a00eae7e634fc5db0c3cc5531eefb81f49febce8da5bb4a153548b"
    }
  end
  let(:context) do
    {
      current_user: user,
      election: election
    }
  end
  let(:user) { create(:user) }
  let(:election) { create(:election) }

  context "when everything is fine" do
    it { is_expected.to be_valid }
  end

  context "when the encrypted vote is not present" do
    let(:params) do
      {
        encrypted_vote_hash: "f149b928f7a00eae7e634fc5db0c3cc5531eefb81f49febce8da5bb4a153548b"
      }
    end

    it { is_expected.to be_invalid }
  end

  context "when the encrypted vote hash is not present" do
    let(:params) do
      {
        encrypted_vote: "{ \"question_1\": \"aNsWeR 1\" }"
      }
    end

    it { is_expected.to be_invalid }
  end

  context "when the encrypted vote hash doesn't match" do
    let(:params) do
      {
        encrypted_vote: "{ \"question_1\": \"aNsWeR 1\" }",
        encrypted_vote_hash: "1234"
      }
    end

    it { is_expected.to be_invalid }
  end

  context "when the current user is not present" do
    let(:context) do
      {
        election: create(:election)
      }
    end

    it { is_expected.to be_invalid }
  end

  context "when the election is not present" do
    let(:context) do
      {
        current_user: create(:user)
      }
    end

    it { is_expected.to be_invalid }
  end

  describe ".election_unique_id" do
    it "returns the election unique id" do
      expect(subject.election_unique_id).to eq("decidim-test-authority.#{election.id}")
    end
  end

  describe ".voter_id" do
    it "returns the voter unique id" do
      expect(subject.voter_id).to eq(Digest::SHA256.hexdigest([user.created_at, user.id, election.id, "decidim-test-authority"].join(".")))
    end
  end
end
