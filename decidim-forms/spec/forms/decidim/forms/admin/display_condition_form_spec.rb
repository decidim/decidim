# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Forms
    module Admin
      describe DisplayConditionForm do
        subject do
          described_class.new(decidim_question_id:,
                              decidim_condition_question_id:,
                              condition_value:,
                              condition_type:,
                              decidim_response_option_id:,
                              mandatory: true).with_context(current_organization: organization)
        end

        let(:organization) { create(:organization) }
        let(:condition_question) { create(:questionnaire_question, position: 1) }
        let(:decidim_condition_question_id) { condition_question&.id }
        let(:question) { create(:questionnaire_question, position: 2) }
        let(:decidim_question_id) { question&.id }
        let(:response_option) { create(:response_option, question: condition_question) }
        let(:decidim_response_option_id) { response_option&.id }
        let(:questionnaire) { question.questionnaire }

        let(:condition_type) { :responded }
        let(:condition_value) do
          {
            en: "Text en",
            ca: "Text ca",
            es: "Text es"
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when decidim_question_id is not present" do
          let!(:decidim_question_id) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when decidim_condition_question_id is not present" do
          let!(:decidim_condition_question_id) { nil }
          let!(:decidim_response_option_id) { nil } # otherwise it will try to use condition_question overridden in previous line

          it { is_expected.not_to be_valid }
        end

        context "when the condition_type is not present" do
          let!(:condition_type) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the condition_value is missing a locale translation" do
          let(:condition_type) { :match }

          before do
            condition_value[:en] = ""
          end

          it { is_expected.not_to be_valid }
        end

        context "when question is the first in the questionnaire" do
          let!(:question) { create(:questionnaire_question, position: 0) }

          it { is_expected.not_to be_valid }
        end

        context "when response_option is not from condition_question" do
          let(:condition_type) { :equal }
          let(:response_option) { create(:response_option) }

          it { is_expected.not_to be_valid }
        end

        context "when response_option is mandatory" do
          let!(:condition_type) { :equal }
          let!(:decidim_response_option_id) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when it is deleted" do
          let!(:condition_type) { :equal }
          let!(:condition_value) { nil }
          let!(:decidim_response_option_id) { nil }

          before { subject.deleted = true }

          it { is_expected.to be_valid }
        end

        describe "#response_options" do
          context "when decidim_condition_question_id is set" do
            it { expect(subject.response_options).to match_array(condition_question.response_options) }
          end

          context "when decidim_condition_question_id is not set" do
            let!(:condition_question) { nil }
            let!(:response_option) { nil }

            it { expect(subject.response_options).to be_empty }
          end
        end

        describe "#questions_for_select" do
          let(:questions_for_select) { subject.questions_for_select(questionnaire, question.id) }

          it "returns an array of arrays containing translated body, id, and a hash" do
            expect(questions_for_select.first.first).to eq(questionnaire.questions.first.translated_body)
            expect(questions_for_select.first.second).to eq(questionnaire.questions.first.id)
            expect(questions_for_select.first.third).to be_a(Hash)
          end

          it "attaches a 'data-type' attribute to every question with its question_type" do
            expect(questions_for_select.map { |q| q.last["data-type"] }).to match_array(questionnaire.questions.pluck(:question_type))
          end

          it "disables current question" do
            this_question = questions_for_select.find { |q| q.second == decidim_question_id }
            expect(this_question.last["disabled"]).to be true
          end
        end

        describe "#question" do
          context "when decidim_question_id is set" do
            it { expect(subject.question).to eq(question) }
          end

          context "when decidim_question_id is not set" do
            let!(:question) { nil }

            it { expect(subject.question).to be_nil }
          end
        end

        describe "#condition_question" do
          context "when decidim_condition_question_id is set" do
            it { expect(subject.condition_question).to eq(condition_question) }
          end

          context "when decidim_condition_question_id is not set" do
            let!(:condition_question) { nil }
            let!(:response_option) { nil }

            it { expect(subject.condition_question).to be_nil }
          end
        end

        describe "#response_option" do
          context "when decidim_response_option_id is set" do
            it { expect(subject.response_option).to eq(response_option) }
          end

          context "when decidim_response_option_id is not set" do
            let!(:response_option) { nil }

            it { expect(subject.response_option).to be_nil }
          end
        end

        it_behaves_like "form to param", default_id: "questionnaire-display-condition-id"
      end
    end
  end
end
