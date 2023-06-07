# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Voter::UpdateInPersonVoteStatus do
  subject { described_class.new(in_person_vote) }

  let(:in_person_vote) { create(:in_person_vote) }
  let(:method_name) { :get_pending_message_status }
  let(:response) { :accepted }

  before do
    allow(Decidim::Elections.bulletin_board).to receive(method_name).and_return(response)
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates the vote status" do
    subject.call
    expect(in_person_vote.status).to eq "accepted"
  end

  context "when the Bulletin Board has rejected the vote" do
    let(:response) { :rejected }

    it "updates the vote status" do
      subject.call
      expect(in_person_vote.status).to eq "rejected"
    end
  end
end
