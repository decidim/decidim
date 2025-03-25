# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalAnswerForm do
        subject { form }

        let(:organization) { proposals_component.participatory_space.organization }
        let(:state) { "accepted" }
        let(:answer) { Decidim::Faker::Localized.sentence(word_count: 3) }
        let(:proposals_component) { create(:proposal_component) }
        let(:cost) { nil }
        let(:cost_report) { nil }
        let(:execution_period) { nil }
        let(:params) do
          {
            internal_state: state,
            answer:,
            cost:,
            cost_report:,
            execution_period:
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_component: proposals_component,
            current_organization: organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the state is not valid" do
          let(:state) { "foo" }

          it { is_expected.to be_invalid }
        end

        context "when there is no state" do
          let(:state) { nil }

          it { is_expected.to be_invalid }
        end

        context "when rejecting a proposal" do
          let(:state) { "rejected" }

          context "and there is no answer" do
            let(:answer) { nil }

            it { is_expected.to be_valid }
          end
        end

        context "when accepting the proposal" do
          let(:state) { "accepted" }

          context "and costs are enabled" do
            before do
              proposals_component.update!(
                step_settings: {
                  proposals_component.participatory_space.active_step.id => {
                    answers_with_costs: true
                  }
                }
              )
            end

            it { is_expected.to be_valid }

            context "and cost data is filled" do
              let(:cost) { 20_000 }
              let(:cost_report) { { en: "Cost report" } }
              let(:execution_period) { { en: "Execution period" } }

              it { is_expected.to be_valid }
            end
          end
        end
      end
    end
  end
end
