# frozen_string_literal: true

shared_examples "has mandatory config setting" do |mandatory_field|
  let(:edit_component_path) do
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    visit edit_component_path
    component.update(settings: { mandatory_field => "" })
    visit edit_component_path
  end

  it "does not allow updating the component" do
    click_on "Update"

    within ".#{mandatory_field}_container" do
      expect(page).to have_content("There is an error in this field")
    end
  end
end

shared_context "with a component" do
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }
  let(:user) { create(:user, :confirmed, organization:) }

  let!(:organization) { create(:organization, *organization_traits, available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)) }

  let(:participatory_process) do
    create(:participatory_process, :with_steps, organization:)
  end

  let(:participatory_space) { participatory_process }

  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:)
  end

  let!(:category) { create(:category, participatory_space:) }
  let!(:scope) { create(:scope, organization:) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let(:taxonomy_filter) { create(:taxonomy_filter, internal_name:, name:, participatory_space_manifests: [participatory_space.manifest.name], root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:internal_name) { { "en" => "Internal taxonomy filter name" } }
  let(:name) { { "en" => "Public taxonomy filter name" } }

  let(:organization_traits) { [] }

  before do
    if organization_traits.include?(:secure_context)
      switch_to_secure_context_host
    else
      switch_to_host(organization.host)
    end
  end

  def visit_component
    page.visit main_component_path(component, locale: I18n.locale)
  end
end

shared_context "when managing a component" do
  include_context "with a component" do
    let(:organization_traits) { component_organization_traits }
  end

  let(:current_component) { component }
  let(:component_organization_traits) { [] }

  before do
    login_as user, scope: :user
    visit_component_admin
  end

  def visit_component_admin
    visit manage_component_path(component)
  end

  # Returns the config path for a given component.
  #
  # component - the Component we want to find the root path for.
  #
  # Returns a url.
  def edit_component_path(component)
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end
end

shared_context "when managing a component as an admin" do
  include_context "when managing a component" do
    let(:component_organization_traits) { admin_component_organization_traits }
  end

  let(:admin_component_organization_traits) { [] }

  let(:user) do
    create(:user,
           :admin,
           :confirmed,
           organization:)
  end
end

shared_context "when managing a component as a process admin" do
  include_context "when managing a component"

  let(:user) do
    create(:process_admin,
           :confirmed,
           organization:,
           participatory_process:)
  end
end
