# frozen_string_literal: true

shared_examples "export debates" do
  let!(:debates) { create_list(:debate, 3, component: current_component) }

  let(:export_type) { "Export all" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"

  it "exports a CSV" do
    find(".exports").click
    perform_enqueued_jobs { click_on "Comments as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("debate_comments", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^debate_comments.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports").click
    perform_enqueued_jobs { click_on "Comments as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("debate_comments", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^debate_comments.*\.zip$/)
  end
end

shared_examples "export as CSV" do
  it "exports a CSV" do
    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_on "Debates as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("debates", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^debates.*\.zip$/)
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_on "Debates as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("debates", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^debates.*\.zip$/)
  end
end
