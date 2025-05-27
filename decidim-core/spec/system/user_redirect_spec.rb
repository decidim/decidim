# frozen_string_literal: true

require "spec_helper"

describe "UserRedirect" do
  before do
    switch_to_host(organization.host)
  end

  context "when organization has forced login" do
    let(:organization) { create(:organization, force_users_to_authenticate_before_access_organization: true) }

    let(:user) { create(:user, :confirmed, organization:) }

    context "when accessing manifest" do
      before do
        visit decidim.manifest_path(format: "webmanifest")
      end

      it "does not redirect to login page" do
        expect(page).to have_no_content("Log in")
      end

      it "renders a JSON with the manifest" do
        expect(page).to have_content("\"display\": \"standalone\"")
      end
    end

    context "when logging for the first time" do
      before do
        visit decidim.pages_path(locale: I18n.locale)

        within "form.new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "decidim123456789"
          find("*[type=submit]").click
        end
      end

      it "redirects the user to the page attempted to access before login" do
        expect(page).to have_css("h1.title-decorator", text: "Help")
      end
    end
  end
end
