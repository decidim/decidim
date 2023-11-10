# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference attachments" do
  include_context "when admin administrating a conference"

  let(:attached_to) { conference }
  let(:attachment_collection) { create(:attachment_collection, collection_for: conference) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
