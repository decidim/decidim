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
      user: user,
      election: election,
      bulletin_board_client: double(authority_slug: "test")
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

  context "when the user is not present" do
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
        user: create(:user)
      }
    end

    it { is_expected.to be_invalid }
  end

  describe "election_data" do
    it "returns a Hash with the election unique id" do
      expect(subject.election_data).to eq({ election_id: "test.#{election.id}" })
    end
  end

  describe "voter_data" do
    it "returns a Hash with the voter unique id" do
      expect(subject.voter_data).to eq({ voter_id: Digest::SHA256.hexdigest([user.created_at, user.id, election.id, "test"].join(".")) })
    end
  end
end
