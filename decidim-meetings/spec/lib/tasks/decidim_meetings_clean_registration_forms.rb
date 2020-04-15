# frozen_string_literal: true

require "spec_helper"

describe "decidim_meetings:clean_registration_forms", type: :task do
  let(:months) { 3 }
  let(:threshold) { Time.current - months.months }

  let(:end_time) { Time.current - 4.months }
  let(:meeting) { create(:meeting, end_time: end_time) }
  let(:questionnaire) { create(:questionnaire, :with_questions, questionnaire_for: meeting) }
  let(:answers) { questionnaire.questions.map { |q| create(:answer, questionnaire: questionnaire, question: q) } }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
    expect(task.prerequisites).to include "months"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  context "when a meeting has finished before the given threshold" do
    it "removes related questionnaires and answers but not the meeting itself" do
      expect(meeting.end_time).to be < threshold
      task.execute

      questionnaire.reload
      expect(questionnaire).to be_blank
      expect(answers).to be_blank
      expect(meeting).to be_present
    end
  end

  context "when a meeting has finished after the given threshold" do
    it "does not remove anything" do
      expect(meeting.end_time).to be >= threshold
      task.execute

      questionnaire.reload
      expect(questionnaire).to be_present
      expect(answers).to be_present
    end
  end
end
