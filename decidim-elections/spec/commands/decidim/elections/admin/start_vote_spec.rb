# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::StartVote do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:invalid) { false }
  let(:participatory_process) { create :participatory_process, organization: }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:user) { create :user, :admin, :confirmed, organization: }
  let(:election) { create :election, :key_ceremony_ended }
  let(:form) do
    double(
      invalid?: invalid,
      election:,
      current_user: user,
      current_component:,
      current_organization: organization,
      bulletin_board:
    )
  end

  let(:method_name) { :start_vote }
  let(:response) { OpenStruct.new(status: "enqueued") }
  let(:action) { Decidim::Elections::Action.last }

  let(:bulletin_board) do
    double(Decidim::Elections.bulletin_board)
  end

  before do
    allow(bulletin_board).to receive(:public_key).and_return({
                                                               kty: "RSA",
                                                               n: "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw",
                                                               e: "AQAB",
                                                               alg: "RS256",
                                                               kid: "2011-04-29"
                                                             })
    allow(bulletin_board).to receive(:authority_name).and_return("Decidim Test Authority")
    allow(bulletin_board).to receive(:authority_slug).and_return("decidim-test-authority")
    allow(bulletin_board).to receive(method_name).and_yield("a.message+id").and_return(response)
  end

  context "when valid form" do
    it "logs the performed action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:start_vote, election, user, visibility: "all")
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    it "creates an action" do
      expect { subject.call }.to change { Decidim::Elections::Action.count }.by(1)

      expect(action.election).to eq(election)
      expect(action.message_id).to eq "a.message+id"
      expect(action).to be_pending
      expect(action).to be_start_vote
    end

    it "calls the bulletin board method with the correct params" do
      subject.call
      expect(bulletin_board).to have_received(method_name).with(election.id)
    end
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
