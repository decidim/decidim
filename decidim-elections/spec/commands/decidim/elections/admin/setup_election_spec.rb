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
      api_key: "89Ht70GZNcicu8WEyagz_rRae6brbqZAGuBEICYBCii-PTV3MAstAtx1aRVe5H5YfODi-JgYPvyf9ZMH7tOeZ15e3mf9B2Ymgw7eknvBFMRP213YFGo1SPn_C4uLK90G",
      authority_name: "Decidim Test Authority",
      scheme: {
        name: "test",
        parameters: {
          quorum: 2
        }
      },
      number_of_trustees: 2,
      identification_private_key: identification_private_key_content
    )
  end

  let(:identification_private_key_content) do
    <<~KEY
      -----BEGIN RSA PRIVATE KEY-----
      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
      -----END RSA PRIVATE KEY-----
    KEY
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
    end
  end
end
