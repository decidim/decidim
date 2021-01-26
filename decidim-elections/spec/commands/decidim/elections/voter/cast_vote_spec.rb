# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Voter::CastVote do
  subject { described_class.new(form) }

  let(:form) do
    double(
      invalid?: invalid,
      encrypted_vote: encrypted_vote,
      encrypted_vote_hash: encrypted_vote_hash,
      election: election,
      election_id: election_id,
      election_unique_id: election_unique_id,
      voter_id: voter_id,
      bulletin_board: bulletin_board
    )
  end
  let(:invalid) { false }
  let(:encrypted_vote) { { question_1: "aNsWeR 1" }.to_json }
  let(:encrypted_vote_hash) { "1234" }
  let(:election) { create(:election) }
  let(:election_id) { election.id }
  let(:election_unique_id) { "decidim-test-authority.#{election.id}" }
  let(:voter_id) { "voter.1" }

  let(:method_name) { :cast_vote }
  let(:response) { OpenStruct.new(id: 1, status: "enqueued") }
  let(:bulletin_board) do
    double(Decidim::Elections.bulletin_board)
  end

  before do
    allow(bulletin_board).to receive(method_name).and_return(response)
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

  it "calls the bulletin board cast_vote method with the correct params" do
    subject.call
    expect(bulletin_board).to have_received(method_name).with(election_id, voter_id, encrypted_vote)
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the bulletin board returns an error message" do
    before do
      allow(bulletin_board).to receive(method_name).and_raise(StandardError.new("An error!"))
    end

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid, "An error!")
    end
  end
end
