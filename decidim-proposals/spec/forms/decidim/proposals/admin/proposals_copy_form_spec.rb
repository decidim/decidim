# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalsCopyForm do
        subject { form }

        let(:proposal) { create(:proposal) }
        let(:feature) { proposal.feature }
        let(:origin_feature) { create(:proposal_feature, participatory_space: feature.participatory_space) }
        let(:states) { %w(accepted) }
        let(:copy_proposals) { true }
        let(:params) do
          {
            states: states,
            origin_feature_id: origin_feature.try(:id),
            copy_proposals: copy_proposals
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_feature: feature,
            current_participatory_space: feature.participatory_space
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

        context "when there's no target feature" do
          let(:origin_feature) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the copy proposals is not accepted" do
          let(:copy_proposals) { false }

          it { is_expected.to be_invalid }
        end

        describe "states" do
          let(:states) { ["", "accepted"] }

          it "ignores blank options" do
            expect(form.states).to eq(["accepted"])
          end
        end

        describe "origin_feature" do
          let(:origin_feature) { create(:proposal_feature) }

          it "ignores features from other participatory spaces" do
            expect(form.origin_feature).to be_nil
          end
        end

        describe "origin_features" do
          before do
            create(:feature, participatory_space: feature.participatory_space)
          end

          it "returns available target features" do
            expect(form.origin_features).to include(origin_feature)
            expect(form.origin_features.length).to eq(1)
          end
        end
      end
    end
  end
end
