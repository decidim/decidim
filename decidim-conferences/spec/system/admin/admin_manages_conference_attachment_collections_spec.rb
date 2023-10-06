# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference attachment collections examples", type: :system do
  include_context "when admin administrating a conference"

  let(:collection_for) { conference }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.edit_conference_path(conference)
    within_admin_sidebar_menu do
      click_link "Folders"
    end
  end

  it_behaves_like "manage attachment collections examples"
end
