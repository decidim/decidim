# frozen_string_literal: true

require "spec_helper"

describe "Admin invite", type: :feature do
  let(:form) do
    Decidim::System::RegisterOrganizationForm.new(params)
  end

  let(:homepage_image_path) do
    Decidim::Dev.asset("city.jpeg")
  end

  let(:params) do
    {
      name: "Gotham City",
      reference_prefix: "JKR",
      host: "decide.lvh.me",
      organization_admin_name: "Fiorello Henry La Guardia",
      organization_admin_email: "f.laguardia@gotham.gov",
      welcome_text_en: "Welcome",
      homepage_image: Rack::Test::UploadedFile.new(homepage_image_path, "image/jpg"),
      available_locales: ["en"],
      default_locale: "en"
    }
  end

  before do
    expect { Decidim::System::RegisterOrganization.new(form).call }.to broadcast(:ok)
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

      within ".callout-wrapper" do
        page.find(".close-button").click
      end

      expect(page).to have_content("DASHBOARD")
      expect(current_path).to eq "/admin/"
    end
  end
end
