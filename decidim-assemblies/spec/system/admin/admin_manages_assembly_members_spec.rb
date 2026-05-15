# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/admin_members_shared_examples"

describe "Admin manages assembly members" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let!(:participatory_space) { create(:assembly, organization:, has_members: true) }
  let(:participatory_space_edit_path) { decidim_admin_assemblies.edit_assembly_path(participatory_space) }

  it_behaves_like "manage admin members examples"
end
