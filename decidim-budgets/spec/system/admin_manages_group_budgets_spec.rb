# frozen_string_literal: true

require "spec_helper"

describe "Admin manages group budgets", type: :system do
  let(:manifest_name) { "budgets_groups" }

  include_context "when managing a component as an admin"

  describe "add a budgets component" do
    it "creates a new budgets component", :slow do
      find(".card-title a.button").click

      within ".new_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My component",
          ca: "La meva funcionalitat",
          es: "Mi funcionalitat"
        )

        click_button "Add component"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My component")
      expect(page).to have_current_path manage_component_path(component)
    end
  end

  describe "edit a component" do
    let(:component) { create(:budgets_group_component, :with_children, participatory_space: participatory_space) }
    let(:child_component) { component.children.first }

    it "updates the component" do
      within ".component-#{child_component.id}" do
        click_link "Configure"
      end

      within ".edit_component" do
        fill_in_i18n(
          :component_name,
          "#component-name-tabs",
          en: "My updated component",
          ca: "La meva funcionalitat actualitzada",
          es: "Mi funcionalidad actualizada"
        )

        click_button "Update"
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_content("My updated component")

      expect(page).to have_current_path manage_component_path(component)
    end
  end

  describe "remove a component" do
    let(:component) { create(:budgets_group_component, :with_children, participatory_space: participatory_space) }
    let(:child_component) { component.children.first }

    it "removes the component" do
      within ".component-#{child_component.id}" do
        click_link "Delete"
      end

      expect(page).to have_no_content("My component")
    end
  end

  describe "publish and unpublish a component" do
    let(:component) { create(:budgets_group_component, :with_children, participatory_space: participatory_space) }
    let(:child_component) { component.children.first }
    let(:follow) { create(:follow, followable: participatory_space, user: follower) }
    let(:follower) { create(:user, organization: organization) }

    before { follow }

    it "unpublishes the component" do
      within ".component-#{child_component.id}" do
        click_link "Unpublish"
      end

      within ".component-#{child_component.id}" do
        expect(page).to have_css(".action-icon--publish")
      end
    end

    context "when the component is unpublished" do
      before { child_component.update published_at: nil }

      it "publishes the component" do
        page.refresh

        within ".component-#{child_component.id}" do
          click_link "Publish"
        end

        within ".component-#{child_component.id}" do
          expect(page).to have_css(".action-icon--unpublish")
        end
      end
    end
  end
end
