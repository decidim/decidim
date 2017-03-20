# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Admin manages features", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:participatory_process) do
    create(:participatory_process, :with_steps, organization: organization)
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

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within ".step-settings" do
          all("input[type=checkbox]").first.click
        end

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("My feature")

      within find("tr", text: "My feature") do
        page.find(".action-icon--configure").click
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within ".step-settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end
    end
  end

  describe "edit a feature" do
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

    it "updates the feature" do
      within ".feature-#{feature.id}" do
        page.find(".action-icon--configure").click
      end

      within ".edit_feature" do
        fill_in_i18n(
          :feature_name,
          "#name-tabs",
          en: "My updated feature",
          ca: "La meva funcionalitat actualitzada",
          es: "Mi funcionalidad actualizada"
        )

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within ".step-settings" do
          all("input[type=checkbox]").first.click
        end

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_content("My updated feature")

      within find("tr", text: "My updated feature") do
        page.find(".action-icon--configure").click
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within ".step-settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end
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
        page.find(".action-icon--remove").click
      end

      expect(page).to have_no_content("My feature")
    end
  end

  describe "publish and unpublish a feature" do
    let!(:feature) do
      create(:feature, participatory_process: participatory_process, published_at: published_at)
    end

    let(:published_at) { nil }

    before do
      visit decidim_admin.participatory_process_features_path(participatory_process)
    end

    context "when the feature is unpublished" do
      it "publishes the feature" do
        within ".feature-#{feature.id}" do
          page.find(".action-icon--publish").click
        end

        within ".feature-#{feature.id}" do
          expect(page).to have_css(".action-icon--unpublish")
        end
      end
    end

    context "when the feature is published" do
      let(:published_at) { Time.current }

      it "unpublishes the feature" do
        within ".feature-#{feature.id}" do
          page.find(".action-icon--unpublish").click
        end

        within ".feature-#{feature.id}" do
          expect(page).to have_css(".action-icon--publish")
        end
      end
    end
  end
end
