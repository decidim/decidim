# frozen_string_literal: true

require "spec_helper"

describe "TOS" do
  let(:organization) { create(:organization) }
  let!(:terms_of_service_page) { Decidim::StaticPage.find_by(slug: "terms-of-service", organization:) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when in registration form" do
    it "show tos checkbox" do
      within("div#card__tos") do
        expect(page).to have_content("Terms of Service")
        expect(page).to have_css("label[for=\"registration_user_tos_agreement\"]")
        expect(page).to have_field(id: "registration_user_tos_agreement")
      end
    end

    it "show tos checkbox separaterly from other input elements" do
      within("div#card__tos") do
        expect(page).not_to have_css("input:not(#registration_user_tos_agreement)")
      end
    end
  end
end
