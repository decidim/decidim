# frozen_string_literal: true
require "spec_helper"

describe "Homepage", type: :feature do
  context "visiting the homepage" do
    before(:each) do
      visit decidim.root_path
    end

    it "has header text 'Decidim'" do
      within("h1") { expect(page).to have_content("Decidim") }
    end
  end
end
