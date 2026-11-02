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
        let(:statuses) { %w(accepted rejected) }
        let(:params) do
          {
            origin_component_id: origin_component.try(:id),
            default_budget:,
            statuses:
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

        context "when no statuses are selected" do
          let(:statuses) { [] }

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

        describe "valid_statuses validation" do
          context "when all selected statuses are valid" do
            let(:statuses) { %w(accepted rejected) }

            it { is_expected.to be_valid }
          end

          context "when including the special not_answered status" do
            let(:statuses) { %w(accepted not_answered) }

            it { is_expected.to be_valid }
          end

          context "when only not_answered is selected" do
            let(:statuses) { %w(not_answered) }

            it { is_expected.to be_valid }
          end

          context "when some statuses are invalid" do
            let(:statuses) { %w(accepted invalid_status) }

            it { is_expected.to be_invalid }

            it "adds an error to the statuses attribute" do
              form.valid?
              expect(form.errors[:statuses]).to be_present
            end
          end

          context "when all statuses are invalid" do
            let(:statuses) { %w(nonexistent_status another_invalid) }

            it { is_expected.to be_invalid }
          end

          context "when there is no origin component" do
            let(:origin_component) { nil }
            let(:statuses) { %w(invalid_status) }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
