# frozen_string_literal: true

shared_examples "export survey user responses" do
  let!(:questionnaire) { create(:questionnaire) }
  let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
  let!(:responses) do
    questions.map do |question|
      create_list(:response, 3, questionnaire:, question:)
    end.flatten
  end

  it "exports a CSV" do
    visit_component_admin
    click_on "Questions"
    click_on "Responses"

    find(".exports").click
    expect(Decidim::PrivateExport.count).to eq(0)

    perform_enqueued_jobs { click_on "CSV" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    sleep 0.5
    expect(last_email.subject).to eq(%(Your export "survey_user_responses" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_responses")
  end

  it "exports a JSON" do
    visit_component_admin
    click_on "Questions"
    click_on "Responses"

    find(".exports").click
    expect(Decidim::PrivateExport.count).to eq(0)

    perform_enqueued_jobs { click_on "JSON" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    sleep 0.5
    expect(last_email.subject).to eq(%(Your export "survey_user_responses" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_responses")
  end

  it "exports a PDF" do
    visit_component_admin
    click_on "Questions"
    click_on "Responses"

    find(".exports").click
    expect(Decidim::PrivateExport.count).to eq(0)

    perform_enqueued_jobs { click_on "PDF" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    sleep 0.5
    expect(last_email.subject).to eq(%(Your export "survey_user_responses" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_responses")
  end
end
