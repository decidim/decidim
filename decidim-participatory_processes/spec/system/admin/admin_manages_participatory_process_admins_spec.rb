# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process admins" do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage process admins examples"

  context "when visiting as space admin" do
    let!(:user) do
      create(:process_admin,
             :confirmed,
             organization:,
             participatory_process:)
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
      within_admin_sidebar_menu do
        click_on "Process admins"
      end
    end

    it "shows process admin list" do
      within "#process_admins table" do
        expect(page).to have_content(user.email)
      end
    end
  end
end
