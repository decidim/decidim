# frozen_string_literal: true
require "spec_helper"

describe "Admin invite", type: :feature do
  let(:form) do
    Decidim::System::RegisterOrganizationForm.new(params)
  end

  let(:params) do
    {
      name: "Gotham City",
      host: "decide.lvh.me",
      organization_admin_name: "Fiorello Henry La Guardia",
      organization_admin_email: "f.laguardia@gotham.gov",
      welcome_text_en: "Welcome",
      homepage_image: Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "..", "decidim-dev", "spec", "support", "city.jpeg"), "image/jpg"),
      available_locales: ["en"],
      default_locale: "en"
    }
  end

  before(:each) do
    expect{ Decidim::System::RegisterOrganization.new(form).call }.to broadcast(:ok)
    switch_to_host("decide.lvh.me")
  end

  describe "Accept an invitation", perform_enqueued: true do
    it "asks for a password and redirects to the organization dashboard" do
      visit last_email_link

      within "form.new_user" do
        fill_in :user_password, with: "123456"
        fill_in :user_password_confirmation, with: "123456"
        find("*[type=submit]").click
      end

      expect(page).to have_content("Dashboard")
    end
  end
end
