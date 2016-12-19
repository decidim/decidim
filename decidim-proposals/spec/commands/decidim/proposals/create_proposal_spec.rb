# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposal do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create :participatory_process, organization: organization }
        let(:feature) { create(:feature, participatory_process: participatory_process) }
        let(:form_params) do
          {
            title: "Proposal title",
            body: "Proposal body",
            author: create(:user, organization: organization),
            feature: feature
          }
        end
        let(:form) do
          ProposalForm.from_params(
            form_params,
            current_organization: organization,
            current_process: participatory_process
          )
        end
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a proposal" do
            expect do
              command.call
            end.to_not change { Proposal.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new proposal" do
            expect do
              command.call
            end.to change { Proposal.count }.by(1)
          end
        end
      end
    end
  end
end
