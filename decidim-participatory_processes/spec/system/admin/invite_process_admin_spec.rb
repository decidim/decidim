# frozen_string_literal: true

require "spec_helper"

describe "Invite process administrator", type: :system do
  include_context "when inviting process users"

  let(:role) { "Administrator" }

  before do
    switch_to_host organization.host
  end

  context "when the user does not exist" do
    before do
      perform_enqueued_jobs { invite_user }
    end

    it "asks for a password and nickname and redirects to the admin dashboard" do
      visit last_email_link

      within "form.new_user" do
        fill_in :user_nickname, with: "caballo_loco"
        fill_in :user_password, with: "123456"
        fill_in :user_password_confirmation, with: "123456"
        check :user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_current_path "/admin/"
      expect(page).to have_content("DASHBOARD")

      click_link "Processes"

      within "#processes" do
        expect(page).to have_i18n_content(participatory_process.title)
        click_link translated(participatory_process.title)
      end

      within ".secondary-nav" do
        expect(page.text).to eq "View public page\nInfo\nSteps\nComponents\nCategories\nAttachments\nFolders\nFiles\nProcess users\nModerations"
      end
    end
  end

  context "when the user already exists" do
    let(:email) { "administrator@example.org" }

    let!(:administrator) do
      create :user, :confirmed, email: email, organization: organization
    end

    before do
      perform_enqueued_jobs { invite_user }
    end

    it "redirects the administrator to the admin dashboard" do
      login_as administrator, scope: :user

      visit decidim_admin.root_path
      expect(page).to have_content("DASHBOARD")

      click_link "Processes"

      within "#processes" do
        expect(page).to have_i18n_content(participatory_process.title)
        click_link translated(participatory_process.title)
      end

      within ".secondary-nav" do
        expect(page.text).to eq "View public page\nInfo\nSteps\nComponents\nCategories\nAttachments\nFolders\nFiles\nProcess users\nModerations"
      end
    end
  end
end
