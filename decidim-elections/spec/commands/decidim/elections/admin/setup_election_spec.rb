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
  let(:bulletin_board) do
    Decidim::Elections::BulletinBoardClient.new(
      server: "http://localhost:8000/api",
      api_key: Rails.application.secrets.bulletin_board[:api_key],
      authority_name: "Decidim Test Authority",
      scheme: {
        name: "test",
        parameters: {
          quorum: 2
        }
      },
      number_of_trustees: 2,
      identification_private_key: identification_private_key
    )
  end

  let(:identification_private_key) do
    Rails.application.secrets.bulletin_board[:identification_private_key]
  end

  let(:identification_private_key_content) do
    Decidim::Elections::JwkUtils.import_private_key(identification_private_key)
  end

  let(:invalid) { false }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when valid form", :vcr do
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
