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
        let(:import_proposals) { true }
        let(:params) do
          {
            states:,
            keep_authors: false,
            origin_component_id: origin_component.try(:id),
            import_proposals:
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

          it { is_expected.to be_invalid }
        end

        context "when there's no target component" do
          let(:origin_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the import proposals is not accepted" do
          let(:import_proposals) { false }

          it { is_expected.to be_invalid }
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
      end
    end
  end
end
