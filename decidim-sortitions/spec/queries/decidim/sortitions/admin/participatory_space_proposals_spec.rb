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
        let(:taxonomies) { [] }
        let(:decidim_proposals_component) { proposal_component }
        let(:sortition) do
          double(
            request_timestamp:,
            taxonomies:,
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

        context "when filtering by taxonomy" do
          let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
          let(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
          let(:taxonomy_proposals) do
            create_list(:proposal, 10,
                        component: proposal_component,
                        taxonomies: [taxonomy],
                        created_at: request_timestamp - 10.days)
          end
          let(:sub_taxonomy_proposals) do
            create_list(:proposal, 10,
                        component: proposal_component,
                        taxonomies: [sub_taxonomy],
                        created_at: request_timestamp - 10.days)
          end

          context "and no taxonomies" do
            it "Contains all proposals" do
              expect(described_class.for(sortition)).to include(*proposals)
              expect(described_class.for(sortition)).to include(*taxonomy_proposals)
              expect(described_class.for(sortition)).to include(*sub_taxonomy_proposals)
            end
          end

          context "and taxonomy is passed" do
            let(:taxonomies) { [taxonomy] }

            it "Contains proposals of the taxonomy and sub_taxonomies" do
              expect(described_class.for(sortition)).to include(*taxonomy_proposals)
              expect(described_class.for(sortition)).to include(*sub_taxonomy_proposals)
            end

            it "Do not contains proposals of the taxonomy" do
              expect(described_class.for(sortition)).not_to include(*proposals)
            end
          end

          context "and sub_taxonomy is passed" do
            let(:taxonomies) { [sub_taxonomy] }

            it "Contains proposals of the sub_taxonomy" do
              expect(described_class.for(sortition)).to include(*sub_taxonomy_proposals)
            end

            it "Do not contains proposals of the taxonomy" do
              expect(described_class.for(sortition)).not_to include(*proposals)
              expect(described_class.for(sortition)).not_to include(*taxonomy_proposals)
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
