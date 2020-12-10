# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::CastVote do
  subject { described_class.new(form, bulletin_board_client) }

  let(:form) do
    double(
      valid?: valid,
      encrypted_vote: { question_1: "aNsWeR 1" },
      encrypted_vote_hash: "1234",
      election: election,
      election_data: { election_id: "test.1" },
      voter_id: "voter.1",
      voter_data: { voter_id: "voter.1" }
    )
  end
  let(:valid) { true }
  let(:election) { create(:election) }
  let(:bulletin_board_client) { double }

  context "when everything is ok" do
    before do
      allow(bulletin_board_client).to receive(:cast_vote)
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "stores the vote" do
      expect { subject.call }.to change(Decidim::Elections::Vote, :count).by(1)

      last_vote = Decidim::Elections::Vote.last
      expect(last_vote.election).to eq(election)
      expect(last_vote.voter_id).to eq("voter.1")
      expect(last_vote.encrypted_vote_hash).to eq("1234")
      expect(last_vote.status).to eq(Decidim::Elections::Vote::PENDING_STATUS)
    end

    it "calls the bulletin board client cast_vote method with the correct params" do
      subject.call
      expect(bulletin_board_client).to have_received(:cast_vote).with(
        { election_id: "test.1" },
        { voter_id: "voter.1" },
        form.encrypted_vote
      )
    end
  end

  context "when the bulletin board client cast_vote raises an error" do
    before do
      allow(bulletin_board_client).to receive(:cast_vote).and_throw("something went wrong")
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the form is not valid" do
    let(:valid) { false }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
