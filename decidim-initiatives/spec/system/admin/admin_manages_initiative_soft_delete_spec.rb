# frozen_string_literal: true

require "spec_helper"

describe "Admin manages initiative soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_initiatives.initiatives_path }
  let(:trash_path) { decidim_admin_initiatives.manage_trash_initiatives_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:initiative, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "initiative"
  it_behaves_like "manage trashed resource", "initiative"
end
