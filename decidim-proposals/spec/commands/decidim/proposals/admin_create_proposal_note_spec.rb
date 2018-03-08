# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposalNote do
        describe "call" do
          let(:proposal) { create(:proposal) }
          let(:current_user) { create(:user, :admin, organization: proposal.feature.organization) }
          let(:form) { ProposalNoteForm.from_params(form_params).with_context(current_user: current_user) }

          let(:form_params) do
            {
              body: "A reasonable private note"
            }
          end

          let(:command) { described_class.new(form, proposal) }

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create the proposal note" do
              expect do
                command.call
              end.to change(ProposalVote, :count).by(0)
            end
          end

          describe "when the form is valid" do
            before do
              expect(form).to receive(:invalid?).and_return(false)
            end

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates the proposal notes" do
              expect do
                command.call
              end.to change(ProposalNote, :count).by(1)
            end

            it "traces the action", versioning: true do
              expect(Decidim.traceability)
                .to receive(:create!)
                .with(ProposalNote, current_user, hash_including(:body, :proposal, :author), resource: hash_including(:title))
                .and_call_original

              expect { command.call }.to change(ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
            end
          end
        end
      end
    end
  end
end
