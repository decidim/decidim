# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly share tokens" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, organization:, private_space: true) }
  let(:participatory_space) { assembly }
  let(:participatory_space_path) { decidim_admin_assemblies.edit_assembly_path(assembly) }
  let(:participatory_spaces_path) { decidim_admin_assemblies.assemblies_path }

  it_behaves_like "manage participatory space share tokens"

  context "when the user is an assembly admin" do
    let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:role) { create(:assembly_user_role, user:, assembly:, role: :admin) }

    it_behaves_like "manage participatory space share tokens"
  end
end
