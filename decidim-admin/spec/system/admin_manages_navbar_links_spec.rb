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

      expect(page).to have_admin_callout("successfully")
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
        end
      end

      context "when editing a link" do
        before do
          within find("#navbar_link_#{navbar_link.id}", text: translated(navbar_link.title)) do
            click_link "Edit"
          end
        end

        it "keep the existing link attributes" do
          expect(page).to have_content(translated(navbar_link.title, locale: :en))
          expect(page).to have_content(navbar_link.link)
          expect(page).to have_content(navbar_link.weight)
        end

        it "can edit them" do
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

          expect(page).to have_admin_callout("successfully")

          within "table" do
            expect(page).to have_content("Another title")
            expect(page).not_to have_content(translated(navbar_link.title, locale: :en))
          end
        end
      end

      it "can delete them" do
        within find("#navbar_link_#{navbar_link.id}", text: translated(navbar_link.title)) do
          accept_confirm { click_link "Destroy" }
        end
        expect(page).to have_admin_callout("successfully")
        within ".card-section" do
          expect(page).to have_content("No links created")
        end
      end
    end
  end
end
