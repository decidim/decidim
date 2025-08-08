# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_access_examples"

describe "AdminAccess" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:assembly, organization:, title: { en: "My space" }) }
  let(:other_participatory_space) { create(:assembly, organization:) }

  context "with participatory space admin" do
    let(:role) { create(:assembly_admin, :confirmed, organization:, assembly: participatory_space) }
    let(:target_path) { decidim_admin_assemblies.edit_assembly_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_assemblies.edit_assembly_path(other_participatory_space) }
    let(:participatory_space_path) { decidim_assemblies.assembly_path(participatory_space) }

    it_behaves_like "admin participatory space access"
    it_behaves_like "admin participatory space edit button"
  end

  context "with participatory space evaluator" do
    let(:role) { create(:assembly_evaluator, :confirmed, organization:, assembly: participatory_space) }
    let(:target_path) { decidim_admin_assemblies.components_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_assemblies.components_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end

  context "with participatory space moderator" do
    let(:role) { create(:assembly_moderator, :confirmed, organization:, assembly: participatory_space) }
    let(:target_path) { decidim_admin_assemblies.moderations_path(participatory_space) }
    let(:unauthorized_target_path) { decidim_admin_assemblies.moderations_path(other_participatory_space) }

    it_behaves_like "admin participatory space access"
  end
end
