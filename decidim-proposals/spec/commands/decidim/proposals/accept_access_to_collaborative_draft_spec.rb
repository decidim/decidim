# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AcceptAccessToCollaborativeDraft do
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
      let(:form) { AcceptAccessToCollaborativeDraftForm.from_params(form_params).with_context(current_user:, current_organization:) }
      let(:form_params) do
        {
          state:,
          id:,
          requester_user_id:
        }
      end

      describe "Author (current_user) accepts access to requester to collaborate" do
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

          it "adds the requester as a co-author of the collaborative draft" do
            command.call
            updated_draft = CollaborativeDraft.find(collaborative_draft.id)
            expect(updated_draft.authors).to include(requester_user)
          end

          it "notifies the requester and authors of the collaborative draft that access to requester has been accepted" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_accepted",
                event_class: Decidim::Proposals::CollaborativeDraftAccessAcceptedEvent,
                resource: collaborative_draft,
                affected_users: collaborative_draft.notifiable_identities - [requester_user],
                extra: {
                  requester_id: requester_user_id
                }
              )

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_requester_accepted",
                event_class: Decidim::Proposals::CollaborativeDraftAccessRequesterAcceptedEvent,
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

          it "doesn't accept the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end

          it "doesn't add the requester as a co-author of the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.authors, :count)
          end
        end

        context "when the collaborative draft is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end

          it "doesn't add the requester as a co-author of the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.authors, :count)
          end
        end

        context "when the requester is missing" do
          let(:requester_user_id) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the collaborative draft" do
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

          it "doesn't accept the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end

        context "when the requester is not as a requestor" do
          let(:not_requester_user) { create(:user, :confirmed, organization: component.organization) }
          let(:requester_user_id) { not_requester_user.id }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the collaborative draft" do
            expect do
              command.call
            end.not_to change(collaborative_draft.requesters, :count)
          end
        end
      end
    end
  end
end
