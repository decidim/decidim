# frozen_string_literal: true

shared_examples "export proposals" do
  let!(:proposals) { create_list(:proposal, 3, component: current_component) }

  it "exports a CSV" do
    find(".exports").click
    perform_enqueued_jobs { click_link "Proposals as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("proposals", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^proposals.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports").click
    perform_enqueued_jobs { click_link "Proposals as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("proposals", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^proposals.*\.zip$/)
  end
end
