# frozen_string_literal: true

shared_examples "reports" do
  context "when the user is not logged in" do
    it "gives the option to sign in" do
      visit reportable_path

      expect(page).to have_no_css("html.is-reveal-open")

      click_button "Report"

      expect(page).to have_css("html.is-reveal-open")
    end
  end

  context "when the admin is logged in" do
    let!(:admin) { create(:user, :admin, :confirmed, organization: user.organization) }
    before do
      login_as admin, scope: :user
    end

    context "and the admin reports the resource" do
      it "reports the resource" do
        visit reportable_path

        expect(page).to have_selector(".author-data__extra")

        within ".author-data__extra", match: :first do
          page.find("button").click
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        within ".flag-modal" do
          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end
    end

    context "and the admin hides the resource" do
      around do |example|
        previous = Capybara.raise_server_errors

        Capybara.raise_server_errors = false
        example.run
        Capybara.raise_server_errors = previous
      end

      it "reports the resource" do
        visit reportable_path

        expect(page).to have_selector(".author-data__extra")

        within ".author-data__extra", match: :first do
          page.find("button").click
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        within ".flag-modal" do
          find(:css, "input[name='report[hide]']").set(true)
          click_button "Hide"
        end

        expect(reportable.reload).to be_hidden
      end
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

        expect(page).to have_selector(".author-data__extra")

        within ".author-data__extra", match: :first do
          page.find("button").click
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        expect(page).to have_content "already reported"
      end
    end
  end
end
