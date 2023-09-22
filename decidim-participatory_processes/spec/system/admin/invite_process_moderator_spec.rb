# frozen_string_literal: true

require "spec_helper"

describe "Invite process moderator", type: :system do
  include_context "when inviting process users"

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
        fill_in :invitation_user_nickname, with: "caballo_loco"
        fill_in :invitation_user_password, with: "decidim123456789"
        check :invitation_user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_current_path "/admin/admin_terms/show"

      visit decidim_admin.admin_terms_show_path
      find_button("I agree with the terms").click

      click_link "Processes"

      within "div.table-scroll" do
        expect(page).to have_i18n_content(participatory_process.title)
        click_link "Moderate"
      end

      within "div.process-title-content-breadcrumb-container-left" do
        expect(page).to have_css("span.process-title-content-breadcrumb", text: "Moderations")
      end
    end
  end

  context "when the user already exists" do
    let(:email) { "moderator@example.org" }

    let!(:moderator) do
      create(:user, :confirmed, :admin_terms_accepted, email:, organization:)
    end

    before do
      perform_enqueued_jobs { invite_user }
    end

    it "redirects the moderator to the admin dashboard" do
      login_as moderator, scope: :user

      visit decidim_admin.root_path

      click_link "Processes"

      within "div.table-scroll" do
        expect(page).to have_i18n_content(participatory_process.title)
        within find("tr", text: translated(participatory_process.title)) do
          click_link "Moderate"
        end
      end

      within "div.process-title-content-breadcrumb-container-left" do
        expect(page).to have_css("span.process-title-content-breadcrumb", text: "Moderations")
      end
    end
  end
end
