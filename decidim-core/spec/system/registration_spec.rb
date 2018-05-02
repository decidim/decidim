# frozen_string_literal: true

require "spec_helper"

describe "Registration", type: :system do
  let(:organization) { create(:organization) }
  let!(:terms_and_conditions_page) { create(:static_page, slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_registration_path
  end

  context "when on the sign up page" do
    before do
    end

    describe "on first sight" do
      it "fields must be empty" do
        expect(page).to have_content("Sign up as")

        expect(page).to have_field("user_name", with: "")
        expect(page).to have_field("user_nickname", with: "")
        expect(page).to have_field("user_email", with: "")
        expect(page).to have_field("user_password", with: "")
        expect(page).to have_field("user_password_confirmation", with: "")
        expect(page).to have_field("user_newsletter", checked: false)
      end
    end
  end

  context "when submit fails" do
    before do
      fill_in :user_name, with: "Nikola Tesla"
      fill_in :user_nickname, with: "the-best-genius-in-history"
      fill_in :user_email, with: "https://example.org"
      fill_in :user_password, with: "sekritpass123"
      fill_in :user_password_confirmation, with: "sekritpass123"
    end

    it "keeps the user newsletter checkbox false value" do
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_field("user_newsletter", checked: false)
    end

    it "keeps the user newsletter checkbox true value" do
      page.check("user_newsletter")
      within "form.new_user" do
        find("*[type=submit]").click
      end
      expect(page).to have_field("user_newsletter", checked: true)
    end
  end
end
