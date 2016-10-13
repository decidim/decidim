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
      organization_admin_email: "f.laguardia@gotham.gov"
    }
  end

  before(:each) do
    Decidim::System::RegisterOrganization.new(form).call
    switch_to_host("decide.lvh.me")
  end

  describe "Accept an invitation", perform_enqueued: true do
    it "asks for a password and redirects to the organization dashboard" do
      visit last_email_link

      fill_in :user_password, with: "123456"
      fill_in :user_password_confirmation, with: "123456"
      find("*[type=submit]").click

      expect(page).to have_content("Dashboard")
    end
  end
end
