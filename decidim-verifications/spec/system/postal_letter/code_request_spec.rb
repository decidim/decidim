# frozen_string_literal: true

require "spec_helper"

describe "Postal letter code request", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["postal_letter"])
  end

  let!(:user) { create(:user, :confirmed, organization:) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  let(:verification_metadata) do
    Decidim::Authorization.first.verification_metadata
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_postal_letter.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Request your verification code")
  end

  context "when requesting a code by postal letter" do
    before do
      fill_in "Full address", with: "C/ Milhouse, 3, 00000, Springfield (Monaco)"
      click_button "Send me a letter"
    end

    it "allows the user to request a code by postal letter to get verified" do
      expect(page).to have_content("Thanks! We'll send a verification code to your address")
    end

    context "and getting it sent" do
      before do
        relogin_as admin
        visit decidim_admin_postal_letter.root_path
      end

      it "shows the address as pending" do
        within "table" do
          expect(page).to have_content("C/ Milhouse, 3, 00000, Springfield (Monaco)")
        end
      end
    end
  end
end
