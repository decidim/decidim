# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process features", type: :feature do
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
      visit decidim_admin_participatory_processes.features_path(participatory_process)
    end

    context "when the process has active steps" do
      before do
        find("button[data-toggle=add-feature-dropdown]").click

        within "#add-feature-dropdown" do
          find(".dummy").click
        end

        within ".new_feature" do
          fill_in_i18n(
            :feature_name,
            "#feature-name-tabs",
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

          click_button "Add feature"
        end
      end

      it "is successfully created" do
        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content("My feature")
      end

      context "and then edit it" do
        before do
          within find("tr", text: "My feature") do
            click_link "Configure"
          end
        end

        it "successfully displays initial values in the form" do
          within ".global-settings" do
            expect(all("input[type=checkbox]").last).to be_checked
          end

          within ".step-settings" do
            expect(all("input[type=checkbox]").first).to be_checked
          end
        end

        it "successfully edits it" do
          click_button "Update"

          expect(page).to have_admin_callout("successfully")
        end
      end
    end

    context "when the process doesn't have active steps" do
      let!(:participatory_process) do
        create(:participatory_process, organization: organization)
      end

      before do
        find("button[data-toggle=add-feature-dropdown]").click

        within "#add-feature-dropdown" do
          find(".dummy").click
        end

        within ".new_feature" do
          fill_in_i18n(
            :feature_name,
            "#feature-name-tabs",
            en: "My feature",
            ca: "La meva funcionalitat",
            es: "Mi funcionalitat"
          )

          within ".global-settings" do
            all("input[type=checkbox]").last.click
          end

          within ".default-step-settings" do
            all("input[type=checkbox]").first.click
          end

          click_button "Add feature"
        end
      end

      it "is successfully created" do
        expect(page).to have_admin_callout("successfully")
        expect(page).to have_content("My feature")
      end

      context "and then edit it" do
        before do
          within find("tr", text: "My feature") do
            click_link "Configure"
          end
        end

        it "successfully displays initial values in the form" do
          within ".global-settings" do
            expect(all("input[type=checkbox]").last).to be_checked
          end

          within ".default-step-settings" do
            expect(all("input[type=checkbox]").first).to be_checked
          end
        end

        it "successfully edits it" do
          click_button "Update"

          expect(page).to have_admin_callout("successfully")
        end
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
      create(:feature, name: feature_name, participatory_space: participatory_process)
    end

    before do
      visit decidim_admin_participatory_processes.features_path(participatory_process)
    end

    it "updates the feature" do
      within ".feature-#{feature.id}" do
        click_link "Configure"
      end

      within ".edit_feature" do
        fill_in_i18n(
          :feature_name,
          "#feature-name-tabs",
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

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My updated feature")

      within find("tr", text: "My updated feature") do
        click_link "Configure"
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within ".step-settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end
    end

    context "when the process doesn't have active steps" do
      before { participatory_process.steps.destroy_all }

      it "updates the default step settings" do
        within ".feature-#{feature.id}" do
          click_link "Configure"
        end

        within ".edit_feature" do
          within ".default-step-settings" do
            all("input[type=checkbox]").first.click
          end

          click_button "Update"
        end

        expect(page).to have_admin_callout("successfully")

        within find("tr", text: "My feature") do
          click_link "Configure"
        end

        within ".default-step-settings" do
          expect(all("input[type=checkbox]").first).to be_checked
        end
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
      create(:feature, name: feature_name, participatory_space: participatory_process)
    end

    before do
      visit decidim_admin_participatory_processes.features_path(participatory_process)
    end

    it "removes the feature" do
      within ".feature-#{feature.id}" do
        click_link "Destroy"
      end

      expect(page).to have_no_content("My feature")
    end
  end

  describe "publish and unpublish a feature" do
    let!(:feature) do
      create(:feature, participatory_space: participatory_process, published_at: published_at)
    end

    let(:published_at) { nil }

    before do
      visit decidim_admin_participatory_processes.features_path(participatory_process)
    end

    context "when the feature is unpublished" do
      it "publishes the feature" do
        within ".feature-#{feature.id}" do
          click_link "Publish"
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
          click_link "Unpublish"
        end

        within ".feature-#{feature.id}" do
          expect(page).to have_css(".action-icon--publish")
        end
      end
    end
  end
end
