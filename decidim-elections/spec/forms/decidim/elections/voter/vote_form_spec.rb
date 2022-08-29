# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::VoteForm do
  subject { described_class.from_params(params).with_context(context) }

  let(:params) do
    {
      encrypted_data: "{ \"question_1\": \"aNsWeR 1\" }",
      encrypted_data_hash: "f149b928f7a00eae7e634fc5db0c3cc5531eefb81f49febce8da5bb4a153548b",
      voter_id: "a voter id",
      voter_token: "a voter token"
    }
  end
  let(:context) do
    {
      user:,
      email:,
      election:
    }
  end
  let(:user) { create(:user) }
  let(:email) { "an_email@example.org" }
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

  context "when the election is not present" do
    let(:election) { nil }

    it { is_expected.to be_invalid }
  end
end
