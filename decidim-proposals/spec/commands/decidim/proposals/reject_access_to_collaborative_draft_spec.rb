# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe RejectAccessToCollaborativeDraft do
      let(:component) { create(:proposal_component) }
      let(:state) { :open }
      let(:collaborative_draft) { create(:collaborative_draft, state, component:, users: [author1, author2]) }
      let(:id) { collaborative_draft.id }
      let(:requester_user) { create(:user, :confirmed, organization: component.organization) }
      let(:requester_user_id) { requester_user.id }
      let(:author1) { create(:user, :confirmed, organization: component.organization) }
      let(:author2) { create(:user, :confirmed, organization: component.organization) }
      let(:current_user) { author1 }
      let(:current_organization) { component.organization }
      let(:form) { RejectAccessToCollaborativeDraftForm.from_params(form_params).with_context(current_user:, current_organization:) }
      let(:form_params) do
        {
          state:,
          id:,
          requester_user_id:
        }
      end

      describe "Author (current_user) rejects access to requester to collaborate" do
        let(:command) { described_class.new(form, current_user) }

        before do
          collaborative_draft.collaborator_requests.create!(user: requester_user)
        end

        context "when the collaborative draft is open" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "removes the requester from requestors of the collaborative draft" do
            expect do
              command.call
            end.to change(collaborative_draft.requesters, :count).by(-1)
          end

          it "notifies the requester and authors of the collaborative draft that access to requester has been rejected" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_rejected",
                event_class: Decidim::Proposals::CollaborativeDraftAccessRejectedEvent,
                resource: collaborative_draft,
                affected_users: collaborative_draft.authors,
                extra: {
                  requester_id: requester_user_id
                }
              )

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_requester_rejected",
                event_class: Decidim::Proposals::CollaborativeDraftAccessRequesterRejectedEvent,
                resource: collaborative_draft,
                affected_users: [requester_user]
              )

            command.call
          end
        end

        context "when the collaborative draft is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the collaborative draft" do
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

          it "doesn't reject the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end

        context "when the requester is missing" do
          let(:requester_user_id) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end

        context "when the current_user is missing" do
          let(:current_user) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end

        context "when the requester is not as a requestor" do
          let(:not_requester) { create(:user, :confirmed, organization: component.organization) }
          let(:requester_user_id) { not_requester.id }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end
      end
    end
  end
end
