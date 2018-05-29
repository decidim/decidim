# frozen_string_literal: true

require "spec_helper"

describe "TOS", type: :system do
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { create(:static_page, slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when in registration form" do
    it "show tos checkbox" do
      within("div#card__tos") do
        expect(page).to have_content("Terms of Service")
        expect(page).to have_css("label[for=\"user_tos_agreement\"]")
        expect(page).to have_css("input#user_tos_agreement")
      end
    end

    it "show tos checkbox separaterly from other input elements" do
      within("div#card__tos") do
        expect(page).not_to have_css("input:not(#user_tos_agreement)")
      end
    end
  end
end
