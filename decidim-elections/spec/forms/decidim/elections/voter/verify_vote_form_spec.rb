# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::VerifyVoteForm do
  subject { described_class.from_params(params).with_context(context) }

  let(:params) do
    {
      vote_identifier: "f149b928f7a00eae7e634fc5db0c3cc5531eefb81f49febce8da5bb4a153548b"
    }
  end
  let(:context) do
    {
      election:
    }
  end
  let(:election) { create(:election) }

  context "when everything is fine" do
    it { is_expected.to be_valid }
  end

  context "when the vote identifier is not present" do
    let(:params) do
      {
        vote_identifier: ""
      }
    end

    it { is_expected.to be_invalid }
  end

  context "when the election is not present" do
    let(:context) { {} }

    it { is_expected.to be_invalid }
  end
end
