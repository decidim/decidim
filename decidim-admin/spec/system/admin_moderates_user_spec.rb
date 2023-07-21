# frozen_string_literal: true

require "spec_helper"

describe "Admin reports user", type: :system do
  let(:admin) { create(:user, :confirmed, :admin) }
  let(:reportable) { create(:user, :confirmed, organization: admin.organization) }
  let(:reportable_path) { decidim.profile_path(reportable.nickname) }

  before do
    allow(Decidim).to receive(:redesign_active).and_return(true)
    switch_to_host(admin.organization.host)
    login_as admin, scope: :user
  end

  context "when chooses to block user" do
    it "is redirected to admin panel" do
      visit reportable_path

      selector = Decidim.redesign_active ? ".profile__actions-secondary" : ".profile--sidebar"
      expect(page).to have_selector(selector)

      within selector, match: :first do
        click_button
      end

      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        find(:css, "input[name='report[block]']").set(true)
        expect(page).to have_field(name: "report[block]", visible: :visible)
        expect(page).to have_field(name: "report[hide]", visible: :visible)
        click_button I18n.t("decidim.shared.flag_user_modal.block")
      end

      expect(page).to have_current_path(decidim_admin.new_user_block_path(user_id: reportable.id), ignore_query: true)
    end
  end

  context "when chooses to hide user" do
    it "is redirected to admin panel" do
      visit reportable_path

      selector = Decidim.redesign_active ? ".profile__actions-secondary" : ".profile--sidebar"
      expect(page).to have_selector(selector)

      within selector, match: :first do
        click_button
      end

      expect(page).to have_css(".flag-modal", visible: :visible)

      within ".flag-modal" do
        find(:css, "input[name='report[block]']").set(true)
        find(:css, "input[name='report[hide]']").set(true)
        expect(page).to have_field(name: "report[block]", visible: :visible)
        expect(page).to have_field(name: "report[hide]", visible: :visible)
        click_button I18n.t("decidim.shared.flag_user_modal.block")
      end

      expect(page).to have_current_path(decidim_admin.new_user_block_path(user_id: reportable.id), ignore_query: true)
      expect(page).to have_content("Continuing with this action you will also hide all the participants contents")
    end
  end

  it_behaves_like "hideable resource during block"
end
