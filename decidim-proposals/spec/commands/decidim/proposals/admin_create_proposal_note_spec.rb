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
              expect(Decidim::EventsManager).not_to receive(:publish)

              command.call
            end
          end

          context "when author is the only mentioned" do
            let(:body) { body_with_mentions(current_user) }

            it "nobody gets notified" do
              expect(Decidim::EventsManager).not_to receive(:publish)

              command.call
            end
          end

          context "when admins, participatory space admins or proposal valuators are mentioned" do
            let(:body) { body_with_mentions(another_admin, participatory_space_admin, valuator) }

            it "affected users are notified" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .once
                .ordered
                .with(
                  event: "decidim.events.proposals.admin.proposal_note_created",
                  event_class: Decidim::Proposals::Admin::ProposalNoteCreatedEvent,
                  resource: proposal,
                  affected_users: a_collection_containing_exactly(another_admin, participatory_space_admin, valuator)
                )

              command.call
            end
          end

          context "when not affected users are mentioned" do
            let(:body) { body_with_mentions(normal_user, other_participatory_space_admin, other_proposal_valuator) }

            it "they are not notified" do
              expect(Decidim::EventsManager).not_to receive(:publish)

              command.call
            end
          end
        end
      end
    end
  end
end
