# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe EvaluationAssignmentForm do
        subject { form }

        let(:organization) { component.participatory_space.organization }
        let(:proposals) { create_list(:proposal, 2, component:) }
        let(:component) { create(:proposal_component) }
        let(:evaluator_process) { component.participatory_space }
        let(:evaluator) { create(:user, organization:) }
        let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: evaluator_process) }
        let(:params) do
          {
            evaluator_role_ids: [evaluator_role.try(:id)],
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

        context "without evaluator roles" do
          let(:evaluator_role) { nil }

          it { is_expected.to be_invalid }
        end

        context "when not enough proposals" do
          let(:proposals) { [] }

          it { is_expected.to be_invalid }
        end

        context "when given a evaluator role from another space" do
          let(:evaluator_process) { create(:participatory_process, organization:) }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
