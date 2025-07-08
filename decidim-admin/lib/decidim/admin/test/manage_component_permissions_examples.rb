# frozen_string_literal: true

require "spec_helper"

shared_examples "access permissions form" do
  it "can view the permissions" do
    within "tr", text: row_text do
      find("button[data-component='dropdown']").click
      click_on "Permissions"
    end
    expect(page).to have_content(permission)
  end
end

shared_examples "Managing component permissions" do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)
    )
  end

  let!(:component) do
    create(:component, participatory_space:)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit participatory_space_engine.components_path(participatory_space)
  end

  context "when setting permissions" do
    before do
      within ".component-#{component.id}" do
        find("button[data-component='dropdown']").click
        click_on "Permissions"
      end
    end

    it "saves permission settings in the component" do
      within "#components form" do
        within ".foo-permission" do
          check "Example authorization (Direct)"
          fill_in "Allowed postal codes", with: "08002"
        end
        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
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

  context "when failing to set permissions" do
    before do
      allow_any_instance_of(Decidim::Admin::PermissionsForm).to receive(:valid?).and_return(false)
      within ".component-#{component.id}" do
        find("button[data-component='dropdown']").click
        click_on "Permissions"
      end
      within "#components form" do
        within ".foo-permission" do
          check "Example authorization (Direct)"
          fill_in "Allowed postal codes", with: "08002"
        end
        find("*[type=submit]").click
      end
    end

    it "renders the form again" do
      expect(page).to have_content("problem")
    end
  end

  context "when unsetting permissions" do
    before do
      component.update!(
        permissions: {
          "foo" => {
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "allowed_postal_codes" => "08002" }
              }
            }
          }
        }
      )

      within ".component-#{component.id}" do
        find("button[data-component='dropdown']").click
        click_on "Permissions"
      end
    end

    it "removes the action from the permissions hash" do
      within "#components form" do
        within ".foo-permission" do
          uncheck "Example authorization (Direct)"
          uncheck "Another example authorization (Direct)"
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
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "allowed_postal_codes" => "08002" }
              }
            }
          }
        }
      )

      within ".component-#{component.id}" do
        find("button[data-component='dropdown']").click
        click_on "Permissions"
      end
    end

    it "changes the configured action in the permissions hash" do
      within "#components form" do
        within ".foo-permission" do
          uncheck "Example authorization (Direct)"
          check "Another example authorization (Direct)"
          fill_in "Passport number", with: "AXXXXXXXX"
        end

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
        include(
          "authorization_handlers" => {
            "another_dummy_authorization_handler" => {
              "options" => { "passport_number" => "AXXXXXXXX" }
            }
          }
        )
      )
    end

    it "adds an authorization to the configured action in the component permissions hash" do
      within "#components form" do
        within ".foo-permission" do
          check "Another example authorization (Direct)"
          fill_in "Passport number", with: "AXXXXXXXX"
        end

        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      expect(component.reload.permissions["foo"]).to(
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

  context "when managing resource permissions" do
    let!(:resource) do
      create(:dummy_resource, component:)
    end

    let(:edit_resource_permissions_path) do
      Decidim::EngineRouter.admin_proxy(participatory_space).edit_component_permissions_path(component.id,
                                                                                             resource_name: resource.resource_manifest.name,
                                                                                             resource_id: resource.id)
    end

    let(:component_settings) { nil }

    before do
      if component_settings
        component.settings = component_settings
        component.save!
      end
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit edit_resource_permissions_path
    end

    it "shows the resource permissions settings" do
      expect(page).to have_content("Edit permissions")
    end

    context "when resources permissions are disabled" do
      let(:component_settings) { { resources_permissions_enabled: false } }

      it "does not show the resource permissions settings" do
        expect(page).to have_no_content(resource.title)
      end
    end

    context "when setting permissions" do
      it "saves permission settings for the resource" do
        within "#components form" do
          within ".foo-permission" do
            check "Example authorization (Direct)"
            fill_in "Allowed postal codes", with: "08002"
          end
          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to(
          include(
            "authorization_handlers" => {
              "dummy_authorization_handler" => {
                "options" => { "allowed_postal_codes" => "08002" }
              }
            }
          )
        )
        expect(component.reload.permissions).to be_nil
      end
    end

    context "when unsetting permissions" do
      before do
        resource.create_resource_permission(
          permissions: {
            "foo" => {
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
        within "#components form" do
          within ".foo-permission" do
            uncheck "Example authorization (Direct)"
            uncheck "Another example authorization (Direct)"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to be_nil
      end
    end

    context "when changing existing permissions" do
      before do
        resource.create_resource_permission(
          permissions: {
            "foo" => {
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
        within "#components form" do
          within ".foo-permission" do
            uncheck "Example authorization (Direct)"
            check "Another example authorization (Direct)"
            fill_in "Passport number", with: "AXXXXXXXX"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to(
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
        within "#components form" do
          within ".foo-permission" do
            check "Another example authorization (Direct)"
            fill_in "Passport number", with: "AXXXXXXXX"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to(
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

    context "when overriding component permissions" do
      before do
        component.update!(
          permissions: {
            "foo" => {
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
        within "#components form" do
          within ".foo-permission" do
            uncheck "Example authorization (Direct)"
            check "Another example authorization (Direct)"
            fill_in "Passport number", with: "AXXXXXXXX"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to(
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
        within "#components form" do
          within ".foo-permission" do
            check "Another example authorization (Direct)"
            fill_in "Passport number", with: "AXXXXXXXX"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to(
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

    context "when unsetting component permissions" do
      before do
        component.update!(
          permissions: {
            "foo" => {
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

      it "saves the action from the permissions hash as an empty hash" do
        within "#components form" do
          within ".foo-permission" do
            uncheck "Example authorization (Direct)"
            uncheck "Another example authorization (Direct)"
          end

          find("*[type=submit]").click
        end

        expect(page).to have_content("DUMMY ADMIN ENGINE")

        expect(resource.reload.permissions["foo"]).to eq({})
      end
    end
  end
end
