# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_component_permissions_examples"

# We should ideally be using the shared_context for this, but it assumes the
# resource belongs to a component, which is not the case.
describe "Admin manages initiative type permissions", type: :system do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)
    )
  end
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_space_engine) { decidim_admin_initiatives }
  let!(:initiative_type) { create :initiatives_type, organization: organization }

  let(:action) { "vote" }

  let(:index_path) do
    participatory_space_engine.initiatives_types_path
  end
  let(:index_class_selector) { ".initiative-type-#{initiative_type.id}" }

  context "when managing resource permissions" do
    let(:edit_resource_permissions_path) do
      participatory_space_engine
        .edit_initiatives_type_permissions_path(
          initiative_type.id,
          resource_name: initiative_type.resource_manifest.name
        )
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit edit_resource_permissions_path
    end

    it "shows the resource permissions settings" do
      expect(page).to have_content(translated(initiative_type.title))
    end

    context "when setting permissions" do
      it "saves permission settings for the resource" do
        within "form.new_component_permissions" do
          within ".#{action}-permission" do
            check "Example authorization (Direct)"
            fill_in "Allowed postal codes", with: "08002"
          end
          find("*[type=submit]").click
        end

        expect(page).to have_content("Permissions updated successfully.")

        expect(initiative_type.reload.permissions[action]).to(
          include(
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "allowed_postal_codes" => "08002" }
              }
            }
          )
        )
      end
    end

    context "when unsetting permissions" do
      before do
        initiative_type.create_resource_permission(
          permissions: {
            action => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => {
                  "options" => { "allowed_postal_codes" => "08002" }
                }
              }
            }
          }
        )

        visit edit_resource_permissions_path
      end

      it "removes the action from the permissions hash" do
        within "form.new_component_permissions" do
          within ".#{action}-permission" do
            uncheck "Example authorization (Direct)"
            uncheck "Another example authorization (Direct)"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("Permissions updated successfully.")

        expect(initiative_type.reload.permissions[action]).to be_nil
      end
    end

    context "when changing existing permissions" do
      before do
        initiative_type.create_resource_permission(
          permissions: {
            action => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => {
                  "options" => { "allowed_postal_codes" => "08002" }
                }
              }
            }
          }
        )

        visit edit_resource_permissions_path
      end

      it "changes the configured action in the resource permissions hash" do
        within "form.new_component_permissions" do
          within ".#{action}-permission" do
            uncheck "Example authorization (Direct)"
            check "Another example authorization (Direct)"
            fill_in "Passport number", with: "AXXXXXXXX"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("Permissions updated successfully.")

        expect(initiative_type.reload.permissions[action]).to(
          include(
            "authorization_handlers" => {
              "another_dummy_authorization_handler" => {
                "options" => { "passport_number" => "AXXXXXXXX" }
              }
            }
          )
        )
      end

      it "adds an authorization to the configured action in the resource permissions hash" do
        within "form.new_component_permissions" do
          within ".#{action}-permission" do
            check "Another example authorization (Direct)"
            fill_in "Passport number", with: "AXXXXXXXX"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("Permissions updated successfully.")

        expect(initiative_type.reload.permissions[action]).to(
          include(
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "allowed_postal_codes" => "08002" }
              },
              "another_dummy_authorization_handler" => {
                "options" => { "passport_number" => "AXXXXXXXX" }
              }
            }
          )
        )
      end
    end
  end
end
