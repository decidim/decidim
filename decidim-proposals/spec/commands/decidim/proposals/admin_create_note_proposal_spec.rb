# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateNoteProposal do
        let(:form_klass) { ProposalNoteForm }

        describe "call" do
          let(:form) do
            form_klass.from_params(
              form_params
            )
          end
          let(:form_params) do
            {
              body: "A reasonable private note",
              proposal: proposal,
              author: current_user
            }
          end
          let(:proposal) { create(:proposal) }
          let(:current_user) { create(:user, organization: proposal.feature.organization) }
          let(:command) { described_class.new(form, proposal, current_user) }

          context "with normal conditions" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a new note for the proposal" do
              expect do
                command.call
              end.to change { ProposalNote.count }.by(1)
            end
          end
        end
      end
    end
  end
end
