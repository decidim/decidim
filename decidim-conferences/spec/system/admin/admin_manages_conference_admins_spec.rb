# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference admins" do
  include_context "when admin administrating a conference"

  it_behaves_like "manage conference admins examples"

  context "when visiting as space admin" do
    let!(:user) do
      create(:conference_admin,
             :confirmed,
             organization:,
             conference:)
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_conferences.edit_conference_path(conference)
      within_admin_sidebar_menu do
        click_on "Conference admins"
      end
    end

    it "shows conference admin list" do
      within "#conference_admins table" do
        expect(page).to have_content(user.email)
      end
    end
  end
end
