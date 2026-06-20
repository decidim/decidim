# frozen_string_literal: true

require "spec_helper"

describe "Load more comments" do
  let!(:organization) { create(:organization) }
  let!(:component) { create(:component, manifest_name: :dummy, organization:) }
  let!(:commentable) { create(:dummy_resource, component:) }
  let!(:comments) { create_list(:comment, 30, commentable:) }

  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
    visit resource_path
  end

  after do
    expect_no_js_errors
  end

  context "when there are more comments than the default limit" do
    it "shows the Load more comments button" do
      expect(page).to have_text("Load more comments")
    end

    it "loads more comments when clicking the button", :slow do
      expect(page).to have_css(".comment", count: 20)

      click_button "Load more comments"

      expect(page).to have_css(".comment", count: 30)
    end
  end

  context "when the locale is different than English" do
    before do
      visit resource_path

      within_language_menu do
        click_on "Castellano"
      end
    end

    it "shows the Load more comments button in the correct locale" do
      expect(page).to have_text("Cargar más comentarios")
    end

    it "loads more comments when clicking the button in the correct locale", :slow do
      expect(page).to have_css(".comment", count: 20)

      click_button "Cargar más comentarios"

      expect(page).to have_css(".comment", count: 30)
    end
  end
end
