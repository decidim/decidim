# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveyUserAnswersSerializer do
      let!(:survey) { create(:survey) }
      let!(:user) { create(:user, organization: survey.feature.organization) }
      let!(:survey_questions) { create_list :survey_question, 3, survey: survey }
      let!(:survey_answers) do
        survey_questions.map do |question|
          create :survey_answer, survey: survey, question: question, user: user
        end
      end

      subject do
        described_class.new(survey_answers)
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "includes the answer for each question" do
          survey_questions.each_with_index do |question, idx|
            expect(serialized).to include(
              "#{idx + 1}. #{translated(question.body, locale: I18n.locale)}" => survey_answers[idx].body
            )
          end
        end
      end
    end
  end
end
