# frozen_string_literal: true

require "spec_helper"

describe "Admin reports user" do
  let(:admin) { create(:user, :confirmed, :admin) }
  let(:reportable) { create(:user, :confirmed, organization: admin.organization) }
  let(:reportable_path) { decidim.profile_path(reportable.nickname, locale: I18n.locale) }

  before do
    switch_to_host(admin.organization.host)
    login_as admin, scope: :user
  end

  context "when chooses to block user" do
    it "is redirected to admin panel" do
      visit reportable_path

      expect(page).to have_css(".profile__actions-secondary")

      within ".profile__actions-secondary", match: :first do
        click_on "Report"
      end

      expect(page).to have_css(".flag-user-modal", visible: :visible)

      within ".flag-user-modal" do
        expect(page).to have_content("Report inappropriate participant")
        find(:css, "input[name='report[block]']").set(true)
        expect(page).to have_field(name: "report[block]", visible: :visible)
        expect(page).to have_field(name: "report[hide]", visible: :visible)
        click_on I18n.t("decidim.shared.flag_user_modal.block")
      end

      expect(page).to have_current_path(decidim_admin.new_user_block_path(user_id: reportable.id), ignore_query: true)
    end
  end

  context "when chooses to hide user" do
    it "is redirected to admin panel" do
      visit reportable_path

      expect(page).to have_css(".profile__actions-secondary")

      within ".profile__actions-secondary", match: :first do
        click_on "Report"
      end

      expect(page).to have_css(".flag-user-modal", visible: :visible)

      within ".flag-user-modal" do
        expect(page).to have_content("Report inappropriate participant")
        find(:css, "input[name='report[block]']").set(true)
        find(:css, "input[name='report[hide]']").set(true)
        expect(page).to have_field(name: "report[block]", visible: :visible)
        expect(page).to have_field(name: "report[hide]", visible: :visible)
        click_on I18n.t("decidim.shared.flag_user_modal.block")
      end

      expect(page).to have_current_path(decidim_admin.new_user_block_path(user_id: reportable.id), ignore_query: true)
      expect(page).to have_content("By continuing with this action, you will also hide all the participant's content.")
    end
  end

  it_behaves_like "hideable resource during block"
end
