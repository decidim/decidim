# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly share tokens" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, organization:, private_space: true) }

  it_behaves_like "manage participatory space share tokens" do
    let(:participatory_space) { assembly }
    let(:participatory_space_path) { decidim_admin_assemblies.edit_assembly_path(assembly) }
  end
end
