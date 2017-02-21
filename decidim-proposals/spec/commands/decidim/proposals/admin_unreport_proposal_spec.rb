# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UnreportProposal do
        let(:proposal) { create(:proposal, :reported) }
        let(:command) { described_class.new(proposal) }

        context "when everything is ok" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "resets the report count" do
            command.call
            expect(proposal.reload.report_count).to eq(0)
          end

          context "when the proposal is hidden" do
            let(:proposal) { create(:proposal, :reported, :hidden) }

            it "unhides the proposal" do
              command.call
              expect(proposal.reload).not_to be_hidden
            end
          end
        end

        context "when the proposal is not reported" do
          let(:proposal) { create(:proposal) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
