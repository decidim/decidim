# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference attachment collections examples" do
  include_context "when admin administrating a conference"

  let(:collection_for) { conference }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_on "Attachments"
    end
    click_on "Folders"
  end

  it_behaves_like "manage attachment collections examples"
end
