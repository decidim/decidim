# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe RequestAccessToCollaborativeDraft do
      let(:component) { create(:proposal_component) }
      let(:state) { :open }

      let(:collaborative_draft) { create(:collaborative_draft, state, component:, users: [author1, author2]) }
      let(:id) { collaborative_draft.id }
      let(:form) { RequestAccessToCollaborativeDraftForm.from_params(form_params).with_context(current_user:) }
      let(:form_params) do
        {
          state:,
          id:
        }
      end
      let(:current_user) { create(:user, :confirmed, organization: component.organization) }
      let(:author1) { create(:user, :confirmed, organization: component.organization) }
      let(:author2) { create(:user, :confirmed, organization: component.organization) }

      describe "User requests to collaborate" do
        let(:command) { described_class.new(form, current_user) }

        context "when the collaborative draft is open" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new request for the collaborative draft" do
            expect do
              command.call
            end.to change(collaborative_draft.requesters, :count).by(1)
          end

          it "notifies all authors of the collaborative_draft that access has been requested" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_requested",
                event_class: Decidim::Proposals::CollaborativeDraftAccessRequestedEvent,
                resource: collaborative_draft,
                affected_users: collaborative_draft.authors,
                extra: {
                  requester_id: current_user.id
                }
              )

            command.call
          end
        end

        context "when the collaborative draft is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new requestor for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end

        context "when the collaborative draft is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new requestor for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end
      end
    end
  end
end
