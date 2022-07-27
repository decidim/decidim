# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe SpawnCommitteeRequest do
      let(:initiative) { create(:initiative, :created) }
      let(:current_user) { create(:user, organization: initiative.organization) }
      let(:state) { "requested" }
      let(:form) do
        Decidim::Initiatives::CommitteeMemberForm
          .from_params(initiative_id: initiative.id, user_id: current_user.id, state:)
          .with_context(
            current_organization: initiative.organization,
            current_user:
          )
      end
      let(:command) { described_class.new(form, current_user) }

      context "when duplicated request" do
        let!(:committee_request) { create(:initiatives_committee_member, user: current_user, initiative:) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast :invalid
        end
      end

      context "when everything is ok" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast :ok
        end

        it "notifies author" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.initiatives.spawn_committee_request",
              event_class: Decidim::Initiatives::SpawnCommitteeRequestEvent,
              resource: initiative,
              affected_users: [initiative.author],
              force_send: true,
              extra: { applicant: current_user }
            )

          command.call
        end

        it "Creates a committee membership request" do
          expect do
            command.call
          end.to change(InitiativesCommitteeMember, :count)
        end

        it "Request state is requested" do
          command.call
          request = InitiativesCommitteeMember.last
          expect(request).to be_requested
        end
      end
    end
  end
end
