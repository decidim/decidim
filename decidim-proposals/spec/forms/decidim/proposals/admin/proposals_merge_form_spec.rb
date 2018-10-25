# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalsMergeForm do
        subject { form }

        let(:proposals) { create_list(:proposal, 3, component: component) }
        let(:component) { create(:proposal_component) }
        let(:target_component) { create(:proposal_component, participatory_space: component.participatory_space) }
        let(:params) do
          {
            target_component_id: target_component.try(:id),
            proposal_ids: proposals.map(&:id)
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

        context "without a target component" do
          let(:target_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when not enough proposals" do
          let(:proposals) { create_list(:proposal, 1, component: component) }

          it { is_expected.to be_invalid }
        end

        context "when given a target component from another space" do
          let(:target_component) { create(:proposal_component) }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
