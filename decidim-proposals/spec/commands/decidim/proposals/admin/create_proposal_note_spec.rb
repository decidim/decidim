# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposalNote do
        include_context "with proposal and users allowed to create proposal notes"

        describe "call" do
          let(:command) { described_class.new(form, proposal) }

          it_behaves_like "a proposal note command call"

          context "when no users are mentioned" do
            it "nobody gets notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_created",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(evaluator),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end

          context "when author is the only mentioned" do
            let(:body) { body_with_mentions(current_user) }

            it "only evaluators gets notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_created",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(evaluator),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end

          context "when admins, participatory space admins or proposal evaluators are mentioned" do
            let(:body) { body_with_mentions(another_admin, participatory_space_admin, evaluator) }

            it "affected users are notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_mentioned",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(another_admin, participatory_space_admin, evaluator),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end

            it "evaluators do not receive proposal note creation notification if mentioned" do
              expect(Decidim::EventsManager)
                .not_to receive(:publish)
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_created",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(evaluator),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end

          context "when not affected users are mentioned" do
            let(:body) { body_with_mentions(normal_user, other_participatory_space_admin, other_proposal_evaluator) }

            it "only the evaluators are notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_created",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(evaluator),
                  extra: { note_author_id: form.current_user.id }
                )

              command.call
            end
          end
        end
      end
    end
  end
end
