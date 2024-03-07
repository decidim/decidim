# frozen_string_literal: true

shared_examples "export results" do
  include_context "when managing an accountability component as an admin"

  let!(:results) { create_list(:result, 3, component: current_component) }
  let(:export_type) { "Export all" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"

  context "with query" do
    before do
      fill_in "q[id_string_or_title_cont]", with: translated(results.last.title)
      find("button[aria-label='Search']").click
    end

    let(:export_type) { "Export selection" }

    it_behaves_like "export as CSV"
    it_behaves_like "export as JSON"
  end
end

shared_examples "export as CSV" do
  it "exports a CSV" do
    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_on "Results as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("results", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^results.*\.zip$/)
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_on "Results as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("results", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^results.*\.zip$/)
  end
end
