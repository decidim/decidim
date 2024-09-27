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
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, space_manifest: participatory_space.manifest.name) }
    let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
    let!(:component) { create(:component, manifest:, participatory_space:, settings: { taxonomy_filters: [taxonomy_filter.id] }) }

    it_behaves_like "manage results"
    it_behaves_like "export results"
  end

  describe "child results" do
    before do
      within ".table-list__actions" do
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

  describe "timeline" do
    before do
      visit_component_admin
      within "tr", text: translated(result.title) do
        click_on "Project evolution"
      end
    end

    let!(:timeline_entry) { create(:timeline_entry, result:) }

    it_behaves_like "manage timeline"
  end
end
