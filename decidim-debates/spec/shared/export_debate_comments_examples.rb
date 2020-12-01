# frozen_string_literal: true

shared_examples "export debates comments" do
  let!(:debates) { create_list :debate, 3, component: current_component }

  it "exports a CSV" do
    find(".exports.dropdown").click
    perform_enqueued_jobs { click_link "Comments as CSV" }

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("comments", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^comments.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports.dropdown").click
    perform_enqueued_jobs { click_link "Comments as JSON" }

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("comments", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^comments.*\.zip$/)
  end
end
