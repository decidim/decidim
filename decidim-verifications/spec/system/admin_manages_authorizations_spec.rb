# frozen_string_literal: true

require "spec_helper"
describe "Admin manages authorizations users" do
  let!(:organization) { create(:organization, available_authorizations:) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path
    click_on "Participants"
    within_admin_sidebar_menu do
      click_on "Authorizations"
    end
  end

  context "when multiple authorization handlers are available" do
    let(:available_authorizations) { %w(id_documents postal_letter csv_census dummy_authorization_handler another_dummy_authorization_handler sms) }

    it "displays the menu entries" do
      within ".sidebar-menu" do
        expect(page).to have_content("Identity documents")
        expect(page).to have_content("Code by postal letter")
        expect(page).to have_content("Organization's census")
      end
    end

    it "displays main view entries" do
      within ".item_show__wrapper" do
        expect(page).to have_content("Identity documents")
        expect(page).to have_content("Code by postal letter")
        expect(page).to have_content("Organization's census")
        expect(page).to have_content("Example authorization")
        expect(page).to have_content("Another example authorization")
        expect(page).to have_content("Code by SMS")
      end
    end
  end

  context "when single authorization handler is unavailable" do
    let(:available_authorizations) { %w(id_documents csv_census) }

    it "displays the menu entries" do
      within ".sidebar-menu" do
        expect(page).to have_content("Identity documents")
        expect(page).to have_content("Organization's census")
        expect(page).to have_no_content("Code by postal letter")
      end
    end

    it "displays main view entries" do
      within ".item_show__wrapper" do
        expect(page).to have_content("Identity documents")
        expect(page).to have_content("Organization's census")
        expect(page).to have_no_content("Code by postal letter")
        expect(page).to have_no_content("Example authorization")
        expect(page).to have_no_content("Another example authorization")
        expect(page).to have_no_content("Code by SMS")
      end
    end
  end

  context "when no authorization handler is unavailable" do
    let(:available_authorizations) { [] }

    it "displays the menu entries" do
      within ".sidebar-menu" do
        expect(page).to have_no_content("Identity documents")
        expect(page).to have_no_content("Code by postal letter")
        expect(page).to have_no_content("Organization's census")
      end
    end

    it "displays main view entries" do
      within ".item_show__wrapper" do
        expect(page).to have_no_content("Identity documents")
        expect(page).to have_no_content("Code by postal letter")
        expect(page).to have_no_content("Organization's census")
        expect(page).to have_no_content("Example authorization")
        expect(page).to have_no_content("Another example authorization")
        expect(page).to have_no_content("Code by SMS")
      end
    end
  end
end
