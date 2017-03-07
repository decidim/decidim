# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "reports" do
  context "when the user is not logged in" do
    it "should be given the option to sign in" do
      visit reportable_path

      within ".author-data__extra", match: :first do
        page.find('button').click
      end

      expect(page).to have_css('#loginModal', visible: true)
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "and the user has not reported the resource yet" do
      it "reports the resource" do
        visit reportable_path

        within ".author-data__extra", match: :first do
          page.find('button').click
        end

        expect(page).to have_css('#flagModal', visible: true)

        choose :report_reason_offensive

        within "#flagModal" do
          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end
    end

    context "and the user has reported the resource previously" do
      before do
        create(:report, reportable: reportable, user: user, reason: "spam")
      end

      it "cannot report it twice" do
        visit reportable_path

        within ".author-data__extra", match: :first do
          page.find('button').click
        end

        expect(page).to have_css('#flagModal', visible: true)

        expect(page).to have_content "already reported"
      end
    end
  end
end
