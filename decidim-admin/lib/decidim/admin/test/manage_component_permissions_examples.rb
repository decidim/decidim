# frozen_string_literal: true

require "spec_helper"

shared_examples "Managing component permissions" do
  let(:organization) { create(:organization, available_authorizations: ["dummy_authorization_handler"]) }

  let!(:component) do
    create(:component, participatory_space: participatory_space)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit participatory_space_engine.components_path(participatory_space)

    within ".component-#{component.id}" do
      click_link "Permissions"
    end
  end

  it "allows setting permissions with json options" do
    within "form.new_component_permissions" do
      within ".foo-permission" do
        select "Example authorization", from: "component_permissions_permissions_foo_authorization_handler_name"
        fill_in "component_permissions_permissions_foo_options", with: '{ "foo": 123 }'
      end
      find("*[type=submit]").click
    end

    expect(page).to have_content("successfully")

    expect(component.reload.permissions["foo"]).to(
      include(
        "authorization_handler_name" => "dummy_authorization_handler",
        "options" => { "foo" => 123 }
      )
    )
  end
end
