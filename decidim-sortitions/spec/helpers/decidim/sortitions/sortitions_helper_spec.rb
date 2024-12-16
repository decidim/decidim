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

      describe "sortition_taxonomy_labels" do
        let(:sortition) { create(:sortition) }

        context "when sortition has no taxonomies" do
          it "returns from all taxonomies" do
            expect(helper.sortition_taxonomy_labels(sortition)).to eq("from all taxonomies")
          end
        end

        context "when sortition has taxonomies" do
          let(:taxonomy) { create(:taxonomy, :with_parent, skip_injection: true, organization: sortition.organization) }

          before do
            sortition.taxonomies << taxonomy
          end

          it "returns from the given taxonomy" do
            expect(helper.sortition_taxonomy_labels(sortition)).to eq("from the #{taxonomy.name["en"]} taxonomies")
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
