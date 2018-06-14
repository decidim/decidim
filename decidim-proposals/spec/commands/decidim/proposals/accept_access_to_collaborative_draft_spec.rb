# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe AcceptAccessToCollaborativeDraft do
      let(:component) { create(:proposal_component) }
      let(:state) { :open }
      let(:collaborative_draft) { create(:collaborative_draft, state, component: component, authors: [author1, author2]) }
      let(:requester) { create(:user, :confirmed, organization: component.organization) }
      let(:author1) { create(:user, :confirmed, organization: component.organization) }
      let(:author2) { create(:user, :confirmed, organization: component.organization) }
      let(:current_user) { author1 }

      describe "Author (current_user) accepts access to requester to collaborate" do
        let(:command) { described_class.new(collaborative_draft, current_user, requester) }

        before do
          RequestAccessToCollaborativeDraft.call(collaborative_draft, requester)
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
            expect do
              command.call
            end.to change(collaborative_draft.authors, :count).by(1)
          end

          it "notifies the requester and authors of the collaborative draft that access to requester has been accepted" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_accepted",
                event_class: Decidim::Proposals::CollaborativeDraftAccessAcceptedEvent,
                resource: collaborative_draft,
                recipient_ids: collaborative_draft.authors.pluck(:id) - [requester.id],
                extra: {
                  requester_id: requester.id
                }
              )

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.collaborative_draft_access_requester_accepted",
                event_class: Decidim::Proposals::CollaborativeDraftAccessRequesterAcceptedEvent,
                resource: collaborative_draft,
                recipient_ids: [requester.id]
              )

            command.call
          end
        end

        context "when the collaborative draft is closed" do
          let(:state) { :closed }

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
          let(:requester) { nil }

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
          before do
            collaborative_draft.requesters.delete requester
          end

          let(:requester) { create(:user, :confirmed, organization: component.organization) }

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
