# frozen_string_literal: true

require "spec_helper"

describe "Invite process collaborator", type: :feature do
  include_context "invite process users"
  let(:role) { "Collaborator" }

  before do
    switch_to_host organization.host
  end

  context "when the user does not exist" do
    describe "Accept an invitation", perform_enqueued: true do
      before do
        invite_user
      end

      it "asks for a password and redirects to the admin dashboard" do
        visit last_email_link

        within "form.new_user" do
          fill_in :user_password, with: "123456"
          fill_in :user_password_confirmation, with: "123456"
          find("*[type=submit]").click
        end

        expect(current_path).to eq "/admin/"
        expect(page).to have_content("DASHBOARD")

        click_link "Processes"

        within "#processes" do
          expect(page).to have_i18n_content(participatory_process.title)
        end
      end
    end
  end

  context "when the user already exists" do
    describe "Accept an invitation", perform_enqueued: true do
      let(:email) { "collaborator@example.org" }
      let(:collaborator) { @collaborator }

      before do
        @collaborator = create :user, :confirmed, email: email, organization: organization
        invite_user
      end

      it "redirects the collaborator to the admin dashboard" do
        login_as collaborator, scope: :user

        visit decidim_admin.root_path
        expect(page).to have_content("DASHBOARD")

        click_link "Processes"

        within "#processes" do
          expect(page).to have_i18n_content(participatory_process.title)
        end
      end
    end
  end
end
