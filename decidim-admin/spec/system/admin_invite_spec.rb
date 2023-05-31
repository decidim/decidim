# frozen_string_literal: true

require "spec_helper"

describe "Admin invite", type: :system do
  let(:form) do
    Decidim::System::RegisterOrganizationForm.new(params)
  end

  let(:params) do
    {
      name: "Gotham City",
      reference_prefix: "JKR",
      host: "decide.lvh.me",
      organization_admin_name: "Fiorello Henry La Guardia",
      organization_admin_email: "f.laguardia@example.org",
      available_locales: ["en"],
      default_locale: "en",
      users_registration_mode: "enabled",
      smtp_settings: {
        "address" => "decide.lvh.me",
        "port" => "25",
        "user_name" => "f.laguardia",
        "password" => Decidim::AttributeEncryptor.encrypt("password"),
        "from" => "no-reply@example.org"
      },
      file_upload_settings: Decidim::OrganizationSettings.default(:upload)
    }
  end

  before do
    expect do
      perform_enqueued_jobs { Decidim::System::RegisterOrganization.new(form).call }
    end.to broadcast(:ok)

    switch_to_host("decide.lvh.me")
  end

  describe "Accept an invitation" do
    it "asks for a password and nickname and redirects to the organization dashboard" do
      visit last_email_link

      within "form.new_user" do
        fill_in :invitation_user_nickname, with: "caballo_loco"
        fill_in :invitation_user_password, with: "decidim123456789"
        fill_in :invitation_user_password_confirmation, with: "decidim123456789"
        check :invitation_user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_selector ".callout--full"

      within ".callout--full" do
        page.find(".close-button").click
      end

      expect(page).to have_content("Dashboard")
      expect(page).to have_current_path "/admin/"
    end
  end
end
