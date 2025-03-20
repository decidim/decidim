# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe ParticipatorySpaceProposals do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
        let(:another_proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
        let(:proposals) { create_list(:proposal, 10, component: proposal_component, created_at: request_timestamp - 10.days) }
        let(:request_timestamp) { Time.now.utc }
        let(:category) { nil }
        let(:decidim_proposals_component) { proposal_component }
        let(:sortition) do
          double(
            request_timestamp:,
            category:,
            decidim_proposals_component:
          )
        end

        context "when filtering by component" do
          let(:other_component_proposals) { create_list(:proposal, 10, component: another_proposal_component) }

          it "Includes only proposals in this component" do
            expect(described_class.for(sortition)).to include(*proposals)
          end

          it "Do not includes proposals in other components" do
            expect(described_class.for(sortition)).not_to include(*other_component_proposals)
          end
        end

        context "when filtering by creation date" do
          let(:recent_proposals) { create_list(:proposal, 10, component: proposal_component, created_at: Time.now.utc) }
          let(:request_timestamp) { Time.now.utc - 1.day }

          it "Includes proposals created before the sortition date" do
            expect(described_class.for(sortition)).to include(*proposals)
          end

          it "Do not includes proposals created after the sortition date" do
            expect(described_class.for(sortition)).not_to include(*recent_proposals)
          end
        end

        context "when filtering by category" do
          let(:proposal_category) { create(:category, participatory_space: participatory_process) }
          let(:proposals_with_category) do
            create_list(:proposal, 10,
                        component: proposal_component,
                        category: proposal_category,
                        created_at: request_timestamp - 10.days)
          end

          context "and category is passed nil" do
            it "Contains all proposals" do
              expect(described_class.for(sortition)).to include(*proposals)
              expect(described_class.for(sortition)).to include(*proposals_with_category)
            end
          end

          context "and category is passed" do
            let(:category) { proposal_category }

            it "Contains proposals of the category" do
              expect(described_class.for(sortition)).to include(*proposals_with_category)
            end

            it "Do not contains proposals of the category" do
              expect(described_class.for(sortition)).not_to include(*proposals)
            end
          end
        end

        context "when filtering withdrawn proposals" do
          let(:proposals) do
            create_list(:proposal, 10, :withdrawn, component: proposal_component, created_at: request_timestamp - 10.days)
          end

          it "do not return withdrawn proposals" do
            expect(described_class.for(sortition)).not_to include(*proposals)
          end
        end

        context "when filtering drafts proposals" do
          let(:proposals) do
            create_list(:proposal, 10, :draft, component: proposal_component, created_at: request_timestamp - 10.days)
          end

          it "do not return draft proposals" do
            expect(described_class.for(sortition)).not_to include(*proposals)
          end
        end
      end
    end
  end
end
