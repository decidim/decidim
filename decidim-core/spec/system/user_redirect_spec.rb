# frozen_string_literal: true

require "spec_helper"

describe "UserRedirect", type: :system do
  before do
    switch_to_host(organization.host)
  end

  context "when organization has forced login" do
    let(:organization) { create :organization, force_users_to_authenticate_before_access_organization: true }

    let(:user) { create(:user, :confirmed, organization:) }

    context "when logging for the first time" do
      before do
        visit decidim.pages_path

        within "form.new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "decidim123456789"
          find("*[type=submit]").click
        end
      end

      it "redirects the user to the page attempted to access before login" do
        expect(page).to have_css("h1.h1", text: "Help")
      end
    end
  end
end
