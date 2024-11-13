# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposal soft delete" do
  include_context "when managing a component as an admin"

  let(:manifest_name) { "proposals" }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { current_path }
  let(:trash_path) { "#{admin_resource_path}/proposals/manage_trash" }
  let(:title) { { en: "My proposal" } }
  let!(:resource) { create(:proposal, component: current_component, title:) }

  it_behaves_like "manage soft deletable resource", "proposal"
  it_behaves_like "manage trashed resource", "proposal"
end
