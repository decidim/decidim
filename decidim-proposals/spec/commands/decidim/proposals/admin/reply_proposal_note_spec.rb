# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ReplyProposalNote do
        include_context "with proposal and users allowed to create proposal notes"

        describe "call" do
          let(:command) { described_class.new(form, proposal_note) }

          it_behaves_like "a proposal note command call"

          context "when no users are mentioned" do
            it "only parent note author is notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_replied",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(another_admin),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end

          context "when admins, participatory space admins or proposal evaluators are mentioned" do
            let(:body) { body_with_mentions(participatory_space_admin, evaluator) }

            it "affected users and parent note author are notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_replied",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(another_admin),
                  extra: { note_author_id: form.current_user.id }
                )
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_mentioned",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(participatory_space_admin, evaluator),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end

          context "when not affected users are mentioned" do
            let(:body) { body_with_mentions(normal_user, other_participatory_space_admin, other_proposal_evaluator) }

            it "only parent note author is notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_replied",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(another_admin),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end

          context "when the author of the reply is the author of the parent note and there are no mentions" do
            let(:author) { current_user }

            it "nobody gets notified" do
              expect(Decidim::EventsManager).not_to receive(:publish)

              command.call
            end
          end
        end
      end
    end
  end
end
