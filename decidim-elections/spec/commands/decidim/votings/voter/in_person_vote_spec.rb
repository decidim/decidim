# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Voter::InPersonVote do
  subject { described_class.new(form) }

  let(:form) do
    double(
      invalid?: invalid,
      election:,
      election_id:,
      voter_id:,
      polling_station:,
      polling_station_slug:,
      polling_officer:,
      bulletin_board:
    )
  end
  let(:invalid) { false }
  let(:election) { create(:election, :complete, :bb_test, :vote, component:) }
  let(:election_id) { election.id }
  let(:voter_id) { "voter.1" }
  let(:organization) { create(:organization) }
  let(:component) { create(:elections_component, organization:) }
  let(:user) { create :user, :confirmed, organization: }
  let(:voting) { create(:voting, :published, organization:) }
  let(:polling_station) { create(:polling_station, id: 1, voting:) }
  let(:polling_station_slug) { polling_station.slug }
  let(:polling_officer) { create(:polling_officer, voting:, user:, presided_polling_station: polling_station) }
  let(:datum) { create(:datum, dataset:, full_name: "Jon Doe", document_type: "DNI", document_number: "12345678X", birthdate: Date.civil(1980, 5, 11)) }
  let(:dataset) { create(:dataset, voting:) }
  let(:in_person_vote_method) { :in_person_vote }

  let(:response) { OpenStruct.new(id: 1, status: "enqueued") }
  let(:message_id) { "#{election.id}.vote.in_person+v.#{voter_id}" }

  let(:bulletin_board) do
    double(Decidim::Elections.bulletin_board)
  end

  before do
    allow(bulletin_board).to receive(in_person_vote_method).and_yield(message_id).and_return(response)
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "stores the vote" do
    expect { subject.call }.to change(Decidim::Votings::InPersonVote, :count).by(1)

    last_vote = Decidim::Votings::InPersonVote.last
    expect(last_vote.election).to eq(election)
    expect(last_vote.voter_id).to eq("voter.1")
    expect(last_vote.polling_station).to eq(polling_station)
    expect(last_vote.polling_officer).to eq(polling_officer)
    expect(last_vote.status).to eq("pending")
  end

  it "calls the bulletin board cast_vote method with the correct params" do
    subject.call
    expect(bulletin_board).to have_received(in_person_vote_method).with(election_id, voter_id, polling_station_slug)
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the bulletin board returns an error message" do
    before do
      allow(bulletin_board).to receive(in_person_vote_method).and_raise(StandardError.new("An error!"))
    end

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid, "An error!")
    end
  end
end
