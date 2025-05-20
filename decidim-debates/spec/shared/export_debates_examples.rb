# frozen_string_literal: true

shared_examples "export debates" do
  let!(:debates) { create_list(:debate, 3, component: current_component) }

  let(:export_type) { "Export all" }

  it_behaves_like "export as CSV"
  it_behaves_like "export as JSON"

  it "exports a CSV" do
    expect(Decidim::PrivateExport.count).to eq(0)
    find("a", text: export_type).click
    perform_enqueued_jobs do
      click_on "Comments as CSV"
      sleep 1
    end

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "debate_comments" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("debate_comments")
  end

  it "exports a JSON" do
    expect(Decidim::PrivateExport.count).to eq(0)
    find("a", text: export_type).click
    perform_enqueued_jobs do
      click_on "Comments as JSON"
      sleep 1
    end

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "debate_comments" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("debate_comments")
  end
end

shared_examples "export as CSV" do
  it "exports a CSV" do
    expect(Decidim::PrivateExport.count).to eq(0)
    find("a", text: export_type).click
    perform_enqueued_jobs do
      click_on "Debates as CSV"
      sleep 1
    end

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "debates" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("debates")
  end
end

shared_examples "export as JSON" do
  it "exports a JSON" do
    expect(Decidim::PrivateExport.count).to eq(0)

    find("a", text: export_type).click
    perform_enqueued_jobs do
      click_on "Debates as JSON"
      sleep 1
    end

    expect(page).to have_admin_callout "Your export is currently in progress. You will receive an email when it is complete."
    expect(last_email.subject).to eq(%(Your export "debates" is ready))
    expect(Decidim::PrivateExport.count).to eq(1)
    expect(Decidim::PrivateExport.last.export_type).to eq("debates")
  end
end
