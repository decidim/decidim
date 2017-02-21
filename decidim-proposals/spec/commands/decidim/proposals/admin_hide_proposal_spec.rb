# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe HideProposal do
        let(:proposal) { create(:proposal) }
        let(:command) { described_class.new(proposal) }

        context "when everything is ok" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "hides the proposal" do
            command.call
            expect(proposal.reload).to be_hidden
          end
        end

        context "when the proposal is already hidden" do
          let(:proposal) { create(:proposal, :hidden) }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
