# frozen_string_literal: true

shared_examples "export proposals" do
  let!(:proposals) { create_list :proposal, 3, feature: current_feature }

  it "exports a CSV" do
    find(".exports.dropdown").click
    perform_enqueued_jobs { click_link "Proposals as CSV" }

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("proposals", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^proposals.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports.dropdown").click
    perform_enqueued_jobs { click_link "Proposals as JSON" }

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("proposals", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^proposals.*\.zip$/)
  end
end
