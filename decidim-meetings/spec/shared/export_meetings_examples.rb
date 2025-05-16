# frozen_string_literal: true

shared_examples "export meetings" do
  let!(:meetings) { create_list(:meeting, 3, :published, component: current_component) }
  let(:export_type) { "Export all" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"

  context "with query" do
    before do
      fill_in "q[id_string_or_title_cont]", with: translated(meetings.last.title)
      find("button[aria-label='Search']").click
    end

    let(:export_type) { "Export selection" }

    it_behaves_like "export as CSV"
    it_behaves_like "export as JSON"
  end
end

shared_examples "export as CSV" do
  it "exports a CSV" do
    expect(Decidim::PrivateExport.count).to eq(0)

    find("span.exports", text: export_type).click
    perform_enqueued_jobs do
      click_on "Meetings as CSV"
      sleep 1
    end

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "meetings" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("meetings")
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    expect(Decidim::PrivateExport.count).to eq(0)

    find("span.exports", text: export_type).click
    perform_enqueued_jobs do
      click_on "Meetings as JSON"
      sleep 1
    end

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "meetings" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("meetings")
  end
end
