# frozen_string_literal: true

require "spec_helper"

describe "Admin manages consultation components", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:consultation) { create(:consultation, organization: organization) }
  let!(:question) { create(:question, consultation: consultation) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "add a component" do
    before do
      visit decidim_admin_consultations.components_path(question)

      find("button[data-toggle=add-component-dropdown]").click

      within "#add-component-dropdown" do
        find(".dummy").click
      end

      within ".new_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My component",
          ca: "El meu component",
          es: "Mi componente"
        )

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within ".default-step-settings" do
          all("input[type=checkbox]").first.click
        end

        click_button "Add component"
      end
    end

    it "is successfully created" do
      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My component")
    end

    context "and then edit it" do
      before do
        within find("tr", text: "My component") do
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

  describe "edit a component" do
    let(:component_name) do
      {
        en: "My component",
        ca: "El meu component",
        es: "Mi component"
      }
    end

    let!(:component) do
      create(:component, name: component_name, participatory_space: question)
    end

    before do
      visit decidim_admin_consultations.components_path(question)
    end

    it "updates the component" do
      within ".component-#{component.id}" do
        click_link "Configure"
      end

      within ".edit_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My updated component",
          ca: "El meu component actualitzat",
          es: "Mi component actualizado"
        )

        within ".global-settings" do
          all("input[type=checkbox]").last.click
        end

        within ".default-step-settings" do
          all("input[type=checkbox]").first.click
        end

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My updated component")

      within find("tr", text: "My updated component") do
        click_link "Configure"
      end

      within ".global-settings" do
        expect(all("input[type=checkbox]").last).to be_checked
      end

      within ".default-step-settings" do
        expect(all("input[type=checkbox]").first).to be_checked
      end
    end
  end

  describe "remove a component" do
    let(:component_name) do
      {
        en: "My component",
        ca: "El meu component",
        es: "Mi componente"
      }
    end

    let!(:component) do
      create(:component, name: component_name, participatory_space: question)
    end

    before do
      visit decidim_admin_consultations.components_path(question)
    end

    it "removes the component" do
      within ".component-#{component.id}" do
        click_link "Delete"
      end

      expect(page).to have_no_content("My component")
    end
  end

  describe "publish and unpublish a component" do
    let!(:component) do
      create(:component, participatory_space: question, published_at: published_at)
    end

    let(:published_at) { nil }

    before do
      visit decidim_admin_consultations.components_path(question)
    end

    context "when the component is unpublished" do
      it "publishes the component" do
        within ".component-#{component.id}" do
          click_link "Publish"
        end

        within ".component-#{component.id}" do
          expect(page).to have_css(".action-icon--unpublish")
        end
      end
    end

    context "when the component is published" do
      let(:published_at) { Time.current }

      it "unpublishes the component" do
        within ".component-#{component.id}" do
          click_link "Unpublish"
        end

        within ".component-#{component.id}" do
          expect(page).to have_css(".action-icon--publish")
        end
      end
    end
  end
end
