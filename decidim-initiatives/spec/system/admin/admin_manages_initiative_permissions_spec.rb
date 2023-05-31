# frozen_string_literal: true

require "spec_helper"
# require "decidim/admin/test/manage_component_permissions_examples"

# We should ideally be using the shared_context for this, but it assumes the
# resource belongs to a component, which is not the case.
describe "Admin manages initiative permissions", type: :system do
  let(:organization) do
    create(
      :organization,
      available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)
    )
  end
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_space_engine) { decidim_admin_initiatives }
  let!(:initiative_type) { create(:initiatives_type, :online_signature_enabled, organization:) }
  let!(:scoped_type) { create(:initiatives_type_scope, type: initiative_type) }
  let(:initiative) { create(:initiative, :published, author:, scoped_type:, organization:) }
  let!(:author) { create(:user, :confirmed, organization:) }

  let(:action) { "comment" }

  let(:index_path) do
    participatory_space_engine.initiatives_path
  end
  let(:edit_resource_permissions_path) do
    participatory_space_engine
      .edit_initiative_permissions_path(
        initiative,
        resource_name: initiative.resource_manifest.name
      )
  end
  let(:index_class_selector) { ".initiative-#{initiative.id}" }
  let(:resource) { initiative }

  it_behaves_like "manage resource permissions"
end
