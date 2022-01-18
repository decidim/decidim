# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    describe SortitionsHelper do
      describe "proposal_path" do
        let(:proposal) { create(:proposal) }

        it "Returns a path for a proposal" do
          expect(helper.proposal_path(proposal)).not_to be_blank
        end
      end

      describe "sortition_category_label" do
        let(:sortition) { create(:sortition) }

        context "when uncategorized sortition" do
          it "returns from all categories" do
            expect(helper.sortition_category_label(sortition)).to eq("from all categories")
          end
        end

        context "when categorized sortition" do
          let(:category) { create(:category, participatory_space: sortition.component.participatory_space) }

          before do
            Decidim::Categorization.create!(
              decidim_category_id: category.id,
              categorizable: sortition
            )
            sortition.reload
          end

          it "returns from the given category" do
            expect(helper.sortition_category_label(sortition)).to eq("from the #{category.name["en"]} category")
          end
        end
      end

      describe "sortition_proposal_candidate_ids" do
        let(:sortition) { create(:sortition) }
        let!(:label) { helper.sortition_proposal_candidate_ids(sortition) }

        it "Contains all candidate proposal ids" do
          sortition.candidate_proposals.each do |proposal_id|
            expect(label).to include proposal_id.to_s
          end
        end

        it "Selected proposal ids appear in bold" do
          sortition.selected_proposals.each do |proposal_id|
            expect(label).to include "<b>#{proposal_id}</b>"
          end
        end
      end
    end
  end
end
