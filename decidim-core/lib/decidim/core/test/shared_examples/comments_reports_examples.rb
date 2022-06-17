# frozen_string_literal: true

shared_examples "comments_reports" do
  context "when the user is not logged in" do
    it "gives the option to sign in" do
      visit reportable_path

      expect(page).to have_no_css("html.is-reveal-open")

      within ".comment__header__context-menu" do
        page.find(".icon--ellipses").click
      end

      click_button "Report"

      expect(page).to have_css("html.is-reveal-open")
    end
  end

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "and the user has not reported the resource yet" do
      it "reports the resource" do
        visit reportable_path

        expect(page).to have_selector(".comment__header__context-menu")

        within ".comment__header__context-menu" do
          page.find(".icon--ellipses").click
          click_button "Report"
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        within ".flag-modal" do
          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end
    end

    context "and the user has reported the resource previously" do
      before do
        moderation = create(:moderation, reportable:, participatory_space: participatory_process)
        create(:report, moderation:, user:, reason: "spam")
      end

      it "cannot report it twice" do
        visit reportable_path

        expect(page).to have_selector(".comment__header__context-menu")

        within ".comment__header__context-menu" do
          page.find(".icon--ellipses").click
          click_button "Report"
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        expect(page).to have_content "already reported"
      end
    end
  end
end
