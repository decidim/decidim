# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment do
      include_context "when creating a comment"
      it_behaves_like "create comment"

      context "and comment contains a link to a proposal" do
        let(:prop_feature) { create(:proposal_feature, organization: organization) }
        let(:source_proposal) { create(:proposal, feature: prop_feature) }
        let(:linked_proposal) { create(:proposal, feature: prop_feature) }
        let(:parser_context) { { current_organization: organization } }
        let(:body) { ::Faker::Lorem.paragraph + " ~#{linked_proposal.id}" }

        context "when the link is a Proposal id" do
          it "creates a new comment with proposal url replaced" do
            expect(Comment).to receive(:create!).with(
              author: author,
              commentable: commentable,
              root_commentable: commentable,
              body: Decidim::ContentProcessor.parse(body, parser_context).rewrite,
              alignment: alignment,
              decidim_user_group_id: user_group_id
            ).and_call_original

            expect do
              command.call
            end.to change(Comment, :count).by(1)
          end
        end

        context "when the link is a url" do
          let(:body) { ::Faker::Lorem.paragraph + " #{Decidim::ResourceLocatorPresenter.new(linked_proposal).path}" }

          it "creates a new comment with proposal url replaced" do
            expect(Comment).to receive(:create!).with(
              author: author,
              commentable: commentable,
              root_commentable: commentable,
              body: Decidim::ContentProcessor.parse(body, parser_context).rewrite,
              alignment: alignment,
              decidim_user_group_id: user_group_id
            ).and_call_original

            expect do
              command.call
            end.to change(Comment, :count).by(1)
          end
        end

        it "sends a notification with mentioned proposals in its m" do
          expect(command).to receive(:send_notification).and_return false

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.proposal_mentioned",
              event_class: Decidim::Proposals::ProposalMentionedEvent,
              resource: commentable,
              recipient_ids: [linked_proposal.decidim_author_id],
              extra: {
                comment_id: a_kind_of(Integer),
                mentioned_proposal_id: linked_proposal.id
              }
            )

          command.call
        end
      end
    end
  end
end
