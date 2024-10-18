# frozen_string_literal: true

require "spec_helper"

describe "Admin manages accountability" do
  let(:manifest_name) { "accountability" }

  include_context "when managing an accountability component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "results" do
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

  describe "soft delete result" do
    let(:admin_resource_path) { current_path }
    let(:trash_path) { "#{admin_resource_path}/results/manage_trash" }
    let(:title) { { en: "My new result" } }
    let!(:resource) { create(:result, component:, deleted_at:, title:) }

    it_behaves_like "manage soft deletable resource", "result"
    it_behaves_like "manage trashed resource", "result"
  end
end
