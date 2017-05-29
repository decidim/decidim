# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe AnswerProposal do
        describe "call" do
          let(:proposal) { create(:proposal) }
          let(:form) { ProposalAnswerForm.from_params(form_params) }
          let(:form_params) do
            {
              state: "rejected", answer: { en: "Foo" }
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

            it "doesn't update the proposal" do
              expect(proposal).not_to receive(:update_attributes!)
              command.call
            end
          end

          describe "when the form is valid" do
            before do
              expect(form).to receive(:invalid?).and_return(false)
            end

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "updates the proposal" do
              command.call

              expect(proposal.reload).to be_answered
            end
          end
        end
      end
    end
  end
end
