# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim
  module Forms
    module Admin
      describe DisplayConditionForm do
        subject do
          described_class.new(question: question,
                              condition_question: condition_question,
                              condition_value: condition_value,
                              condition_type: condition_type,
                              answer_option: answer_option,
                              position: position,
                              mandatory: true,
                              deleted: false).with_context(current_organization: organization)
        end

        let(:organization) { create(:organization) }
        let(:condition_question) { create(:questionnaire_question, position: 1) }
        let(:question) { create(:questionnaire_question, position: 2) }
        let(:answer_option) { create(:answer_option, question: condition_question) }

        let(:position) { 1 }
        let(:condition_type) { :answered }
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

        context "when question is not present" do
          let!(:question) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when condition_question is not present" do
          let!(:condition_question) { nil }
          let!(:answer_option) { nil } # otherwise it will try to use condition_question overriden in previous line

          it { is_expected.not_to be_valid }
        end

        context "when the condition_type is not present" do
          let!(:condition_type) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the position is not present" do
          let!(:position) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the condition_value is missing a locale translation" do
          let(:condition_type) { :match }

          before do
            condition_value[:en] = ""
          end

          it { is_expected.not_to be_valid }
        end

        context "when condition_question is positioned before question" do
          before do
            question.position = condition_question.position - 1
          end

          it { is_expected.not_to be_valid }
        end

        context "when answer_option is not from condition_question" do
          let(:condition_type) { :equal }
          let(:answer_option) { create(:answer_option) }

          it { is_expected.not_to be_valid }
        end

        context "when answer_option is mandatory" do
          let!(:condition_type) { :equal }
          let!(:answer_option) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when it is deleted" do
          let!(:condition_type) { :equal }
          let!(:condition_value) { nil }
          let!(:answer_option) { nil }

          before do
            subject.deleted = true
          end

          it { is_expected.to be_valid }
        end

        it_behaves_like "form to param", default_id: "questionnaire-display-condition-id"
      end
    end
  end
end
