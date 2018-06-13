# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe PublishCollaborativeDraft do
      describe "call" do
        let(:component) { create(:proposal_component) }
        let(:organization) { component.organization }
        let!(:current_user) { create(:user, organization: organization) }
        let(:follower) { create(:user, organization: organization) }
        let(:other_author) { create(:user, organization: organization) }
        let(:state) { :open }
        let(:collaborative_draft) { create(:collaborative_draft, component: component, state: state, authors: [current_user, other_author]) }
        let!(:follow) { create :follow, followable: current_user, user: follower }
        let(:event) { "decidim.events.proposals.collaborative_draft_published" }
        let(:event_class) { Decidim::Proposals::CollaborativeDraftPublishedEvent }

        it "broadcasts ok" do
          expect { described_class.call(collaborative_draft, current_user) }.to broadcast(:ok)
        end

        it "broadcasts invalid when the user is not a coauthor" do
          expect { described_class.call(collaborative_draft, follower) }.to broadcast(:invalid)
        end

        context "when the resource is closed" do
          let(:state) { :closed }

          it "broadcasts invalid" do
            expect { described_class.call(collaborative_draft, follower) }.to broadcast(:invalid)
          end
        end

        context "when the resource is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { described_class.call(collaborative_draft, follower) }.to broadcast(:invalid)
          end
        end

        describe "events" do
          subject do
            described_class.new(collaborative_draft, current_user)
          end

          it "notifies the collaborative draft is published to coauthors" do
            recipient_ids = collaborative_draft.authors.pluck(:id) - [current_user.id]
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: event,
                event_class: event_class,
                resource: collaborative_draft,
                recipient_ids: recipient_ids.uniq,
                extra: {
                  author_id: current_user.id
                }
              ).ordered
            subject.call
          end

          xit "notifies the collaborative draft is closed to followers" do
            other_follower = create(:user, organization: organization)
            create(:follow, followable: component.participatory_space, user: follower)
            create(:follow, followable: component.participatory_space, user: other_follower)

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: event,
                event_class: event_class,
                resource: collaborative_draft,
                recipient_ids: [follower.id]
              ).ordered

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: event,
                event_class: event_class,
                resource: collaborative_draft,
                recipient_ids: [other_follower.id],
                extra: {
                  participatory_space: true
                }
              ).ordered

            subject.call
          end
        end
      end
    end
  end
end
