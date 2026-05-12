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
        let(:states) { %w(accepted rejected) }
        let(:params) do
          {
            origin_component_id: origin_component.try(:id),
            default_budget:,
            states:
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

        context "when there is no target component" do
          let(:origin_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when no states are selected" do
          let(:states) { [] }

          it { is_expected.to be_valid }
        end

        describe "origin_component" do
          let(:origin_component) { create(:proposal_component) }

          it "ignores components from other participatory spaces" do
            expect(form.origin_component).to be_nil
          end
        end

        describe "#origin_components" do
          before do
            create(:component, participatory_space: component.participatory_space)
          end

          it "returns available target components" do
            expect(form.origin_components).to include(origin_component)
            expect(form.origin_components.length).to eq(1)
          end
        end

        describe "valid_states validation" do
          context "when all selected states are valid" do
            let(:states) { %w(accepted rejected) }

            it { is_expected.to be_valid }
          end

          context "when including the special not_answered state" do
            let(:states) { %w(accepted not_answered) }

            it { is_expected.to be_valid }
          end

          context "when only not_answered is selected" do
            let(:states) { %w(not_answered) }

            it { is_expected.to be_valid }
          end

          context "when some states are invalid" do
            let(:states) { %w(accepted invalid_state) }

            it { is_expected.to be_invalid }

            it "adds an error to the states attribute" do
              form.valid?
              expect(form.errors[:states]).to be_present
            end
          end

          context "when all states are invalid" do
            let(:states) { %w(nonexistent_state another_invalid) }

            it { is_expected.to be_invalid }
          end

          context "when there is no origin component" do
            let(:origin_component) { nil }
            let(:states) { %w(invalid_state) }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
