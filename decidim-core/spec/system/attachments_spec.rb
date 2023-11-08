# frozen_string_literal: true

require "spec_helper"

describe "Attachment spec", type: :system do
  let(:user) { create(:user, :confirmed) }
  let(:organization) { user.organization }
  let(:file_location) { Decidim::Dev.asset("import_proposals.csv") }
  let(:filename) { file_location.to_s.split("/").last }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.account_path
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  it "Enqueues the cleanup job" do
    find("#user_avatar_button").click

    within ".upload-modal" do
      click_remove(true)
      input_element = find("input[type='file']", visible: :all)
      input_element.attach_file(file_location)
      within "[data-filename='#{filename}']" do
        expect(page).to have_css(filled_selector(true), wait: 5)
        expect(page).to have_content(filename.first(12))
      end
    end
    expect(Decidim::CleanUnattachedBlobJob).to have_been_enqueued
  end
end
