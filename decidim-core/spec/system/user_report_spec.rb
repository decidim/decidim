# frozen_string_literal: true

require "spec_helper"

describe "Report User", type: :system do
  let(:user) { create(:user, :confirmed) }
  let!(:users) { create_list(:user, 3, :confirmed, organization: user.organization) }
  let(:reportable) { users.first }
  let(:reportable_path) { decidim.profile_path(reportable.nickname) }

  before do
    switch_to_host(user.organization.host)
    login_as user, scope: :user
  end

  context "when the user is blocked" do
    let(:user) { create(:user, :confirmed, :blocked) }
    let(:admin) { create(:user, :admin, :confirmed, organization: user.organization) }
    let(:reportable_path) { decidim.profile_path(user.nickname) }

    before do
      switch_to_host(user.organization.host)
      login_as admin, scope: :user
      visit reportable_path
    end

    it "cannot be reported" do
      within ".profile--sidebar", match: :first do
        expect(page).not_to have_css(".user-report_link")
      end
    end
  end

  context "when the user is not logged in" do
    it "gives the option to sign in" do
      page.visit reportable_path

      expect(page).not_to have_css("html.is-reveal-open")

      click_button "Report"

      expect(page).to have_css("html.is-reveal-open")
    end
  end

  context "when admin is logged in" do
    let!(:user) { create(:user, :confirmed, :admin) }

    context "and the admin has not reported the resource yet" do
      it "reports the resource" do
        visit reportable_path

        expect(page).to have_selector(".profile--sidebar")

        within ".profile--sidebar", match: :first do
          click_button
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        within ".flag-modal" do
          expect(page).to have_field(name: "report[block]", visible: :visible)
          expect(page).not_to have_field(name: "report[hide]", visible: :visible)

          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end

      it "chooses to block the resource" do
        visit reportable_path

        expect(page).to have_selector(".profile--sidebar")

        within ".profile--sidebar", match: :first do
          click_button
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        within ".flag-modal" do
          find(:css, "input[name='report[block]']").set(true)
          expect(page).to have_field(name: "report[block]", visible: :visible)
          expect(page).to have_field(name: "report[hide]", visible: :visible)
          click_button "Block this participant"
        end

        expect(page).to have_content "report has been created"
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

        expect(page).to have_selector(".profile--sidebar")

        within ".profile--sidebar", match: :first do
          click_button
        end

        expect(page).to have_css(".flag-modal", visible: :visible)
        expect(page).not_to have_field(name: "report[block]", visible: :visible)
        expect(page).not_to have_field(name: "report[hide]", visible: :visible)

        within ".flag-modal" do
          click_button "Report"
        end

        expect(page).to have_content "report has been created"
      end
    end

    context "and the user has reported the resource previously" do
      before do
        user_moderation = create(:user_moderation, user: reportable)
        create(:user_report, moderation: user_moderation, user:, reason: "spam")
      end

      it "cannot report it twice" do
        visit reportable_path

        expect(page).to have_selector(".profile--sidebar")

        within ".profile--sidebar", match: :first do
          click_button
        end

        expect(page).to have_css(".flag-modal", visible: :visible)

        expect(page).to have_content "already reported"
      end
    end
  end
end
