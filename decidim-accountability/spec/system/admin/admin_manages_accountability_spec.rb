# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability" do
  include_context "when managing an accountability component as an admin"
  let(:manifest_name) { "accountability" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it_behaves_like "manage taxonomy filters in settings"

  describe "results" do
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
    let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
    let!(:component) { create(:component, manifest:, participatory_space:, settings: { taxonomy_filters: [taxonomy_filter.id] }) }

    it_behaves_like "manage results"
    it_behaves_like "when managing results bulk actions as an admin"
    it_behaves_like "export results"
  end

  describe "child results" do
    before do
      within "tr[data-id='#{result.id}'] .table-list__actions" do
        click_on "New result"
      end
    end

    it_behaves_like "manage child results"
  end

  describe "statuses" do
    before do
      click_on "Statuses"
    end

    it_behaves_like "manage statuses"
  end

  describe "milestone" do
    before do
      visit_component_admin
      within "tr", text: translated(result.title) do
        click_on "Milestones"
      end
    end

    let!(:milestone) { create(:milestone, result:) }

    it_behaves_like "manage milestone"
  end

  describe "soft delete result" do
    let(:admin_resource_path) { current_path }
    let(:trash_path) { "#{admin_resource_path}/results/manage_trash" }
    let(:title) { { en: "My new result" } }
    let!(:resource) { create(:result, component:, title:) }

    it_behaves_like "manage soft deletable resource", "result"
    it_behaves_like "manage trashed resource", "result"
  end
end
