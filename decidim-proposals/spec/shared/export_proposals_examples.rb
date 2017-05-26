# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "export proposals" do
  let!(:proposals) { create_list :proposal, 3, feature: current_feature }

  around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  it "exports a CSV" do
    find(".exports.dropdown").click
    click_link "CSV"

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("proposals", "csv")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^proposals.*\.zip$/)
  end

  it "exports a JSON" do
    find(".exports.dropdown").click
    click_link "JSON"

    within ".callout.success" do
      expect(page).to have_content("in progress")
    end

    expect(last_email.subject).to include("proposals", "json")
    expect(last_email.attachments.length).to be_positive
    expect(last_email.attachments.first.filename).to match(/^proposals.*\.zip$/)
  end
end
