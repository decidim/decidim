# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Proposals
    describe AnswerProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { ProposalMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let!(:model) { create(:proposal, component: proposal_component) }
      let(:state) { %w(accepted evaluating rejected).sample }
      let(:answer_content) { Decidim::Faker::Localized.sentence(word_count: 3) }
      let(:proposal_answering_enabled) { false }
      let(:proposal_answers_with_costs?) { false }
      let(:cost_report) { Decidim::Faker::Localized.sentence(word_count: 3) }
      let(:component) { model.component }
      let(:execution_period) { Decidim::Faker::Localized.sentence(word_count: 3) }
      let(:cost) { 123_4 }
      let(:variables) do
        {
          input: {
            attributes: {
              state: state,
              answerContent: answer_content,
              cost: cost,
              costReport: cost_report,
              executionPeriod: execution_period
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: AnswerInput!) {
            answer(input: $input) {
              id
              answer { translation(locale: "en") }
              state
              cost
              costReport { translation(locale: "en") }
              executionPeriod { translation(locale: "en") }
              answeredAt
            }
          }
        GRAPHQL
      end

      before do
        component.update!(
          settings: { proposal_answering_enabled: proposal_answering_enabled },
          step_settings: {
            component.participatory_space.active_step.id => {
              proposal_answering_enabled: proposal_answering_enabled,
              answers_with_costs: proposal_answers_with_costs?
            }
          }
        )
      end

      context "with admin user" do
        it_behaves_like "manage proposal mutation examples" do
          let!(:user_type) { :admin }
        end
      end

      context "with normal user" do
        it "returns nil" do
          expect(response["answer"]).to be_nil
        end
      end

      context "with api_user" do
        it_behaves_like "manage proposal mutation examples" do
          let!(:user_type) { :api_user }
        end
      end
    end
  end
end
