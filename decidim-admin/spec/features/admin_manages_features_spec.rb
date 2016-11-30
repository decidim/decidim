# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Admin manages features", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "add a feature" do
    before do
      visit decidim_admin.participatory_process_features_path(participatory_process)
    end

    it "adds a feature" do
      find("button[data-toggle=add-feature-dropdown]").click

      within "#add-feature-dropdown" do
        find(".dummy").click
      end

      within ".new_feature" do
        fill_in_i18n(
          :feature_name,
          "#name-tabs",
          en: "My feature",
          ca: "La meva funcionalitat",
          es: "Mi funcionalitat"
        )

        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("My feature")
    end
  end

  describe "remove a feature" do
    let(:feature_name) do
      {
        en: "My feature",
        ca: "La meva funcionalitat",
        es: "Mi funcionalitat"
      }
    end

    let!(:feature) do
      create(:feature, name: feature_name, participatory_process: participatory_process)
    end

    before do
      visit decidim_admin.participatory_process_features_path(participatory_process)
    end

    it "removes the feature" do
      within ".feature-#{feature.id}" do
        click_link "Destroy"
      end

      expect(page).to have_no_content("My feature")
    end
  end
end
