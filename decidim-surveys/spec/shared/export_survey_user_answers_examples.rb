# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "export survey user answers" do
  let!(:survey_questions) { create_list :survey_question, 3, survey: survey }
  let!(:survey_answers) do
    survey_questions.map do |question|
      create_list :survey_answer, 3, survey: survey, question: question
    end.flatten
  end

  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  it "exports a CSV" do
    visit_feature_admin

    find(".exports.dropdown").click
    click_link "CSV"

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("survey_user_answers", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^survey_user_answers.*\.zip$/)
  end

  it "exports a JSON" do
    visit_feature_admin

    find(".exports.dropdown").click
    click_link "JSON"

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("survey_user_answers", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^survey_user_answers.*\.zip$/)
  end
end
