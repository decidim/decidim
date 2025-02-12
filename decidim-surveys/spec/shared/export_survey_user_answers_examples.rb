# frozen_string_literal: true

shared_examples "export survey user answers" do
  let!(:questionnaire) { create(:questionnaire) }
  let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
  let!(:answers) do
    questions.map do |question|
      create_list(:answer, 3, questionnaire:, question:)
    end.flatten
  end

  it "exports a CSV" do
    visit_component_admin
    click_on "Manage questions"

    find(".exports").click
    expect(Decidim::PrivateExport.count).to eq(0)

    perform_enqueued_jobs { click_on "CSV" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    expect(last_email.subject).to eq(%(Your export "survey_user_answers" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_answers")
  end

  it "exports a JSON" do
    visit_component_admin
    click_on "Manage questions"

    find(".exports").click
    expect(Decidim::PrivateExport.count).to eq(0)

    perform_enqueued_jobs { click_on "JSON" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")
    expect(last_email.subject).to eq(%(Your export "survey_user_answers" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_answers")
  end

  it "exports a PDF" do
    visit_component_admin
    click_on "Manage questions"

    find(".exports").click
    expect(Decidim::PrivateExport.count).to eq(0)

    perform_enqueued_jobs { click_on "PDF" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    expect(last_email.subject).to eq(%(Your export "survey_user_answers" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_answers")
  end
end
