# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateProposalCategory do
        describe "call" do
          let(:organization) { create(:organization) }

          let!(:proposal) { create :proposal }
          let!(:proposals) { create_list(:proposal, 3, component: proposal.component) }
          let!(:category_one) { create :category, participatory_space: proposal.component.participatory_space }
          let!(:category) { create :category, participatory_space: proposal.component.participatory_space }

          context "with no category" do
            it "broadcasts invalid_category" do
              expect { described_class.call(nil, proposal.id) }.to broadcast(:invalid_category)
            end
          end

          context "with no proposals" do
            it "broadcasts invalid_proposal_ids" do
              expect { described_class.call(category.id, nil) }.to broadcast(:invalid_proposal_ids)
            end
          end

          describe "with a category and proposals" do
            context "when the category is the same as the proposal's category" do
              before do
                proposal.update!(category:)
              end

              it "doesn't update the proposal" do
                expect(proposal).not_to receive(:update!)
                described_class.call(proposal.category.id, proposal.id)
              end
            end

            context "when the category is diferent from the proposal's category" do
              before do
                proposals.each { |p| p.update!(category: category_one) }
              end

              it "broadcasts update_proposals_category" do
                expect { described_class.call(category.id, proposals.pluck(:id)) }.to broadcast(:update_proposals_category)
              end

              it "updates the proposal" do
                described_class.call(category.id, proposal.id)

                expect(proposal.reload.category).to eq(category)
              end
            end
          end
        end
      end
    end
  end
end
