# frozen_string_literal: true

require "spec_helper"

describe "Invite process moderator", type: :feature do
  let(:form) do
    Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessUserRoleForm.from_params(params)
  end
  let(:participatory_process) { create :participatory_process }
  let(:organization) { participatory_process.organization }
  let(:user) { create :user, :admin, :confirmed, organization: participatory_process.organization }
  let(:email) { "this_email_does_not_exist@example.org" }
  let(:role) { "Moderator" }
  let(:params) do
    {
      name: "Alice Liddel",
      email: email,
      role: role
    }
  end

  before do
    switch_to_host organization.host
    login_as user, scope: :user

    visit decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_process)
    within ".container" do
      click_link "New"
    end

    fill_in "Name", with: "Alice Liddel"
    fill_in "Email", with: email
    select role, from: "Role"
    click_button "Create"
    logout :user
  end

  context "when the user does not exist" do
    describe "Accept an invitation", perform_enqueued: true do
      it "asks for a password and redirects to the admin dashboard" do
        visit last_email_link

        within "form.new_user" do
          fill_in :user_password, with: "123456"
          fill_in :user_password_confirmation, with: "123456"
          find("*[type=submit]").click
        end

        within ".callout-wrapper" do
          page.find(".close-button").click
        end

        expect(page).to have_content("DASHBOARD")
        expect(current_path).to eq "/admin/"
      end
    end
  end
end
