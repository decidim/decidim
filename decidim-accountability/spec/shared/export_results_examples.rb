# frozen_string_literal: true

shared_examples "export results" do
  let!(:results) { create_list :result, 3, feature: current_feature }

  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

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
