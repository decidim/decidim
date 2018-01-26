# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateProposal do
        describe "call" do
          let(:organization) { create(:organization) }
          let(:participatory_process) { create(:participatory_process, organization: organization) }
          let(:feature) { create(:proposal_feature, participatory_space: participatory_process) }
          let!(:category_one) { create :category, participatory_space: participatory_process }
          let!(:category) { create :category, participatory_space: participatory_process }
          let!(:proposal) { create :proposal, feature: feature, category: category_one }

          describe "when the category is not valid" do

            it "broadcasts invalid" do
              expect { described_class.call(proposal.category, proposal) }.to broadcast(:invalid)
              expect { described_class.call(nil, proposal) }.to broadcast(:invalid)
            end

            it "doesn't update the proposal" do
              expect(proposal).not_to receive(:update_attributes!)

              described_class.call(proposal.category, proposal).call
            end
          end

          describe "when the category is valid" do

            it "broadcasts ok" do
              expect { described_class.call(category, proposal) }.to broadcast(:ok)
            end

            it "updates the proposal" do
              described_class.call(category, proposal)

              expect(proposal.reload.category).to eq(category)
            end
          end
        end
      end
    end
  end
end
