# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalAnswerType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { ProposalMutationType }
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:current_component) { create(:proposal_component, participatory_space: participatory_process) }
      let!(:model) { create(:proposal, component: current_component) }
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
              state:,
              answerContent: answer_content,
              cost:,
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
          settings: { proposal_answering_enabled: },
          step_settings: {
            component.participatory_space.active_step.id => {
              proposal_answering_enabled:,
              answers_with_costs: proposal_answers_with_costs?
            }
          }
        )
      end

      shared_examples "manage proposal answer mutation examples" do
        context "when proposal answering disabled" do
          it "throws Decidim::Api::Errors::MutationNotAuthorizedError" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when proposal answering enabled" do
          let!(:proposal_answering_enabled) { true }

          it "answers the proposal but not costs" do
            answer = response["answer"]
            expect(answer).to be_present
            expect(answer).to include(
              {
                "id" => model.id.to_s,
                "state" => state,
                "answer" => {
                  "translation" => answer_content[:en]
                },
                "cost" => nil,
                "costReport" => nil,
                "executionPeriod" => nil,
                "answeredAt" => model.reload.answered_at.to_time.iso8601
              }
            )
          end

          context "with enabled answering with cost" do
            let!(:proposal_answers_with_costs?) { true }

            it "answers the proposal and adds the cost" do
              answer = response["answer"]

              expect(answer).to be_present
              expect(answer).to include(
                {
                  "id" => model.id.to_s,
                  "state" => state,
                  "answer" => {
                    "translation" => answer_content[:en]
                  },
                  "cost" => "€ 1,234.00",
                  "costReport" => {
                    "translation" => cost_report[:en]
                  },
                  "executionPeriod" => {
                    "translation" => execution_period[:en]
                  },
                  "answeredAt" => model.reload.answered_at.to_time.iso8601
                }
              )
            end
          end
        end
      end

      it_behaves_like "admin API access checks", "manage proposal answer mutation examples"
    end
  end
end
