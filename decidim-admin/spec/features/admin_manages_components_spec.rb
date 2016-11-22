# coding: utf-8
# frozen_string_literal: true
require "spec_helper"
require "decidim/dummy_component_manifest"

describe "Admin manages components", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:participatory_process) do
    create(:participatory_process, organization: organization)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "add a component" do
    before do
      visit decidim_admin.participatory_process_components_path(participatory_process)
    end

    it "adds a component" do
      find("button[data-toggle=add-component-dropdown]").click
      within ".add-components" do
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

        find("*[type=submit]").click
      end

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      within "#components" do
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

      create(:component, participatory_process: participatory_process, name: component_name)
      visit decidim_admin.participatory_process_components_path(participatory_process)
    end

    it "removes the component" do
      within "#components table" do
        click_link "Destroy"
      end

      within "#components table" do
        expect(page).to have_no_content("My component")
      end
    end
  end
end
