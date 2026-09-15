# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe DeleteMilestoneType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { ResultMutationType }
    let(:current_component) { component }

    let(:component) { create(:accountability_component, organization: current_organization) }
    let!(:result) { create(:result, component:) }
    let!(:milestone) { create(:milestone, result:) }
    let!(:model) { result }

    let(:query) do
      %( mutation { deleteMilestone(id: #{milestone.id}) { id } })
    end

    shared_examples "API deletable milestone" do
      it "deletes the milestone" do
        expect do
          execute_query(query, variables)
        end.to change(Decidim::Accountability::Milestone, :count).by(-1)
      end

      context "when missing milestone" do
        context "when milestone is missing" do
          let(:query) { %( mutation { deleteMilestone(id: 123456789) { id } }) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Milestone not found")
          end
        end

        context "when milestone id is not integer" do
          let(:query) { %( mutation { deleteMilestone(id: "aaaa") { id } } ) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Milestone not found")
          end
        end

        context "when milestone belongs to another result" do
          let!(:result2) { create(:result, component:) }
          let!(:milestone) { create(:milestone, result: result2) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Milestone not found")
          end
        end

        context "when milestone belongs to another result and the result belongs to another component" do
          let(:component2) { create(:accountability_component, organization: current_organization) }
          let!(:result2) { create(:result, component: component2) }
          let!(:milestone) { create(:milestone, result: result2) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Milestone not found")
          end
        end

        context "when milestone belongs to another result in the same component" do
          let!(:result2) { create(:result, component:) }
          let!(:milestone) { create(:milestone, result: result2) }

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, /Milestone not found/)
          end
        end

        context "when milestone is already deleted" do
          before do
            milestone.destroy
          end

          it "raises an error" do
            expect { response }.to raise_error(Decidim::Api::Errors::NotFoundError, "Milestone not found")
          end
        end
      end
    end

    it_behaves_like "admin API access checks", "API deletable milestone"
  end
end
