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
      organization_admin_email: "f.laguardia@gotham.gov",
      available_locales: ["en"],
      default_locale: "en"
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
        fill_in :user_nickname, with: "caballo_loco"
        fill_in :user_password, with: "123456"
        fill_in :user_password_confirmation, with: "123456"
        check :user_tos_agreement
        find("*[type=submit]").click
      end

      expect(page).to have_selector ".callout--full"

      within ".callout--full" do
        page.find(".close-button").click
      end

      expect(page).to have_content("DASHBOARD")
      expect(page).to have_current_path "/admin/"
    end
  end
end
