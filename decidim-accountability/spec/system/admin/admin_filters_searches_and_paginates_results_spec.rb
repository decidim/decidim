# frozen_string_literal: true

require "spec_helper"

describe "Admin filters, searches, and paginates results" do
  include_context "when managing a component as an admin"
  include_context "with filterable context"

  let(:manifest_name) { "accountability" }
  let(:resource_controller) { Decidim::Accountability::Admin::ResultsController }

  it_behaves_like "a collection filtered by taxonomies" do
    let!(:result_with_taxonomy11) { create(:result, component: current_component, taxonomies: [taxonomy11]) }
    let!(:result_with_taxonomy12) { create(:result, component: current_component, taxonomies: [taxonomy12]) }
    let!(:result_with_taxonomy21) { create(:result, component: current_component, taxonomies: [taxonomy21]) }
    let!(:result_with_taxonomy22) { create(:result, component: current_component, taxonomies: [taxonomy22]) }
    let(:resource_with_taxonomy11_title) { translated(result_with_taxonomy11.title) }
    let(:resource_with_taxonomy12_title) { translated(result_with_taxonomy12.title) }
    let(:resource_with_taxonomy21_title) { translated(result_with_taxonomy21.title) }
    let(:resource_with_taxonomy22_title) { translated(result_with_taxonomy22.title) }
  end

  context "when filtering by status" do
    let!(:status1) { create(:status, component: current_component, name: { "en" => "Status1" }) }
    let!(:status2) { create(:status, component: current_component, name: { "en" => "Status2" }) }
    let!(:result_with_status1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      status: status1)
    end
    let(:result_with_status1_title) { translated(result_with_status1.title) }
    let!(:result_with_status2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      status: status2)
    end
    let(:result_with_status2_title) { translated(result_with_status2.title) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Status", filter: "Status1" do
      let(:in_filter) { result_with_status1_title }
      let(:not_in_filter) { result_with_status2_title }
    end

    it_behaves_like "a filtered collection", options: "Status", filter: "Status2" do
      let(:in_filter) { result_with_status2_title }
      let(:not_in_filter) { result_with_status1_title }
    end
  end

  context "when searching by ID or title" do
    let!(:result1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) })
    end
    let!(:result2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) })
    end
    let!(:result1_title) { translated(result1.title) }
    let!(:result2_title) { translated(result2.title) }

    it "can be searched by ID" do
      search_by_text(result1.id)

      expect(page).to have_content(result1_title)
    end

    it "can be searched by title" do
      search_by_text(result2_title)

      expect(page).to have_content(result2_title)
    end
  end

  context "when listing results" do
    it_behaves_like "paginating a collection" do
      let!(:collection) { create_list(:result, 50, component: current_component) }
    end
  end
end
