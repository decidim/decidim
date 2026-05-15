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
        let(:states) { %w(accepted) }
        let(:params) do
          {
            states:,
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

        context "when the states is not valid" do
          let(:states) { %w(foo) }

          it { is_expected.to be_invalid }
        end

        context "when there are no states" do
          let(:states) { [] }

          it { is_expected.to be_valid }
        end

        context "when there is no target component" do
          let(:origin_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when importing from multiple states" do
          let(:states) { %w(accepted rejected) }

          it { is_expected.to be_valid }
        end

        describe "states" do
          let(:states) { ["", "accepted"] }

          it "ignores blank options" do
            expect(form.states).to eq(["accepted"])
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
