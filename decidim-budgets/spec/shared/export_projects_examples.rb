# frozen_string_literal: true

shared_examples "export projects" do
  let!(:projects) { create_list(:project, 5, budget:) }
  let(:export_type) { "Export all" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"

  context "with query" do
    before do
      fill_in "q[id_string_or_title_cont]", with: translated(projects.last.title)
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
    perform_enqueued_jobs { click_link "Projects as CSV" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("projects", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^projects.*\.zip$/)
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    find("span.exports", text: export_type).click
    perform_enqueued_jobs { click_link "Projects as JSON" }

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to include("projects", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^projects.*\.zip$/)
  end
end
