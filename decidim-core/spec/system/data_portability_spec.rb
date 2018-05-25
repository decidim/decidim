# frozen_string_literal: true

require "spec_helper"

describe "DataPortability", type: :system do
  let(:user) { create(:user, :confirmed, password: "password1234", password_confirmation: "password1234", name: "Hodor User") }
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when on the data portability page" do
    before do
      visit decidim.data_portability_path
    end

    describe "show button export data" do
      it "export the user's data" do
        within ".row.data-portability" do
          expect(page).to have_content("Download the data")
          expect(page).to have_content(user.email)
        end
      end
    end

    describe "Export data" do
      it "exports a ZIP with all user information" do
        perform_enqueued_jobs { click_button "Request data" }

        within_flash_messages do
          expect(page).to have_content("Your data is currently in progress")
        end

        expect(last_email.subject).to include("Hodor User")
      end
    end
  end
end
