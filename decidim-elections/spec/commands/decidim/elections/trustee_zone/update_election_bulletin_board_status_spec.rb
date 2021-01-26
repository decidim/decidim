# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::UpdateElectionBulletinBoardStatus do
  subject { described_class.new(election, required_status) }

  let(:election) { create :election, :created }
  let(:required_status) { :key_ceremony }
  let(:new_status) { :ready }
  let(:response) { new_status }

  before do
    allow(Decidim::Elections.bulletin_board).to receive(:get_status).and_return(response)
  end

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates the election status" do
    subject.call
    expect(election).to be_bb_ready
  end

  context "when the election status doesn't match the required status" do
    let(:election) { create :election, :results }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "doesn't update the election status" do
      subject.call
      expect(election).to be_bb_results
    end
  end
end
