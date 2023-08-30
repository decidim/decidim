# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:assembly, organization:, title: { en: "My space" }) }
  let(:other_participatory_space) { create(:assembly, organization:) }

  context "with participatory space admin" do
    let(:role) { create(:assembly_admin, :confirmed, organization:, assembly: participatory_space) }
    let(:target_path) { decidim_admin_assemblies.edit_assembly_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_assemblies.edit_assembly_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end

  context "with participatory space valuator" do
    let(:role) { create(:assembly_valuator, :confirmed, organization:, assembly: participatory_space) }
    let(:target_path) { decidim_admin_assemblies.components_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_assemblies.components_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end
end
