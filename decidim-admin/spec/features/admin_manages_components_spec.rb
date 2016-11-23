# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Admin manages components", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  let!(:participatory_process_step) do
    create(:participatory_process_step, participatory_process: participatory_process)
  end

  let!(:feature) do
    create(:feature, participatory_process: participatory_process)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "add a component" do
    before do
      visit decidim_admin.participatory_process_features_path(participatory_process)
    end

    it "adds a component" do
      find("button[data-toggle=add-component-dropdown-#{feature.id}]").click

      within "#add-component-dropdown-#{feature.id}" do
        find(".dummy").click
      end

      expect(page).to have_content("Add component")

      within ".new_component" do
        fill_in_i18n(
          :component_name,
          "#name-tabs",
          en: "My component",
          es: "Mi compomente",
          ca: "El meu component"
        )

        find("label", text: participatory_process_step.title["en"]).click
        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      within ".feature-#{feature.id}" do
        expect(page).to have_content("My component")
      end
    end
  end

  describe "remove a component" do
    before do
      component_name = {
        en: "My component",
        ca: "El meu component",
        es: "Mi componente"
      }

      create(:component, feature: feature, name: component_name)
      visit decidim_admin.participatory_process_features_path(participatory_process)
    end

    it "removes the component" do
      within ".feature-#{feature.id} .components" do
        click_link "Destroy"
      end

      within ".feature-#{feature.id} .components" do
        expect(page).to have_no_content("My component")
      end
    end
  end
end
