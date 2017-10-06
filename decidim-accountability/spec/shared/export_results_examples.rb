# frozen_string_literal: true

shared_examples "export results", perform_enqueued: true do
  let!(:results) { create_list :result, 3, feature: current_feature }

  it "exports a CSV" do
    find(".exports.dropdown").click
    click_link "Results as CSV"

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("results", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^results.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports.dropdown").click
    click_link "Results as JSON"

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("results", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^results.*\.zip$/)
  end
end
