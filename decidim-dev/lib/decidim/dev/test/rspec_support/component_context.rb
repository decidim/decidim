# frozen_string_literal: true

shared_context "with a component" do
  let(:manifest) { Decidim.find_component_manifest(manifest_name) }
  let(:user) { create :user, :confirmed, organization: }

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

  let!(:category) { create :category, participatory_space: }
  let!(:scope) { create :scope, organization: }

  let(:organization_traits) { [] }

  before do
    if organization_traits.include?(:secure_context)
      switch_to_secure_context_host
    else
      switch_to_host(organization.host)
    end
  end

  def visit_component
    page.visit main_component_path(component)
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
    create :user,
           :admin,
           :confirmed,
           organization:
  end
end

shared_context "when managing a component as a process admin" do
  include_context "when managing a component"

  let(:user) do
    create :process_admin,
           :confirmed,
           organization:,
           participatory_process:
  end
end
