# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    module Admin
      describe ProjectImportProposalsForm do
        subject { form }

        let(:project) { create(:project) }
        let(:component) { project.component }
        let(:origin_component) { create(:proposal_component, participatory_space: component.participatory_space) }
        let(:default_budget) { 1000 }
        let(:import_all_accepted_proposals) { true }
        let(:params) do
          {
            origin_component_id: origin_component.try(:id),
            default_budget:,
            import_all_accepted_proposals:
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_component: component,
            current_participatory_space: component.participatory_space
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the default budget is not valid" do
          let(:default_budget) { nil }

          it { is_expected.to be_invalid }
        end

        context "when there's no target component" do
          let(:origin_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the import proposals is not accepted" do
          let(:import_all_accepted_proposals) { false }

          it { is_expected.to be_invalid }
        end

        describe "origin_component" do
          let(:origin_component) { create(:proposal_component) }

          it "ignores components from other participatory spaces" do
            expect(form.origin_component).to be_nil
          end
        end

        describe "origin_components" do
          before do
            create(:component, participatory_space: component.participatory_space)
          end

          it "returns available target components" do
            expect(form.origin_components).to include(origin_component)
            expect(form.origin_components.length).to eq(1)
          end
        end
      end
    end
  end
end
