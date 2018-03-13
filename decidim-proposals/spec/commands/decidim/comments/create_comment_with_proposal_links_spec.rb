# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateComment do
      include_context "when creating a comment"
      it_behaves_like "create comment"

      context "and comment contains a link to a proposal" do
        let(:prop_component) { create(:proposal_component, organization: organization) }
        let(:source_proposal) { create(:proposal, feature: prop_component) }
        let(:linked_proposal) { create(:proposal, feature: prop_component) }
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

          expect(Decidim::Comments::CommentCreation)
            .to receive(:publish)
            .with(
              a_kind_of(Decidim::Comments::Comment),
              hash_including(proposal: Decidim::ContentParsers::ProposalParser::Metadata.new([linked_proposal.id]))
            )
          command.call
        end
      end
    end
  end
end
