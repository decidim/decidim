# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::UpdateElectionBulletinBoardStatus do
  subject { described_class.new(election, required_status) }

  let(:election) { create :election, required_status }
  let(:required_status) { :key_ceremony }
  let(:new_status) { :key_ceremony_ended }
  let(:election_status_response) { new_status }

  before do
    allow(Decidim::Elections.bulletin_board).to receive(:get_election_status).and_return(election_status_response)
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates the election status" do
    subject.call
    expect(election).to be_bb_key_ceremony_ended
  end

  context "when the election status doesn't match the required status" do
    let(:election) { create :election, :tally_ended }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "doesn't update the election status" do
      subject.call
      expect(election).to be_bb_tally_ended
    end
  end

  context "when the new election status is tally_ended" do
    let(:election) { create :election, :complete, bb_status: required_status }
    let(:required_status) { :tally }
    let(:new_status) { :tally_ended }
    let(:election_results_response) do
      {
        election_results: {
          election.questions.first.slug => {
            "#{election.questions.first.slug}_#{election.questions.first.answers.first.slug}" => 1,
            "#{election.questions.first.slug}_#{election.questions.first.answers.last.slug}" => 2
          },
          election.questions.last.slug =>
          {
            "#{election.questions.last.slug}_#{election.questions.last.answers.first.slug}" => 3,
            "#{election.questions.last.slug}_#{election.questions.last.answers.last.slug}" => 4
          }
        },
        verifiable_results: { url: "some-url", hash: "some-hash" }
      }
    end

    before do
      allow(Decidim::Elections.bulletin_board).to receive(:get_election_results).and_return(election_results_response)
    end

    it "updates the election verifiable results data" do
      subject.call
      election.reload

      expect(election.verifiable_results_file_url).to eq "some-url"
      expect(election.verifiable_results_file_hash).to eq "some-hash"
    end

    it "create the election results" do
      subject.call

      expect(election.questions.first.answers.first.results.first.value).to eq 1
      expect(election.questions.first.answers.last.results.first.value).to eq 2
      expect(election.questions.last.answers.first.results.first.value).to eq 3
      expect(election.questions.last.answers.last.results.first.value).to eq 4
    end
  end
end
