# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_assemblies.assemblies_path }
  let(:trash_path) { decidim_admin_assemblies.manage_trash_assemblies_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:assembly, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "assembly"
  it_behaves_like "manage trashed resource", "assembly"
end
