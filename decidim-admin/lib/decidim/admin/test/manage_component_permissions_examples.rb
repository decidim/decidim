# frozen_string_literal: true

require "spec_helper"

shared_examples "Managing component permissions" do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)
    )
  end

  let!(:component) do
    create(:component, participatory_space: participatory_space)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit participatory_space_engine.components_path(participatory_space)
  end

  context "when setting permissions" do
    before do
      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "saves permission settings in the component" do
      within "form.new_component_permissions" do
        within ".foo-permission" do
          select "Example authorization", from: "component_permissions_permissions_foo_authorization_handler_name"
          fill_in "component_permissions_permissions_foo_options_postal_code", with: "08002"
        end
        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handler_name" => "dummy_authorization_handler",
          "options" => { "postal_code" => "08002" }
        )
      )
    end
  end

  context "when unsetting permissions" do
    before do
      component.update!(
        permissions: {
          "foo" => {
            "authorization_handler_name" => "dummy_authorization_handler",
            "options" => { "postal_code" => "08002" }
          }
        }
      )

      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "removes the action from the permissions hash" do
      within "form.new_component_permissions" do
        within ".foo-permission" do
          select "Everyone", from: "component_permissions_permissions_foo_authorization_handler_name"
        end

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to be_nil
    end
  end

  context "when changing existing permissions" do
    before do
      component.update!(
        permissions: {
          "foo" => {
            "authorization_handler_name" => "dummy_authorization_handler",
            "options" => { "postal_code" => "08002" }
          }
        }
      )

      within ".component-#{component.id}" do
        click_link "Permissions"
      end
    end

    it "changes the configured action in the permissions hash" do
      within "form.new_component_permissions" do
        within ".foo-permission" do
          select "Another example authorization", from: "component_permissions_permissions_foo_authorization_handler_name"
          fill_in "component_permissions_permissions_foo_options_passport_number", with: "AXXXXXXXX"
        end

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handler_name" => "another_dummy_authorization_handler",
          "options" => { "passport_number" => "AXXXXXXXX" }
        )
      )
    end
  end
end
