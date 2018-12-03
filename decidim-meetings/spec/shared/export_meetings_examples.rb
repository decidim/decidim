# frozen_string_literal: true

shared_examples "export meetings" do
  let!(:meetings) { create_list :meeting, 3, component: current_component }

  it "exports a CSV" do
    find(".exports.dropdown").click
    perform_enqueued_jobs { click_link "Meetings as CSV" }

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("meetings", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^meetings.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports.dropdown").click
    perform_enqueued_jobs { click_link "Meetings as JSON" }

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("meetings", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^meetings.*\.zip$/)
  end
end
