# frozen_string_literal: true

shared_examples "export results" do
  include_context "when managing an accountability component as an admin"

  let!(:results) { create_list(:result, 3, component: current_component) }

  it "exports a CSV" do
    find(".exports").click
    perform_enqueued_jobs { click_link "Results as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("results", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^results.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports").click
    perform_enqueued_jobs { click_link "Results as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("results", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^results.*\.zip$/)
  end
end
