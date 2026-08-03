# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalsImportForm do
        subject { form }

        let(:proposal) { create(:proposal) }
        let(:component) { proposal.component }
        let(:origin_component) { create(:proposal_component, participatory_space: component.participatory_space) }
        let(:statuses) { %w(accepted) }
        let(:params) do
          {
            statuses:,
            keep_authors: false,
            origin_component_id: origin_component.try(:id)
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

        context "when the statuses is not valid" do
          let(:statuses) { %w(foo) }

          it { is_expected.to be_invalid }
        end

        context "when there are no statuses" do
          let(:statuses) { [] }

          it { is_expected.to be_valid }
        end

        context "when there is no target component" do
          let(:origin_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when importing from multiple statuses" do
          let(:statuses) { %w(accepted rejected) }

          it { is_expected.to be_valid }
        end

        describe "statuses" do
          let(:statuses) { ["", "accepted"] }

          it "ignores blank options" do
            expect(form.statuses).to eq(["accepted"])
          end
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
