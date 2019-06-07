# frozen_string_literal: true

require "spec_helper"

describe "logs", type: :system do
  let(:admin) { create(:admin) }

  context "when an admin authenticated" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
    end

    describe "visiting log path" do
      before do
        click_link "Logs"
      end

      it "display logs page" do
        expect(page).to have_link("View 50 lines")
        expect(page).to have_link("View 100 lines")
        expect(page).to have_link("View 200 lines")
        expect(page).to have_link("View 300 lines")
        expect(page).to have_link("View 1000 lines")
        expect(page).to have_link("Download log")
      end
    end
  end
end
