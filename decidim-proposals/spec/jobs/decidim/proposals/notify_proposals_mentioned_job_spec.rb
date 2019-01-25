# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe NotifyProposalsMentionedJob do
      include_context "when creating a comment"
      subject { described_class }

      let(:comment) { create(:comment, commentable: commentable) }
      let(:proposal_component) { create(:proposal_component, organization: organization) }
      let(:proposal_metadata) { Decidim::ContentParsers::ProposalParser::Metadata.new([]) }
      let(:linked_proposal) { create(:proposal, component: proposal_component) }
      let(:linked_proposal_no_author) { create(:proposal, :official, component: proposal_component) }

      describe "integration" do
        it "is correctly scheduled" do
          ActiveJob::Base.queue_adapter = :test
          proposal_metadata[:linked_proposals] << linked_proposal
          proposal_metadata[:linked_proposals] << linked_proposal_no_author
          comment = create(:comment)

          expect do
            Decidim::Comments::CommentCreation.publish(comment, proposal: proposal_metadata)
          end.to have_enqueued_job.with(comment.id, proposal_metadata.linked_proposals)
        end
      end

      describe "with mentioned proposals" do
        let(:linked_proposals) do
          [
            linked_proposal.id,
            linked_proposal_no_author.id
          ]
        end

        it "notifies the author about it" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.proposal_mentioned",
              event_class: Decidim::Proposals::ProposalMentionedEvent,
              resource: commentable,
              recipient_ids: [linked_proposal.decidim_author_id],
              extra: {
                comment_id: comment.id,
                mentioned_proposal_id: linked_proposal.id
              }
            )
          subject.perform_now(comment.id, linked_proposals)
        end
      end
    end
  end
end
