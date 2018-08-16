# frozen_string_literal: true

require "spec_helper"

describe "Admin manages officializations", type: :system do
  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Users"
  end

  describe "listing officializations" do
    let!(:officialized) { create(:user, :officialized, organization: organization) }

    let!(:not_officialized) { create(:user, organization: organization) }
    let!(:external_not_officialized) { create(:user) }

    before do
      click_link "Officializations"
    end

    it "shows each user and its officialization status" do
      expect(page).to have_selector("tr[data-user-id=\"#{officialized.id}\"]", text: officialized.name)
      expect(page).to have_selector("tr[data-user-id=\"#{officialized.id}\"]", text: "Officialized")

      expect(page).to have_no_selector("tr[data-user-id=\"#{external_not_officialized.id}\"]", text: not_officialized.name)

      expect(page).to have_selector("tr[data-user-id=\"#{not_officialized.id}\"]", text: not_officialized.name)
      expect(page).to have_selector("tr[data-user-id=\"#{not_officialized.id}\"]", text: "Not officialized")
    end
  end

  describe "officializating users" do
    context "when not yet officialized" do
      let!(:user) { create(:user, organization: organization) }

      before do
        click_link "Officializations"

        within "tr[data-user-id=\"#{user.id}\"]" do
          click_link "Officialize"
        end
      end

      it "officializes it with the standard badge" do
        click_button "Officialize"

        expect(page).to have_content("officialized successfully")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_content("Officialized")
        end
      end

      it "officializes it with a custom badge" do
        fill_in_i18n(
          :officialization_officialized_as,
          "#officialization-officialized_as-tabs",
          en: "Major of Barcelona",
          es: "Alcaldesa de Barcelona"
        )

        click_button "Officialize"

        expect(page).to have_content("officialized successfully")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_content("Officialized").and have_content("Major of Barcelona")
        end
      end
    end

    context "when officialized already" do
      let!(:user) do
        create(
          :user,
          :officialized,
          officialized_as: { "en" => "Mayor of Barcelona" },
          organization: organization
        )
      end

      before do
        click_link "Officializations"

        within "tr[data-user-id=\"#{user.id}\"]" do
          click_link "Reofficialize"
        end
      end

      it "allows changing the officialization label" do
        expect(page).to have_field("officialization_officialized_as_en", with: "Mayor of Barcelona")

        fill_in_i18n(
          :officialization_officialized_as,
          "#officialization-officialized_as-tabs",
          en: "Major of Barcelona"
        )
        click_button "Officialize"

        expect(page).to have_content("officialized successfully")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_content("Officialized").and have_content("Major of Barcelona")
        end
      end
    end
  end

  describe "unofficializating users" do
    let!(:user) { create(:user, :officialized, organization: organization) }

    before do
      click_link "Officializations"

      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link "Unofficialize"
      end
    end

    it "unofficializes user and goes back to list" do
      expect(page).to have_content("unofficialized successfully")

      within "tr[data-user-id=\"#{user.id}\"]" do
        expect(page).to have_content("Not officialized")
      end
    end
  end

  describe "contacting the user" do
    let!(:user) { create(:user, organization: organization) }

    before do
      click_link "Officializations"
    end

    it "redirect to conversation path" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link "Contact"
      end
      expect(page).to have_current_path decidim.new_conversation_path(recipient_id: user.id)
    end
  end

  describe "clicking on user name" do
    let!(:user) { create(:user, organization: organization) }

    before do
      click_link "Officializations"
    end

    it "redirect to user profile page" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link user.name
      end
      expect(page).to have_current_path decidim.profile_path(user.nickname)
    end
  end

  describe "clicking on user nickname" do
    let!(:user) { create(:user, organization: organization) }

    before do
      click_link "Officializations"
    end

    it "redirect to user profile page" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link user.nickname
      end
      expect(page).to have_current_path decidim.profile_path(user.nickname)
    end
  end
end
