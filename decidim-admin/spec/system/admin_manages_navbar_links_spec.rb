# frozen_string_literal: true

require "spec_helper"

describe "Navbar Links", type: :system do
  include Decidim::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let(:target) { %w(navbar_link_target_blank navbar_link_target_).sample }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Settings"
    click_link "Navbar links"
  end

  describe "Managing navbar links" do
    it "can create new navbar links " do
      click_link "Add"

      within ".new_navbar_link " do
        fill_in_i18n :navbar_link_title,
                     "#navbar_link-title-tabs",
                     en: "My title",
                     es: "Mi título",
                     ca: "títol mon"
        fill_in "navbar_link_link", with: "http://example.org"
        fill_in "navbar_link_weight", with: "1"
        choose target
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("Success")
      within "table" do
        expect(page).to have_content("My title")
      end
    end

    context "with existing navbar links" do
      let!(:navbar_link) { create(:navbar_link, organization: organization) }

      before do
        visit current_path
      end

      it "lists all the links for navbar" do
        within "#navbar_links table" do
          expect(page).to have_content(translated(navbar_link.title, locale: :en))
          expect(page).to have_content(navbar_link.link)
          expect(page).to have_content(navbar_link.weight)
          expect(find_link(navbar_link.link)[:target]).to eq(navbar_link.target)
        end
      end

      it "can edit them" do
        within find("#navbar_link_#{navbar_link.id}", text: translated(navbar_link.title)) do
          click_link "Edit"
        end

        within ".new_navbar_link " do
          fill_in_i18n :navbar_link_title,
                       "#navbar_link-title-tabs",
                       en: "Another title",
                       es: "Otro título",
                       ca: "Altre títol"
          fill_in "navbar_link_link", with: "http://another-example.org"
          fill_in "navbar_link_weight", with: "9"
          choose target
          find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("Success")

        within "table" do
          expect(page).to have_content("Another title")
        end
      end

      it "can delete them" do
        within find("#navbar_link_#{navbar_link.id}", text: translated(navbar_link.title)) do
          accept_confirm { click_link "Delete" }
        end
        expect(page).to have_admin_callout("Success")
        within ".card-section" do
          expect(page).to have_content("No links")
        end
      end
    end
  end
end
