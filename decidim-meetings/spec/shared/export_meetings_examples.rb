# frozen_string_literal: true

shared_examples "export meetings" do
  let!(:meetings) { create_list(:meeting, 3, :published, component: current_component) }

  it "exports a CSV" do
    find(".exports").click
    perform_enqueued_jobs { click_link "Meetings as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("meetings", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^meetings.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports").click
    perform_enqueued_jobs { click_link "Meetings as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("meetings", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^meetings.*\.zip$/)
  end
end
