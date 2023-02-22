# frozen_string_literal: true

shared_examples "comments_reports" do
  context "when the user is not logged in" do
    it "gives the option to sign in" do
      visit reportable_path

      expect(page).to have_css("#loginModal", visible: false)

      # Open toolbar
      page.find(".comment__header details summary").click
      click_button "Report"

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

        # Open toolbar
        page.find(".comment__header details summary").click
        within "details" do
          click_button "Report"
        end

        expect(page).to have_css(".modal__report", visible: :visible)

        within ".modal__report" do
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

        # Open toolbar
        page.find(".comment__header details summary").click
        click_button "Report"

        expect(page).to have_css(".modal__report", visible: :visible)

        expect(page).to have_content "already reported"
      end
    end
  end
end
