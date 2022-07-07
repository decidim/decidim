# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::SetupElection do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:invalid) { false }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:election) { create :election, :complete }
  let!(:ballot_style) { create(:ballot_style, :with_ballot_style_questions, election: election) }
  let(:trustees) { create_list :trustee, 5, :with_public_key }
  let(:trustee_ids) { trustees.pluck(:id) }
  let(:form) do
    double(
      invalid?: invalid,
      election: election,
      current_user: user,
      current_component: current_component,
      current_organization: organization,
      trustee_ids: trustee_ids,
      bulletin_board: bulletin_board
    )
  end
  let(:scheme) do
    {
      name: "dummy",
      parameters: {
        quorum: 2
      }
    }
  end
  let(:method_name) { :create_election }
  let(:response) { OpenStruct.new(status: "created") }

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
    allow(bulletin_board).to receive(:scheme).and_return(scheme)
    allow(bulletin_board).to receive(method_name).and_return(response)
  end

  context "when valid form" do
    it "updates the election status" do
      expect { subject.call }.to change { Decidim::Elections::Election.last.bb_status }.from(nil).to("created")
    end

    it "logs the performed action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:setup, election, user, visibility: "all")
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end

    it "adds the trustees to the election" do
      expect { subject.call }.to change { election.trustees.count }.by(5)
    end

    it "notifies the trustees" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.elections.trustees.new_election",
          event_class: Decidim::Elections::Trustees::NotifyTrusteeNewElectionEvent,
          resource: election,
          affected_users: trustees.collect(&:user).sort_by(&:id)
        )
      subject.call
    end

    it "blocks the election for modifications" do
      expect { subject.call }.to change(election, :blocked?).from(false).to(true)
      expect(election.blocked_at).to be_within(1.second).of election.updated_at
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
