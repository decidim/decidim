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

    perform_and_wait_for_enqueued_jobs { click_on "CSV" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

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

    perform_and_wait_for_enqueued_jobs { click_on "JSON" }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

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

    perform_and_wait_for_enqueued_jobs { click_on "PDF" }
    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    expect(last_email.subject).to eq(%(Your export "survey_user_responses" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_responses")
  end

  it "exports a single response" do
    visit_component_admin
    click_on "Questions"
    click_on "Responses"

    expect(Decidim::PrivateExport.count).to eq(0)

    perform_and_wait_for_enqueued_jobs { find(".action-icon--data-transfer-download", match: :first).click }

    expect(page).to have_admin_callout("Your export is currently in progress. You will receive an email when it is complete.")

    expect(last_email.subject).to eq(%(Your export "survey_user_responses" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("survey_user_responses")
  end

  private

  # there is a chance of a flaky spec here, as sometimes the jobs are not enqueued in the corect order
  # causing user's confirmations to be sent after the export is ready
  def perform_and_wait_for_enqueued_jobs(only: nil, except: nil, queue: nil, at: nil, &block)
    while enqueued_jobs.size.positive?
      perform_enqueued_jobs
      sleep 0.5
    end

    perform_enqueued_jobs(only:, except:, queue:, at:, &block)

    while enqueued_jobs.size.positive?
      perform_enqueued_jobs
      sleep 0.5
    end
  end
end
