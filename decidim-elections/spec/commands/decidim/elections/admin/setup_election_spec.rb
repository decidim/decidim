# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Admin::SetupElection do
  subject { described_class.new(form, bulletin_board: bulletin_board) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "elections" }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:election) { create :election, :complete }
  let(:trustees) { create_list :trustee, 5, :considered, :with_public_key }
  let(:trustee_ids) { trustees.pluck(:id) }
  let(:errors) { double.as_null_object }
  let(:form) do
    double(
      invalid?: invalid,
      election: election,
      current_user: user,
      current_component: current_component,
      current_organization: organization,
      trustee_ids: trustee_ids,
      errors: errors
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
  let(:status) { OpenStruct.new(status: "key_ceremony")}
  let(:response) do
    OpenStruct.new(election: status, error: nil)
  end

  let(:bulletin_board) do
    double(Decidim::Elections.bulletin_board)
  end

  before do
    allow(bulletin_board).to receive(:authority_slug) { "decidim-test-authority"}
    allow(bulletin_board).to receive(:scheme).and_return(scheme)
    allow(bulletin_board).to receive(:setup_election).and_return(response)
  end

  let(:invalid) { false }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when valid form" do
    let(:trustee_users) { trustees.collect(&:user) }

    it "setup the election" do
      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.elections.trustees.new_election",
          event_class: Decidim::Elections::Trustees::NotifyTrusteeNewElectionEvent,
          resource: election,
          affected_users: trustee_users
        )

      expect { subject.call }.to change { election.trustees.count }.by(5)
      expect(election.blocked_at).to be_within(1.second).of election.updated_at
      expect(election.blocked?).to be true
    end
  end
end
