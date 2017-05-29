# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "reports" do
  context "when the user is not logged in" do
    it "should be given the option to sign in" do
      visit reportable_path

      expect(page).to have_selector(".author-data__extra")

      within ".author-data__extra", match: :first do
        page.find("button").click
      end

      expect(page).to have_css("#loginModal", visible: true)
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "and the user has not reported the resource yet" do
      it "reports the resource" do
        visit reportable_path

        expect(page).to have_selector(".author-data__extra")

        within ".author-data__extra", match: :first do
          page.find("button").click
        end

        expect(page).to have_css(".flag-modal", visible: true)

        within ".flag-modal" do
          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end
    end

    context "and the user has reported the resource previously" do
      before do
        moderation = create(:moderation, reportable: reportable, participatory_process: participatory_process)
        create(:report, moderation: moderation, user: user, reason: "spam")
      end

      it "cannot report it twice" do
        visit reportable_path

        expect(page).to have_selector(".author-data__extra")

        within ".author-data__extra", match: :first do
          page.find("button").click
        end

        expect(page).to have_css(".flag-modal", visible: true)

        expect(page).to have_content "already reported"
      end
    end
  end
end
